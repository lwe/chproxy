# frozen_string_literal: true

require 'shellwords'

module Chproxy
  # Provide an init system for the shell.
  class InitCommand
    EVAL = '-'.freeze

    def self.escape(str)
      Shellwords.escape(str)
    end

    def self.undent(str)
      str.gsub(/^[ \t]{#{(str.slice(/^[ \t]+/) || '').length}}/, '')
    end

    attr_reader :config, :protocols, :cli

    def initialize(config, protocols = [], cli = 'chproxy')
      @config = File.expand_path(config)
      @protocols = protocols.map(&:downcase).uniq
      @cli = cli
    end

    def run(output, hooks)
      return run_eval(hooks) if output == EVAL
      run_help
    end

    private

    def run_eval(hooks)
      sh = <<-SH
        function chpup() {
          _shasum="$(command -v sha1sum || command -v shasum)"
          _before="$(env | grep -i '^[^=]*proxy=' | "$_shasum")"
          unset proxy {#{self.class.escape(all_protocols.join(','))}}_proxy
          unset PROXY {#{self.class.escape(all_protocols.join(',').upcase)}}_PROXY
          if [ -f "#{self.class.escape(config)}" ]; then
            . "#{self.class.escape(config)}" "$@"
          fi
          _after="$(env | grep -i '^[^=]*proxy=' | "$_shasum")"
          [[ "$_before" == "$_after" ]] && return 0

          #{wrap_hooks(hooks)}
        }
        chpup >/dev/null 2>&1
      SH
      self.class.undent(sh)
    end

    def wrap_hooks(hooks)
      hooks.uniq.sort.map { |h| "#{cli} #{command(*h.split(':', 2))}" }.join("\n  ")
    end

    def run_help
      sh = <<-SH
        \# 1: Add the following to your #{shellrc}, this creates the chpup() function.
        \#    Check `chproxy help init` for details.
        eval "\$(#{cli} init - gradle intellij:AndroidStudio)"

        \# 2: Create a ~/.chproxy script that sets the proxy, http_proxy and other variables. Like:
        echo "export proxy=example.org" > ~/.chproxy
      SH
      self.class.undent(sh)
    end

    def command(cmd, argument = nil)
      protos = self.class.escape(protocols.join(','))
      "#{self.class.escape(cmd)} --protocols=#{protos} #{command_args(cmd, argument)}".strip
    end

    def command_args(cmd, argument)
      return "--variant=#{self.class.escape(argument)}" if cmd == 'intellij' && argument
    end

    def all_protocols
      (protocols + %w[auto no]).uniq.sort
    end

    def shellrc
      case ::ENV['SHELL']
      when /zsh/ then '~/.zshrc'
      else '~/.bashrc'
      end
    end
  end
end
