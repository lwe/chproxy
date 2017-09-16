require 'spec_helper'
require 'change_proxy/gradle/editor'

RSpec.describe ChangeProxy::Gradle::Editor do
	subject { described_class.new('gradle_config' => 'spec/fixtures/gradle.properties', 'protocols' => %w[http rsync]) }

	context '#run' do
		it 'is skipped when gradle_config is missing' do
			expect(described_class.new('gradle_config' => 'simply/does/not/exist').run).to be_falsey
		end

		it 'adds it' do
			pp subject.run('proxy' => 'cache.example.org:3128', 'rsync_proxy' => 'rsync.example.org:1234')
		end
	end
end
