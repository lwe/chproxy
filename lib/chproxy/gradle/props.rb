# frozen_string_literal: true

module Chproxy
  module Gradle
    # Represents a gradle.properties file to replace systemProp.*.proxy* settings.
    class Props
      attr_reader :lines

      def self.load(path)
        new File.readlines(path.to_s)
      end

      def initialize(lines)
        @lines = lines.reject do |l|
          l =~ /\A\s*systemProp\.[a-z0-9]+\.(nonProxy|proxy)/ || l.start_with?('# MARK: chproxy')
        end
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

      def to_s
        lines.join
      end
    end
  end
end
