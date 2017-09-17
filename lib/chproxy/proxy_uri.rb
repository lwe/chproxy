# frozen_string_literal: true

require 'uri'

module Chproxy
  # Represents a proxy URI, backed by URI. Supports the following formats:
  #
  # * `proxy:3128`, a "generic" proxy (no protocol or anything)
  # * `http://proxy:3128`, HTTP proxy
  # * `socks5://proxy:1234`, socks proxy
  # * `http://proxy/proxy.pac`, a PAC url
  #
  # The interface exposed is similar to URI, actually a subset of URI.
  class ProxyURI
    attr_reader :uri

    def self.parse(uri)
      return nil if uri.to_s.strip.empty?
      new(uri)
    end

    def initialize(uri)
      @uri = URI.parse(uri.to_s.strip)
    end

    def scheme
      return nil unless uri.hostname
      uri.scheme
    end

    def hostname
      uri.hostname || uri.to_s.split(':').first
    end

    def port
      port = uri.port || uri.to_s.split(':').last
      return port.to_i if port
    end

    def ==(other)
      other.class == self.class && other.uri == uri
    end

    def empty?
      uri.to_s.empty?
    end

    def to_s
      uri.to_s
    end

    # Representation of an "empty" or "none" ProxyURI.
    NONE = new('')
  end
end
