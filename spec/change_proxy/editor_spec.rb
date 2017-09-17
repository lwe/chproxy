require 'spec_helper'
require 'change_proxy/env'
require 'change_proxy/editor'

RSpec.describe ChangeProxy::Editor do
	let(:klass) do
		Class.new do
			attr_reader :file, :items

			def self.load(file); new(file) end
			def initialize(file)
				@file = file
				@items = []
			end

			def changed?
				items.length > 0
			end

			def add(proto, proxy, no_proxy)
				items << [proto.to_sym, proxy.to_s, no_proxy]
			end
		end
	end

	subject { described_class.new(klass, 'spec/fixtures/gradle.properties', %w{http}) }

	context '#initialize' do
		it 'raises ArgumentError when klass does not implement .load' do
			expect { described_class.new(nil, 'spec/fixtures/gradle.properties') }.to raise_error(ArgumentError)
			expect { described_class.new(Object, 'spec/fixtures/gradle.properties') }.to raise_error(ArgumentError)
		end

		it 'raises a Thor::Error when the file does not exist' do
			expect { described_class.new(klass, 'invalid/file') }.to raise_error(Thor::Error, /file not found/)
			expect { described_class.new(klass, nil) }.to raise_error(Thor::Error, /file not found/)
		end

		it 'raises a Thor::Error when there are no protocols' do
			expect { described_class.new(klass, 'spec/fixtures/gradle.properties', []) }.to raise_error(Thor::Error, /No protocols/)
			expect { described_class.new(klass, 'spec/fixtures/gradle.properties', nil) }.to raise_error(Thor::Error, /No protocols/)
		end
	end

	context '#rewrite' do
		let(:env) { ChangeProxy::Env.new('proxy' => 'cache:1080', 'http_proxy' => 'cache:3128', 'no_proxy' => 'example.org,example.net,example.com') }
		let(:props) { subject.rewrite(env) }

		it 'returns a <klass> instance' do
			expect(props).to be_a klass
		end

		it 'has changes' do
			expect(props.changed?).to be_truthy
		end

		it 'has the new contents' do
			expect(props.items.length).to eq 1
			expect(props.items.first).to eq [:http, "cache:3128", %w{example.org example.net example.com}]
		end
	end
end
