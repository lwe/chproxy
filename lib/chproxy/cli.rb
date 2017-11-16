# frozen_string_literal: true

require 'thor'
require 'pathname'

require 'chproxy/env'
require 'chproxy/editor'
require 'chproxy/executor'
require 'chproxy/init_command'

require 'chproxy/gradle/props'
require 'chproxy/maven/settings'
require 'chproxy/intellij/editor'
require 'chproxy/intellij/settings'

require 'chproxy/version'

module Chproxy
  # The `chproxy` CLI interface.
  class CLI < Thor
    class_option '--dry-run', aliases: '-n', type: :boolean,
                              desc: 'Do not change configuration, put print to STDOUT instead.'
    class_option '--protocols', aliases: '-p', type: :string, default: 'http,https',
                                desc: 'Protocols to write', banner: 'http,https'

    desc 'init [-] <...hooks>', 'Foobar'
    method_option '--config', aliases: '-c', type: :string, default: "#{Thor::Util.user_home}/.chproxy"
    def init(output = nil, *hooks)
      cmd = Chproxy::InitCommand.new(options['config'], protocols, chproxy_cli)
      puts cmd.run(output, hooks)
    end

    desc 'gradle [<config>]', 'Updates the gradle proxy configuration.'
    def gradle(config = "#{Thor::Util.user_home}/.gradle/gradle.properties")
      editor = Chproxy::Editor.new(Chproxy::Gradle::Props, config, protocols)
      executor = Chproxy::Executor.rewriter(self, config,
        dry_run: dry_run?,
        label: 'gradle properties')
      executor.update(editor.rewrite(Chproxy::Env.env))
    end

    desc 'maven [<config>]', 'Updates the maven proxy settings.'
    def maven(config = "#{Thor::Util.user_home}/.m2/settings.xml")
      editor = Chproxy::Editor.new(Chproxy::Maven::Settings, config, protocols)
      executor = Chproxy::Executor.rewriter(self, config,
        dry_run: dry_run?,
        label: 'maven settings')
      executor.update(editor.rewrite(Chproxy::Env.env))
    end

    desc 'intellij [--variant=<product>]', 'Updates the IntelliJ (or other JetBrains products) proxy settings.'
    method_option '--variant', aliases: '-v', banner: '<product>', default: 'IntelliJIdea',
                                desc: 'The JetBrains product to update, one of: IntelliJIdea, ' \
                                      'IdealC, RubyMine, PhpStorm, WebStorm or AndroidStudio.'
    def intellij
      product = options['variant']
      config = Chproxy::IntelliJ::Editor.settings_file(product)
      editor = Chproxy::IntelliJ::Editor.new
      executor = Chproxy::Executor.deleter(self, config,
        dry_run: dry_run?,
        label: "#{product} settings")
      executor.update(editor.rewrite(Chproxy::Env.env))
    end

    map %w[--version -V version] => :version
    desc '--version, -V', 'Print version and exit'
    def version
      puts "chproxy version #{Chproxy::VERSION}"
    end

    no_commands do
      def exit_on_failure?
        true
      end
    end

    private

    def chproxy_cli
      ::ENV.fetch('CHPROXY_BIN', 'chproxy')
    end

    def dry_run?
      options['dry-run']
    end

    def protocols
      options['protocols'].split(/\s*[,\s]\s*/).map(&:strip).reject(&:empty?)
    end
  end
end
