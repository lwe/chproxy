# frozen_string_literal: true

require 'spec_helper'

require 'tempfile'
require 'chproxy/init_command'

CHPUP_PREFIX = <<-SH.freeze
  function chpup() {
    _shasum="$(command -v sha1sum || command -v shasum)"
    _before="$(env | grep -i '^[^=]*proxy=' | "$_shasum")"
    unset proxy {auto,http,https,no}_proxy
    unset PROXY {AUTO,HTTP,HTTPS,NO}_PROXY
    if [ -f "#{ENV['HOME']}/some/config/file" ]; then
      . "#{ENV['HOME']}/some/config/file" "$@"
    fi
    _after="$(env | grep -i '^[^=]*proxy=' | "$_shasum")"
    [[ "$_before" == "$_after" ]] && return 0
SH

CHPUP_SUFFIX = <<-SH.strip.freeze
  }
  chpup >/dev/null 2>&1
SH

CHPUP_BASE = <<-SH.freeze
#{CHPUP_PREFIX}
    chproxy gradle --protocols=http,https
    chproxy maven --protocols=http,https
#{CHPUP_SUFFIX}
SH

CHPUP_INTELLIJ = <<-SH.freeze
#{CHPUP_PREFIX}
    chproxy gradle --protocols=http,https
    chproxy intellij --protocols=http,https
    chproxy intellij --protocols=http,https --variant=AndroidStudio
    chproxy maven --protocols=http,https
#{CHPUP_SUFFIX}
SH

RSpec.describe Chproxy::InitCommand do
  subject { described_class.new('~/some/config/file', %w[http https], 'chproxy') }

  context 'shellcheck' do
    it 'does not find issues with shellcheck' do
      Tempfile.open('test') do |f|
        f.write subject.run('-', %w[gradle maven gradle intellij:AndroidStudio intellij])
        expect(system('shellcheck', f.path, '-s', 'bash', '-e', 'SC2120')).to be_truthy
      end
    end
  end

  context '#run' do
    it 'returns a helpful message when running without arguments' do
      expect(subject.run(nil, %w[gradle maven])).to match %r{Add the following to your ~/.(bashrc|zshrc)}
    end

    it 'builds an "evaluable" chpup function' do
      expect(subject.run('-', %w[gradle maven])).to eq described_class.undent(CHPUP_BASE)
    end

    it 'builds an "evaluable" chpup function with intellij:AndroidStudio' do
      expect(subject.run('-', %w[gradle maven gradle intellij:AndroidStudio intellij])).to eq described_class.undent(CHPUP_INTELLIJ)
    end
  end
end
