require 'spec_helper'
require 'change_proxy/hooks/gradle'
require 'pp'

RSpec.describe ChangeProxy::Hooks::Gradle do
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

RSpec.describe ChangeProxy::Hooks::GradleProps do
	let(:lines) { File.readlines('spec/fixtures/gradle.properties') }
	subject { described_class.new(lines) }

	context '.load' do
		subject { described_class.load('spec/fixtures/gradle.properties') }

		it 'returns a GradleProps instance' do
			expect(subject).to be_a described_class
		end

		it 'loads the file' do
			expect(subject.lines).to_not be_empty
		end
	end

	context '#initialize' do
		it 'removes all occurences of systemProp.*.proxy and nonProxy' do
			expect(subject.lines).to eq ["#org.gradle.java.home=/Library/Java/Home\n",
 				"org.gradle.java.home=/Library/Java/JavaVirtualMachines/jdk1.8.0_141.jdk/Contents/Home\n",
				"\n",
 				"#systemProp.http.nonProxyHosts=localhost|127.0.0.1|example.org\n",
				"\n",
 				"systemProp.https.someSslSetting=foobar\n",
 				"\n",
 				"some.other.property=true\n"]
		end
	end

	context '#add' do
		it 'skips it when proxy is nil or empty' do
			subject.add 'http', nil
			subject.add 'http', ''
			expect(subject.lines).to_not include(/\AsystemProp\..*\.proxyHost/)
		end

		it 'appends a proxy entry to the existing config file' do
			subject.add 'http', 'proxy.example.org:3128'
			expect(subject.lines).to include("systemProp.http.proxyHost=proxy.example.org\n", "systemProp.http.proxyPort=3128\n")
		end

		it 'appends a proxy entry with nonProxy hosts' do
			subject.add 'https', 'proxy.example.org:3128', %w[localhost example.org]
			expect(subject.lines).to include("systemProp.https.proxyHost=proxy.example.org\n",
				"systemProp.https.proxyPort=3128\n",
				"systemProp.https.nonProxyHosts=localhost|example.org\n")
		end

		it 'wraps the added proxy in a BEGIN/END comment' do
			subject.add 'http', 'proxy.example.org:3128'
			expect(subject.lines).to include(/# BEGIN: chproxy \(created on .+\)/, "# END: chproxy\n")
		end
	end
end
