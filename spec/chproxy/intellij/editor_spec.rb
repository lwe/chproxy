# frozen_string_literal: true

require 'spec_helper'
require 'chproxy/env'
require 'chproxy/intellij/editor'

RSpec.describe Chproxy::IntelliJ::Editor do
  subject { described_class.new('spec/fixtures/proxy.settings.xml') }

  context '.settings_root' do
    it 'returns the default settings root for your OS by product' do
      expect(described_class.settings_root('IntelliJIdea')).to match %r{/\.?IntelliJIdea\d{4}\.\d\z}
      expect(described_class.settings_root('IdeaC')).to match %r{/\.?IdeaC\d{4}\.\d\z}
      expect(described_class.settings_root('AndroidStudio')).to match %r{/\.?AndroidStudio\d{4}}
    end
  end

  context '#initialize' do
    it 'raises a Thor::Error when the file does not exist' do
      expect { described_class.new('invalid/file') }.to raise_error(Thor::Error, /file not found/)
      expect { described_class.new(nil) }.to raise_error(Thor::Error, /file not found/)
    end
  end

  context '#rewrite' do
    let(:env) do
      Chproxy::Env.new('proxy' => 'cache:1080',
                       'http_proxy' => 'cache:3128',
                       'auto_proxy' => 'http://proxy.example.net/proxy.pac',
                       'no_proxy' => 'example.org,example.net,example.com')
    end
    let(:props) { subject.rewrite(env) }

    it 'returns a Chproxy::IntelliJ::Settings instance' do
      expect(props).to be_a Chproxy::IntelliJ::Settings
    end

    it 'has changes' do
      expect(props.changed?).to be_truthy
    end

    it 'has the new contents' do
      expect(props.to_s).to include('<option name="USE_HTTP_PROXY" value="true" />',
                                    '<option name="PROXY_HOST" value="cache" />')
    end

    it 'has PAC_URL when "auto_proxy" is present' do
      expect(props.to_s).to include('<option name="USE_PAC_URL" value="true" />')
      expect(props.to_s).to include(
        '<option name="PAC_URL" value="http://proxy.example.net/proxy.pac" />'
      )
    end
  end
end
