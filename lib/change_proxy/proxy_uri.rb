require 'uri'

module ChangeProxy
	class ProxyURI
		attr_reader :uri

		def self.parse(uri)
			return nil if uri.to_s.strip.empty?
			new(uri.to_s.strip)
		end

		def initialize(uri)
			@uri = URI.parse(uri)
		end

		def scheme
			return nil unless uri.hostname
			uri.scheme
		end

		def hostname
			uri.hostname || uri.to_s.split(':').first
		end

		def port
			uri.port || uri.to_s.split(':').last.to_i
		end

		def ==(other)
			other.class == self.class && other.uri == self.uri
		end

		def to_s
			uri.to_s
		end
	end
end
