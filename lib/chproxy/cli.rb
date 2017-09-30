# frozen_string_literal: true

require 'thor'
require 'pathname'

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
      cmd = Chproxy::InitCommand.new(options['config-dir'], protocols, chproxy_cli)
      cmd.run(output, hooks)
    end

    desc 'gradle [<config>]', 'Updates the gradle proxy configuration.'
    def gradle(config = "#{Thor::Util.user_home}/.gradle/gradle.properties")
      editor = Chproxy::Editor.new(Chproxy::Gradle::Props, config, protocols)
      props = editor.rewrite(Chproxy::Env.env)
      update(props, config, label: 'gradle properties')
    end

    desc 'maven [<config>]', 'Updates the maven proxy settings.'
    def maven(config = "#{Thor::Util.user_home}/.m2/settings.xml")
      editor = Chproxy::Editor.new(Chproxy::Maven::Settings, config, protocols)
      settings = editor.rewrite(Chproxy::Env.env)
      update(settings, config, label: 'maven settings')
    end

    desc 'intellij [<config>]', 'Updates the IntelliJ (or other JetBrains products) proxy settings.'
    method_option '--intellij', aliases: '-j', banner: '<product>', default: 'IntelliJIdea',
                                desc: 'The IntelliJ product to update, one of IntelliJIdea, ' \
                                      'IdealC, RubyMine, PhpStorm, WebStorm or AndroidStudio.'
    def intellij(config = nil)
      config ||= "#{Chproxy::IntelliJ::Editor.settings_root(options['intellij'])}/options/proxy.settings.xml"
      editor = Chproxy::IntelliJ::Editor.new(config)
      settings = editor.rewrite(Chproxy::Env.env)
      update(settings, config, label: "#{options['intellij']} settings")
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

    def update(settings, output, label: 'configuration')
      if dry_run?
        puts settings.to_s
      elsif settings.changed?
        File.open(output.to_s, 'w') { |f| f.write(settings.to_s) }
        say_status 'UPDATED', "chproxy: #{label} updated (#{output})", :yellow
      else
        say_status 'SKIPPED', "chproxy: #{label} still up-to-date, nothing changed (#{output})", :green
      end
    end

    def dry_run?
      options['dry-run']
    end

    def protocols
      options['protocols'].split(/\s*[,\s]\s*/).map(&:strip).reject(&:empty?)
    end
  end
end
