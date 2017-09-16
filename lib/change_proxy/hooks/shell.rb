require 'shellwords'
require 'change_proxy/config'

module ChangeProxy
	module Hooks
		class Shell
			attr_reader :config

			def initialize(config)
				@config = config
			end

			def run
				location = config.active_location
				puts "# Location: #{Shellwords.escape(location.id)}"
				puts "unset no_proxy"
				puts "unset proxy"
				puts "unset {#{Shellwords.escape(config.protocols.join(','))}}_proxy"

				puts "export no_proxy=#{Shellwords.escape(location.no_proxy.join(','))}" if location.no_proxy?
				puts "export proxy=#{Shellwords.escape(location.proxy)}" if location.proxy?
				config.protocols.each do |proto|
					puts "export #{proto}_proxy=#{Shellwords.escape(location.protocol_proxies[proto])}" if location.proxy?(proto)
				end
			end
		end
	end
end
