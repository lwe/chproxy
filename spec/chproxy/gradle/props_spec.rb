# frozen_string_literal: true

require 'spec_helper'
require 'chproxy/proxy_uri'
require 'chproxy/gradle/props'

RSpec.describe Chproxy::Gradle::Props do
  let(:lines) { File.readlines('spec/fixtures/gradle.properties') }

  subject { described_class.new(lines) }

  context '.load' do
    subject { described_class.load('spec/fixtures/gradle.properties') }

    it 'returns a Gradle::Props instance' do
      expect(subject).to be_a described_class
    end

    it 'loads the file' do
      expect(subject.lines).to_not be_empty
    end
  end

  context '#initialize' do
    it 'removes all occurences of systemProp.*.proxy, nonProxy and MARK: chproxy' do
      expect(subject.lines).to eq [
        "#org.gradle.java.home=/Library/Java/Home\n",
        "org.gradle.java.home=/Library/Java/JavaVirtualMachines/jdk1.8.0_141.jdk/Contents/Home\n",
        "\n",
        "#systemProp.http.nonProxyHosts=localhost|127.0.0.1|example.org\n",
        "\n",
        "systemProp.https.someSslSetting=foobar\n",
        "\n",
        "some.other.property=true\n"
      ]
    end
  end

  context '#changed?' do
    subject { described_class.new(["my.property=foo\n"]) }

    it 'returns falsey if there are no changes (compared to the original)' do
      expect(subject.changed?).to be_falsey
    end

    it 'returns truthy if there are differences' do
      subject.add 'http', URI.parse('proxy.example.org:3128')
      expect(subject.changed?).to be_truthy
    end
  end

  context '#add' do
    it 'skips it when proxy is nil' do
      subject.add 'http', nil
      expect(subject.lines).to_not include(/\AsystemProp\..*\.proxyHost/)
    end

    it 'appends a proxy entry to the existing config file' do
      subject.add 'http', Chproxy::ProxyURI.parse('proxy.example.org:3128')
      expect(subject.lines).to include("systemProp.http.proxyHost=proxy.example.org\n",
                                       "systemProp.http.proxyPort=3128\n")
    end

    it 'appends a proxy entry with nonProxy hosts' do
      subject.add 'https',
                  Chproxy::ProxyURI.parse('proxy.example.org:3128'),
                  %w[localhost example.org]
      expect(subject.lines).to include("systemProp.https.proxyHost=proxy.example.org\n",
                                       "systemProp.https.proxyPort=3128\n",
                                       "systemProp.https.nonProxyHosts=localhost|example.org\n")
    end

    it 'wraps the added proxy in a BEGIN/END comment' do
      subject.add 'http', Chproxy::ProxyURI.parse('proxy.example.org:3128')
      expect(subject.lines).to include(/# MARK: chproxy \(auto.+\): BEGIN\n\z/,
                                       /# MARK: chproxy.*: END\n\z/)
    end
  end
end
