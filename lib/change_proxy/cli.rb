require 'thor'

require 'change_proxy/version'
require 'change_proxy/config'
require 'change_proxy/hooks'

require 'change_proxy/cmds/locations'

module ChangeProxy
	class CLI < Thor
		map %w[s st] => :status
		desc 'status', 'Display current proxy status'
		def status
			cfg = Config.load('spec/fixtures/chproxy.toml')
			puts cfg.active_location.id
		end

		include ChangeProxy::Cmds::Locations

		desc "switch ...HOOKS", "Update da plugins bro"
		def switch(*hooks)
			cfg = Config.load('spec/fixtures/chproxy.toml')
			shell = ChangeProxy::Hooks::Shell.new(cfg)
			shell.run

			unless hooks.empty?
				puts ""
				puts "# Hooks"
				hooks.each do |hook|
					if Hooks::REGISTRY[hook]
						puts "#{$0} hook-#{hook}"
					else
						puts "chproxy-hook-#{hook}"
					end
				end
			end
		end

		ChangeProxy::Hooks::REGISTRY.each do |hook, clazz|
			desc "hook-#{hook}", "Switch #{hook} to current proxy configuration, based on ENV", hide: true
			define_method("hook_#{hook}") do
				cfg = Config.load('spec/fixtures/chproxy.toml')
				runner = clazz.new(cfg.options[hook])
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
