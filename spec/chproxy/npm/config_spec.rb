# frozen_string_literal: true

require 'spec_helper'
require 'chproxy/proxy_uri'
require 'chproxy/npm/config'

RSpec.describe Chproxy::Npm::Config do
  let(:lines) { File.readlines('spec/fixtures/npmrc') }

  subject { described_class.new(lines) }

  context '.load' do
    subject { described_class.load('spec/fixtures/npmrc') }

    it 'returns a Gradle::Config instance' do
      expect(subject).to be_a described_class
    end

    it 'loads the file' do
      expect(subject.lines).to_not be_empty
    end
  end

  context '#initialize' do
    it 'removes all occurences of proxy, *-proxy and MARK: chproxy' do
      expect(subject.lines).to eq [
        "# proxy=didum\n",
        "color=true\n",
        "ca[]=\"pem\"\n",
        "otp=1234\n",
        "\n",
        "\n"
      ]
    end
  end

  context '#add' do
    it 'skips it when proxy is nil' do
      subject.add 'http', nil
      expect(subject.lines).to_not include(/\Aproxy=/)
    end

    it 'wraps the added proxy in a BEGIN/END comment' do
      subject.add 'http', Chproxy::ProxyURI.parse('proxy.example.org:3128')
      expect(subject.lines).to include(/# MARK: chproxy \(auto.+\): BEGIN\n\z/,
                                       /# MARK: chproxy.*: END\n\z/)
    end

    it 'appends a proxy= entry, including no-proxy' do
      subject.add 'http',
                  Chproxy::ProxyURI.parse('proxy.example.org:3128'),
                  %w[localhost example.org]
      expect(subject.lines).to include("proxy=\"proxy.example.org:3128\"\n",
                                       "no-proxy=\"localhost,example.org\"\n")
    end

    it 'appends a https-proxy= entry (no-proxy is ignored)' do
      subject.add 'https',
                  Chproxy::ProxyURI.parse('proxy.example.org:3128'),
                  %w[localhost example.org]
      expect(subject.lines).to include("https-proxy=\"proxy.example.org:3128\"\n")
      expect(subject.lines).to_not include('no-proxy=')
    end
  end
end
