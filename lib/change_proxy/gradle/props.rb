module ChangeProxy
	module Gradle
		class Props
			attr_reader :lines, :orig_lines

			def self.load(path)
				new File.readlines(path.to_s)
			end

			def initialize(lines)
				@orig_lines = lines.dup
				@lines = lines.reject { |l| l =~ /\A\s*systemProp\.[a-z0-9]+\.(nonProxy|proxy)/ || l =~ /\A# MARK: chproxy/ }
			end

			def add(protocol, proxy, no_proxy = [])
				return unless protocol
				return unless proxy

				lines << "# MARK: chproxy (automatically added by chproxy gradle): BEGIN\n"
				lines << "systemProp.#{protocol}.proxyHost=#{proxy.hostname}\n"
				lines << "systemProp.#{protocol}.proxyPort=#{proxy.port}\n"
				lines << "systemProp.#{protocol}.nonProxyHosts=#{no_proxy.join('|')}\n" unless no_proxy.empty?
				lines << "# MARK: chproxy: END\n"
			end

			def changed?
				lines != orig_lines
			end

			def to_s
				lines.join
			end
		end
	end
end
