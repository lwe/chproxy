require 'thor/error'

require 'change_proxy/maven/settings'

module ChangeProxy
	module Maven
		class Editor
			attr_reader :file, :protocols

			def initialize(file, protocols = %w{http https})
				raise Thor::Error.new("Maven settings file not found: #{file}") if !file || !File.exist?(file)
				raise Thor::Error.new("No protocols provided, at least one protocol required") if !protocols || protocols.empty?

				@file = file
				@protocols = protocols
			end

			def rewrite(env)
				Settings.load(file).tap do |props|
					protocols.each do |proto|
						props.add(proto, env.proxy(proto), env.no_proxy) if env.proxy?(proto)
					end
				end
			end
		end
	end
end
