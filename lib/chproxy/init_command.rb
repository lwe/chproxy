# frozen_string_literal: true

require 'shellwords'

module Chproxy
  # Provide an init system for the shell.
  class InitCommand
    EVAL = '-'

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
      puts <<~SH
        function chpup() {
          unset proxy {#{escape(all_protocols.join(','))}}_proxy
          unset PROXY {#{escape(all_protocols.join(',').upcase)}}_PROXY
          if [ -f "#{escape(config)}" ]; then
            . "#{escape(config)}" $*
          fi

          #{wrap_hooks(hooks)}
        }
        chpup >/dev/null
      SH
    end

    def wrap_hooks(hooks)
      hooks.uniq.sort.map { |h| "#{cli} #{command(*h.split(':', 2))}" }.join("\n  ")
    end

    def run_help
      puts <<~SH
        \# 1: Add the following to your #{shellrc}, this creates the chpup() function.
        \#    Check `chproxy help init` for details.
        eval "\$(#{cli} init - gradle intellij:AndroidStudio)"

        \# 2: Create a ~/.chproxy script that sets the proxy, http_proxy and other variables. Like:
        echo "proxy=example.org" > ~/.chproxy
      SH
    end

    def command(cmd, argument = nil)
      "#{escape(cmd)} --protocols=#{escape(protocols.join(','))} #{command_args(cmd, argument)}".strip
    end

    def command_args(cmd, argument)
      return "--intellij=#{escape(argument)}" if cmd == 'intellij' && argument
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

    def escape(str)
      Shellwords.escape(str)
    end
  end
end
