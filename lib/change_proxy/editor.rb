require 'thor/error'

module ChangeProxy
	class Editor
		attr_reader :config_klass, :file, :protocols

		def initialize(config_klass, file, protocols = %w{http https})
			raise ArgumentError, "Invalid config class provided: #{config_klass}" unless config_klass.respond_to?(:load)
			raise Thor::Error.new("Configuration file not found: #{file}") if !file || !File.exist?(file)
			raise Thor::Error.new("No protocols provided, at least one protocol required") if !protocols || protocols.empty?

			@config_klass = config_klass
			@file = file
			@protocols = protocols
		end

		def rewrite(env)
			config_klass.load(file).tap do |props|
				protocols.each do |proto|
					props.add(proto, env.proxy(proto), env.no_proxy) if env.proxy?(proto)
				end
			end
		end
	end
end
