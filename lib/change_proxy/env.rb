require 'uri'

module ChangeProxy
	class Env
		attr_reader :env, :proxies
		def initialize(env = ::ENV)
			@env = env
			@proxies = {}
		end

		def proxy(protocol = nil)
			fetch_proxy(protocol)
		end

		def proxy?(protocol = nil)

		end

		private

		def fetch_proxy(protocol)
			prefix = protocol ? "#{protocol.downcase}_" : ''
			@proxies[protocol ? protocol : :none] ||= parse_uri(env["#{prefix}proxy"] || env["#{prefix.upcase}PROXY"])
		end
	end
end
