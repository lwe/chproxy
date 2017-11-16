# frozen_string_literal: true

module Chproxy
  module Npm
    # Represents a ~/.npmrc or ~/.yarnrc file to replace *proxy= settings.
    class Config
      attr_reader :lines

      def self.load(path)
        new File.readlines(path.to_s)
      end

      def initialize(lines)
        @lines = lines.reject do |l|
          l =~ /\A\s*([a-z0-9\-]+\-)?proxy\s*=/ || l.start_with?('# MARK: chproxy')
        end
      end

      def add(protocol, proxy, no_proxy = [])
        return unless protocol
        return unless proxy

        key = protocol == 'http' ? 'proxy' : "#{protocol}-proxy"

        lines << "# MARK: chproxy (automatically added by chproxy npm): BEGIN\n"
        lines << "#{key}=\"#{proxy}\"\n"
        lines << "no-proxy=\"#{no_proxy.join(',')}\"\n" if protocol == 'http' && !no_proxy.empty?
        lines << "# MARK: chproxy: END\n"
      end

      def to_s
        lines.join
      end
    end
  end
end
