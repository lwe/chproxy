# frozen_string_literal: true

require 'thor'
require 'pathname'
require 'file_utils'

require 'chproxy/env'
require 'chproxy/editor'
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
      cmd.run(output, hooks)
    end

    desc 'gradle [<config>]', 'Updates the gradle proxy configuration.'
    def gradle(config = "#{Thor::Util.user_home}/.gradle/gradle.properties")
      editor = Chproxy::Editor.new(Chproxy::Gradle::Props, config, protocols)
      props = editor.rewrite(Chproxy::Env.env)
      executor = Chproxy::Executor.rewriter(self, config,
        dry_run: dry_run?,
        label: 'gradle properties')
      executor.update(settings.to_s)
    end

    desc 'maven [<config>]', 'Updates the maven proxy settings.'
    def maven(config = "#{Thor::Util.user_home}/.m2/settings.xml")
      editor = Chproxy::Editor.new(Chproxy::Maven::Settings, config, protocols)
      settings = editor.rewrite(Chproxy::Env.env)
      executor = Chproxy::Executor.rewriter(self, config,
        dry_run: dry_run?,
        label: 'maven settings')
      executor.update(settings.to_s)
    end

    desc 'intellij', 'Updates the IntelliJ (or other JetBrains products) proxy settings.'
    method_option '--variant', aliases: '-v', banner: '<product>', default: 'IntelliJIdea',
                                desc: 'The IntelliJ product to update, one of IntelliJIdea, ' \
                                      'IdealC, RubyMine, PhpStorm, WebStorm or AndroidStudio.'
    def intellij(dir = nil)
      config = "#{Chproxy::IntelliJ::Editor.settings_file(options['intellij'])}"
      editor = Chproxy::IntelliJ::Editor.new
      settings = editor.rewrite(Chproxy::Env.env)
      executor = Chproxy::Executor.deleter(self, config,
        dry_run: dry_run?,
        label: "#{options['intellij']} settings"))
      executor.write(settings.doc)
    end

    map %w[--version -V version] => :version
    desc '--version, -V', 'Print version and exit'
    def version
      puts "chproxy version #{Chproxy::VERSION}"
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
