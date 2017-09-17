# frozen_string_literal: true

require 'spec_helper'
require 'chproxy/proxy_uri'
require 'chproxy/intellij/settings'

RSpec.describe Chproxy::IntelliJ::Settings do
  let(:settings) { File.read('spec/fixtures/proxy.settings.xml') }
  subject { described_class.new(settings) }

  context '.load' do
    subject { described_class.load('spec/fixtures/proxy.settings.xml') }

    it 'returns a IntelliJ::Settings instance' do
      expect(subject).to be_a described_class
    end

    it 'loads the file (as #orig_doc)' do
      expect(subject.orig_doc).to_not be_empty
    end
  end

  context '#initialize' do
    it 'cleans the proxy settings (i.e. no proxy)' do
      expect(subject.to_s).to_not include('<option name="USE_HTTP_PROXY" value="true" />')
    end
  end

  context '#changed?' do
    it 'is truthy, because it was cleaned' do
      expect(subject.changed?).to be_truthy
    end
  end

  context '#set' do
    it 'sets it to no proxy when nil is passed, not even the PROXY_EXCEPTIONS' do
      subject.set(nil, nil, %w[example.org example.net])
      expect(subject.to_s).to_not include('<option name="USE_HTTP_PROXY" value="true" />')
      expect(subject.to_s).to include('<option name="PROXY_HOST" value="" />')
      expect(subject.to_s).to include('<option name="PROXY_PORT" value="" />')
      expect(subject.to_s).to include('<option name="USE_PAC_URL" value="false" />')
    end

    it 'sets the http proxy settings' do
      subject.set(Chproxy::ProxyURI.parse('cache:3128'), nil, %w[example.org example.net])
      expect(subject.to_s).to include('<option name="USE_HTTP_PROXY" value="true" />')
      expect(subject.to_s).to include('<option name="PROXY_HOST" value="cache" />')
      expect(subject.to_s).to include('<option name="PROXY_PORT" value="3128" />')
      expect(subject.to_s).to include(
        '<option name="PROXY_EXCEPTIONS" value="example.org, example.net" />'
      )
      expect(subject.to_s).to include('<option name="USE_PAC_URL" value="false" />')
    end

    it 'sets proxy pac settings when present' do
      subject.set(Chproxy::ProxyURI.parse('cache:3128'),
                  Chproxy::ProxyURI.parse('http://proxy.example.net/proxy.pac'), %w[example.org])
      expect(subject.to_s).to include('<option name="USE_HTTP_PROXY" value="true" />')
      expect(subject.to_s).to include('<option name="PROXY_HOST" value="cache" />')
      expect(subject.to_s).to include('<option name="PROXY_PORT" value="3128" />')
      expect(subject.to_s).to include('<option name="PROXY_EXCEPTIONS" value="example.org" />')
      expect(subject.to_s).to include('<option name="USE_PAC_URL" value="true" />')
      expect(subject.to_s).to include(
        '<option name="PAC_URL" value="http://proxy.example.net/proxy.pac" />'
      )
    end
  end
end
