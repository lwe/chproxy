# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/safe'

require 'chproxy/env'
require 'chproxy/intellij/editor'

RSpec.describe Chproxy::IntelliJ::Editor do
  subject { described_class.new }

  context '.settings_file' do
    it 'returns the default settings file for Linux' do
      FakeFS.with_fresh do
        FileUtils.mkdir_p "#{ENV['HOME']}/.IntelliJIdea3030.1/options"
        File.open("#{ENV['HOME']}/.IntelliJIdea3030.1/options/proxy.settings.xml", 'w') { |f| f.write('test') }
        expect(described_class.settings_file('IntelliJIdea')).to match %r{/\.?IntelliJIdea\d{4}\.\d/options/proxy\.settings\.xml\z}
      end
    end

    it 'returns the default settings file for macOS' do
      FakeFS.with_fresh do
        FileUtils.mkdir_p "#{ENV['HOME']}/Library/Preferences/AndroidStudio3030.1/options"
        File.open("#{ENV['HOME']}/Library/Preferences/AndroidStudio3030.1/options/proxy.settings.xml", 'w') { |f| f.write('test') }
        expect(described_class.settings_file('AndroidStudio')).to match %r{/Library/Preferences/AndroidStudio\d{4}\.\d/options/proxy\.settings\.xml\z}
      end
    end

    it 'raises a Thor::Error when the config directory does not exist' do
      expect { described_class.settings_file('NotAnIntelliJProduct') }.to raise_error(Thor::Error, /directory not found/)
      expect { described_class.settings_file(nil) }.to raise_error(Thor::Error, /directory not found/)
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
