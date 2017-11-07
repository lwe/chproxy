# frozen_string_literal: true

require 'spec_helper'
require 'chproxy/proxy_uri'
require 'chproxy/intellij/settings'

RSpec.describe Chproxy::IntelliJ::Settings do
  subject { described_class.new }

  context '#initialize' do
    it 'cleans the proxy settings (i.e. no proxy)' do
      expect(subject.to_s).to_not include('<option name="USE_HTTP_PROXY" value="true" />')
    end
  end

  context '#set' do
    it 'sets it to an empty string when nil is passed, not even the PROXY_EXCEPTIONS' do
      subject.set(nil, nil, %w[example.org example.net])
      expect(subject.to_s).to be_empty
      expect(subject.doc).to be_nil
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
