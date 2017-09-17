require 'spec_helper'
require 'change_proxy/env'
require 'change_proxy/editor'

RSpec.describe ChangeProxy::Editor do
	subject { described_class.new('spec/fixtures/gradle.properties', %w{http}) }

	context '#initialize' do
		it 'raises a Thor::Error when the file does not exist' do
			expect { described_class.new('invalid/file') }.to raise_error(Thor::Error, /file not found/)
			expect { described_class.new(nil) }.to raise_error(Thor::Error, /file not found/)
		end

		it 'raises a Thor::Error when there are no protocols' do
			expect { described_class.new('spec/fixtures/gradle.properties', []) }.to raise_error(Thor::Error, /No protocols/)
			expect { described_class.new('spec/fixtures/gradle.properties', nil) }.to raise_error(Thor::Error, /No protocols/)
		end
	end

	context '#rewrite' do
		let(:env) { ChangeProxy::Env.new('proxy' => 'cache:1080', 'http_proxy' => 'cache:3128', 'no_proxy' => 'example.org,example.net,example.com') }
		let(:props) { subject.rewrite(env) }

		it 'returns a ChangeProxy::Gradle::Props instance' do
			expect(props).to be_a ChangeProxy::Gradle::Props
		end

		it 'has changes' do
			expect(props.changed?).to be_truthy
		end

		it 'has the new contents' do
			expect(props.lines).to include("systemProp.http.proxyHost=cache\n", "systemProp.http.proxyPort=3128\n")
		end

		context 'with gradle-nochanges.properties' do
			subject { described_class.new('spec/fixtures/gradle-nochanges.properties', %w{http}) }

			it 'has no changes' do
				expect(props.changed?).to be_falsey
			end

			it 'yet it still has the contents' do
				expect(props.lines).to include("systemProp.http.proxyHost=cache\n", "systemProp.http.proxyPort=3128\n")
			end
		end
	end
end
