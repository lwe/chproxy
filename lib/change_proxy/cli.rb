require 'thor'
require 'pathname'

require 'change_proxy/env'
require 'change_proxy/editor'

require 'change_proxy/gradle/props'
require 'change_proxy/maven/settings'
require 'change_proxy/intellij/editor'
require 'change_proxy/intellij/settings'

require 'change_proxy/version'

module ChangeProxy
	class CLI < Thor

		class_option '--dry-run', aliases: '-n', type: :boolean, desc: 'Do not change configuration, put print to STDOUT instead.'

		desc 'gradle [<config>]', 'Updates the gradle proxy configuration.'
		long_desc <<-DESC.gsub("\n", "\x5").strip
Updates the gradle.properties file with the right systemProps for setting the
proxy configuration, based on the current environment. When no <config> is
passed it uses the default gradle configuration file from:

	#{Thor::Util.user_home}/.gradle/gradle.properties

DESC
		method_option '--protocols', aliases: '-p', type: :string, default: 'http,https', desc: 'Protocols to write', banner: 'http,https'
		def gradle(config = "#{Thor::Util.user_home}/.gradle/gradle.properties")
			editor = ChangeProxy::Editor.new(ChangeProxy::Gradle::Props, config, protocols)
			props = editor.rewrite(ChangeProxy::Env.env)
			update(props, config, label: "gradle properties")
		end

		desc 'maven [<config>]', 'Updates the maven proxy settings.'
		method_option '--protocols', aliases: '-p', type: :string, default: 'http,https', desc: 'Protocols to write', banner: 'http,https'
		def maven(config = "#{Thor::Util.user_home}/.m2/settings.xml")
			editor = ChangeProxy::Editor.new(ChangeProxy::Maven::Settings, config, protocols)
			settings = editor.rewrite(ChangeProxy::Env.env)
			update(settings, config, label: "maven settings")
		end

		desc 'intellij [<config>]', 'Updates the IntelliJ (or other JetBrains products) proxy settings.'
		method_option '--intellij', aliases: '-j', banner: '<product>', default: 'IntelliJIdea', desc: 'The IntelliJ product to update, one of IntelliJIdea, IdealC, RubyMine, PhpStorm, WebStorm or AndroidStudio.'
		def intellij(config = nil)
			config ||= "#{ChangeProxy::IntelliJ::Editor.settings_root(options['intellij'])}/options/proxy.settings.xml"
			editor = ChangeProxy::IntelliJ::Editor.new(config)
			settings = editor.rewrite(ChangeProxy::Env.env)
			update(settings, config, label: "#{options['intellij']} settings")
		end

		map %w[--version -V version] => :version
		desc "--version, -V", "Print version and exit"
		def version
			puts "chproxy version #{ChangeProxy::VERSION}"
		end

		private

		def update(settings, output, label: 'configuration')
			if dry_run?
				puts settings.to_s
				settings.changed?
			elsif settings.changed?
				File.open(output.to_s, 'w') { |f| f.write(settings.to_s) }
				say_status 'UPDATED', "chproxy: #{label} updated (#{output})", :yellow
				true
			else
				say_status 'SKIPPED', "chproxy: #{label} still up-to-date, nothing changed (#{output})", :green
				false
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
