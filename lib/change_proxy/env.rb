# frozen_string_literal: true
require 'change_proxy/proxy_uri'

module ChangeProxy
	class Env
		PROXY = 'proxy'
		NO_PROXY = 'no_proxy'

		def self.env
			new ::ENV
		end

		attr_reader :env
		def initialize(env)
			@env = env
			@proxies = {}
		end

		def proxy(protocol = nil)
			protocol && fetch_proxy(protocol) || fetch_proxy(nil)
		end

		def proxy_raw(protocol = nil)
			fetch_proxy(protocol)
		end

		def proxy?(protocol = nil)
			fetch_proxy(nil) && fetch_proxy(protocol)
		end

		def no_proxy
			@no_proxy ||= parse_no_proxy(env[NO_PROXY] || env[NO_PROXY.upcase])
		end

		private

		def fetch_proxy(protocol)
			key = protocol ? protocol.to_s.downcase.to_sym : :none
			prefix = protocol ? "#{protocol.to_s.downcase}_" : ''
			@proxies[key] ||= ProxyURI.parse(env["#{prefix}#{PROXY}"] || env["#{prefix.upcase}#{PROXY.upcase}"])
		end

		def parse_no_proxy(str)
			str.to_s.strip.    # 1) ensure a string
				split(',').      # 2) split by ,
				map(&:strip).    # 3) strip trailing / leading whitespace
				reject(&:empty?) # 4) remove empty entries
		end
	end
end
