# frozen_string_literal: true

require 'shellwords'

module Chproxy
  # Provide an init system for the shell.
  class InitCommand
    EVAL = '-'

    attr_reader :config, :protocols, :cli

    def initialize(config, protocols = [], cli = 'chproxy')
      @config = config
      @protocols = protocols.map(&:downcase).uniq
      @cli = cli
    end

    def run(output, hooks)
      return run_eval(hooks) if output == EVAL
      run_help
    end

    private

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def run_eval(hooks)
      puts <<~SH
        function chpup() {
          unset proxy {#{escape(all_protocols.join(','))}}_proxy
          unset PROXY {#{escape(all_protocols.join(',').upcase)}}_PROXY
          if [ -f "#{escape(config)}" ]; then
            . "#{escape(config)}" $*
          fi

          #{wrap_hooks(hooks)}
          echo "⚠️ Run in all open shells to update the ENV proxy vars properly."
        }
        chpup >/dev/null
      SH
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def wrap_hooks(hooks)
      protos = protocols.join(',')
      hooks.map { |h| "#{cli} #{escape(h)} --protocols=#{escape(protos)}" }.join("\n  ")
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

    def all_protocols
      (protocols + %w[auto no]).uniq
    end

    def proxy_files
      Dir["#{dir}/proxy-*"].sort
    end

    def post_files
      Dir["#{dir}/post-*"].sort
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
