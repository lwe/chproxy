require 'thor'
require 'pathname'

require 'change_proxy/version'
require 'change_proxy/env'
require 'change_proxy/gradle/editor'

module ChangeProxy
	class CLI < Thor
		desc 'gradle [<config>]', 'Updates the gradle proxy configuration.'
		long_desc <<-DESC.gsub("\n", "\x5").strip
Updates the gradle.properties file with the right systemProps for setting the
proxy configuration, based on the current environment. When no <config> is
passed it uses the default gradle configuration file from:

	#{Thor::Util.user_home}/.gradle/gradle.properties

DESC
		method_option '--dry-run', aliases: '-n', type: :boolean, desc: 'Do not change configuration file, put print to STDOUT instead.'
		method_option '--protocols', aliases: '-p', type: :string, default: 'http,https', desc: 'Protocols to write', banner: 'http,https'
		def gradle(config = "#{Thor::Util.user_home}/.gradle/gradle.properties")
			editor = ChangeProxy::Gradle::Editor.new(
				config,
				options['protocols'].split(/\s*[,\s]\s*/).map(&:strip).reject(&:empty?))

			props = editor.rewrite(ChangeProxy::Env.env)

			if options['dry-run']
				puts props
			elsif props.changed?
				File.open(config, 'w') { |f| f.write(props) }
				say_status 'UPDATED', "chproxy: gradle config updated (#{config})", :yellow
			else
				say_status 'SKIPPED', "chproxy: gradle config still up-to-date (#{config})", :green
			end
		end

		map %w[--version -V version] => :version
		desc "--version, -V", "Print version and exit"
		def version
			puts "chproxy version #{ChangeProxy::VERSION}"
		end
	end
end
