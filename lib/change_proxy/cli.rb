require 'thor'

require 'change_proxy/version'
require 'change_proxy/config'
require 'change_proxy/hooks'

module ChangeProxy
	class CLI < Thor
		map %w[s st] => :status
		desc 'status', 'Display current proxy status'
		def status
			cfg = Config.load('spec/fixtures/chproxy.toml')
			puts cfg.active_location.id
		end

		desc "switch ...HOOKS", "Update da plugins bro"
		def switch(*hooks)
			# cfg = TOML.load_file('spec/fixtures/chproxy.toml')
			# loc = cfg['location'].map do |key, options|
			# 	ChangeProxy::Location.new(key, options)
			# end.find(&:active?)
			#
			# if hooks.include?('shell')
			# 	plugin = ChangeProxy::Plugins::Shell.new({})
			# 	plugin.shell_eval(STDOUT, loc)
			# 	puts "# Hooks: #{hooks}"
			# end
			#
			# hooks.each do |hook|
			# 	puts "ruby -Ilib ./exe/chproxy switch-#{hook}"
			# end
			switch_shell
		end

		ChangeProxy::Hooks::REGISTRY.each do |hook, clazz|
			desc "switch-#{hook}", "Switch #{hook} to current proxy configuration, based on ENV"
			define_method("switch_#{hook}") do
				cfg = Config.load('spec/fixtures/chproxy.toml')
				runner = clazz.new(cfg)
				runner.run
			end
		end

		map %w[--version -V version] => :version
		desc "--version, -V", "Print version and exit"
		def version
			puts "chproxy version #{ChangeProxy::VERSION}"
		end
	end
end
