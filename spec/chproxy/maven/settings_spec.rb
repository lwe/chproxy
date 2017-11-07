# frozen_string_literal: true

require 'spec_helper'
require 'chproxy/proxy_uri'
require 'chproxy/maven/settings'

RSpec.describe Chproxy::Maven::Settings do
  let(:doc) { REXML::Document.new(File.read('spec/fixtures/settings.xml')) }
  let(:doc_chproxied) { REXML::Document.new(File.read('spec/fixtures/settings-chproxied.xml')) }
  subject { described_class.new(doc) }

  context '.load' do
    it 'returns a Maven::Settings instance' do
      expect(described_class.load('spec/fixtures/settings.xml')).to be_a described_class
    end

    it 'loads the XML doc' do
      expect(described_class.load('spec/fixtures/settings.xml').doc).to be_a REXML::Document
      expect(described_class.load('spec/fixtures/settings.xml').doc.to_s).to include(
        '<settings>',
        '<things/>',
        '</settings>'
      )
    end
  end

  context '#initialize' do
    it 'purges the <proxies> section' do
      expect(subject.to_s).to_not include('<proxies>', '<proxy>')
    end
  end

  context '#add' do
    it 'raises error when protocol is empty' do
      expect { subject.add(nil, nil) }.to raise_error(ArgumentError, /missing/)
      expect { subject.add('', nil) }.to raise_error(ArgumentError, /missing/)
    end

    it 'does nothing if proxy is empty' do
      subject.add :http, nil
      expect(subject.to_s).to_not include('<proxy>')
    end

    context 'with :http proxy added' do
      before do
        subject.add(:http, Chproxy::ProxyURI.parse('cache:3128'), %w[example.org example.net])
      end

      it 'adds <proxies> with correct <proxy> section' do
        expect(subject.to_s).to include('<proxies><proxy><id>chproxy-maven-http</id>' \
          '<active>true</active><protocol>http</protocol><host>cache</host><port>3128</port>' \
          '<nonProxyHosts>example.org|example.net</nonProxyHosts></proxy></proxies>')
      end

      it 'appends to <proxies> when already present' do
        subject.add(:https, Chproxy::ProxyURI.parse('cache:3128'))
        expect(subject.doc.get_elements('//proxies').size).to eq 1
        expect(subject.to_s).to include('<proxies><proxy><id>chproxy-maven-http</id>' \
          '<active>true</active><protocol>http</protocol><host>cache</host><port>3128</port>' \
          '<nonProxyHosts>example.org|example.net</nonProxyHosts></proxy>' \
          '<proxy><id>chproxy-maven-https</id><active>true</active><protocol>https</protocol>' \
          '<host>cache</host><port>3128</port></proxy></proxies>')
      end
    end
  end
end
