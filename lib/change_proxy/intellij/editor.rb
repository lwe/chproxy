require 'thor/util'
require 'thor/error'
require 'change_proxy/intellij/settings'

module ChangeProxy
	module IntelliJ
		class Editor
			attr_reader :file

			def self.settings_root(product)
				Dir["#{Thor::Util.user_home}/Library/Preferences/#{product}*",
						"#{Thor::Util.user_home}/.#{product}*"].sort.last || "#{Thor::Util.user_home}/.#{product}2017.2"
			end

			def initialize(file)
				raise Thor::Error.new("Configuration file not found: #{file}") if !file || !File.exist?(file)

				@file = file
			end

			def rewrite(env)
				ChangeProxy::IntelliJ::Settings.load(file).tap do |props|
					props.set(
						env.proxy(:http),
						env.proxy?(:auto) ? env.proxy(:auto) : nil,
						env.no_proxy)
				end
			end
		end
	end
end
