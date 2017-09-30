# frozen_string_literal: true

require 'spec_helper'
require 'chproxy/init_command'

CHPUP_BASE = <<-SH.freeze
  function chpup() {
    unset proxy {auto,http,https,no}_proxy
    unset PROXY {AUTO,HTTP,HTTPS,NO}_PROXY
    if [ -f "#{ENV['HOME']}/some/config/file" ]; then
      . "#{ENV['HOME']}/some/config/file" $*
    fi

    chproxy gradle --protocols=http,https
    chproxy maven --protocols=http,https
  }
  chpup >/dev/null
SH

CHPUP_INTELLIJ = <<-SH.freeze
  function chpup() {
    unset proxy {auto,http,https,no}_proxy
    unset PROXY {AUTO,HTTP,HTTPS,NO}_PROXY
    if [ -f "#{ENV['HOME']}/some/config/file" ]; then
      . "#{ENV['HOME']}/some/config/file" $*
    fi

    chproxy gradle --protocols=http,https
    chproxy intellij --protocols=http,https
    chproxy intellij --protocols=http,https --intellij=AndroidStudio
    chproxy maven --protocols=http,https
  }
  chpup >/dev/null
SH

RSpec.describe Chproxy::InitCommand do
  subject { described_class.new('~/some/config/file', %w[http https], 'chproxy') }

  context '#run' do
    it 'returns a helpful message when running without arguments' do
      expect(subject).to receive(:puts).with(%r{Add the following to your ~/.(bashrc|zshrc)})
      subject.run(nil, %w[gradle maven])
    end

    it 'builds an "evaluable" chpup function' do
      expect(subject).to receive(:puts).with(described_class.undent(CHPUP_BASE))
      subject.run('-', %w[gradle maven])
    end

    it 'builds an "evaluable" chpup function with intellij:AndroidStudio' do
      expect(subject).to receive(:puts).with(described_class.undent(CHPUP_INTELLIJ))
      subject.run('-', %w[gradle maven gradle intellij:AndroidStudio intellij])
    end
  end
end
