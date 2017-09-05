require 'pathname'

module ChangeProxy
	module Hooks
		class Gradle
			attr_reader :gradle_config

			def initialize(options = {}, env = ::ENV)
				@gradle_config = Pathname.new(options['gradle_config'] || "#{env.fetch('HOME', '~')}/.gradle/gradle.properties")
				@protocols = Array(options.fetch('protocols', %w{http https}))
			end

			def run(env = ::ENV)
				puts "HELLO WORLD"
			end
		end
	end
end
