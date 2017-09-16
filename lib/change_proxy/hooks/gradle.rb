require 'pathname'
require 'uri'

module ChangeProxy
	module Hooks
		class Gradle
			attr_reader :gradle_config, :protocols

			def initialize(options = {}, env = ::ENV)
				@gradle_config = Pathname.new(options['gradle_config'] || "#{env.fetch('HOME', '~')}/.gradle/gradle.properties")
				@protocols = Array(options.fetch('protocols', %w{http https}))
			end

			def gradle_config?
				gradle_config.exist?
			end

			def run(env = ::ENV)
				return unless gradle_config?

				props = GradleProps.load(gradle_config)
				protocols.each do |proto|
					props.add proto,
						env["#{proto}_proxy"] || env['proxy'],
						env['no_proxy'].to_s.split(/\s*[,\s]\s*/)
				end

				puts props.lines.join
			end
		end

		class GradleProps
			attr_reader :lines

			def self.load(path)
				new File.readlines(path.to_s)
			end

			def initialize(lines)
				@lines = lines.reject! { |l| l =~ /\A\s*systemProp\.[a-z0-9]+\.(nonProxy|proxy)/ || l =~ /\A#\s*(BEGIN|END): chproxy/ }
			end

			def add(protocol, proxy, no_proxy = [])
				proxy = URI("http://#{proxy}") rescue nil
				return unless proxy

				lines << "\n"
				lines << "# BEGIN: chproxy (created on #{Time.now})\n"
				lines << "systemProp.#{protocol}.proxyHost=#{proxy.hostname}\n"
				lines << "systemProp.#{protocol}.proxyPort=#{proxy.port}\n"
				lines << "systemProp.#{protocol}.nonProxyHosts=#{no_proxy.join('|')}\n" unless no_proxy.empty?
				lines << "# END: chproxy\n"
			end
		end
	end
end
