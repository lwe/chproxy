require 'thor/error'

require 'change_proxy/gradle/props'

module ChangeProxy
	module Gradle
		class Editor
			attr_reader :props

			def initialize(file, env, protocols = %w{http https})
				raise Thor::Error.new("Gradle configuration file not found: #{file}") unless File.exist?(file)
				raise Thor::Error.new("No protocols provided, at least one protocol required") if protocols.empty?

				@props = GradleProps.load(file)
				update_props(env, protocols)
			end

			def changed?
				props.changed?
			end

			def write(io)
				io.write(props.to_s)
			end

			private

			def update_props(env, protocols)
				protocols.each do |proto|
					props.add(proto, env.proxy(proto), env.no_proxy) if env.proxy?(proto)
				end
			end
		end
	end
end
