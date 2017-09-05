require 'shellwords'
require 'change_proxy/config'

module ChangeProxy
	module Hooks
		class Shell
			attr_reader :protocols

			def initialize(config)
				@protocols = Array(config.fetch('protocols', Config::DEFAULT_PROTOCOLS))
			end

			def run(location, shell)
				shell.puts "# Location: #{Shellwords.escape(location.id)}"
				shell.puts "unset no_proxy"
				shell.puts "unset proxy"
				shell.puts "unset {#{Shellwords.escape(protocols.join(','))}}_proxy"

				shell.puts "export no_proxy=#{Shellwords.escape(location.no_proxy.join(','))}" if location.no_proxy?
				shell.puts "export proxy=#{Shellwords.escape(location.proxy)}" if location.proxy?
				protocols.each do |proto|
					shell.puts "export #{proto}_proxy=#{Shellwords.escape(location.protocol_proxies[proto])}" if location.proxy?(proto)
				end
			end
		end
	end
end
