require 'change_proxy/test'

module ChangeProxy
	class Location
		attr_reader :id, :test, :proxy, :no_proxy, :proxy_pac, :protocol_proxies

		def initialize(id, options = {})
			raise ArgumentError, "missing id" if id.empty?
			@id = id
			@test = ChangeProxy::Test.factory(options.fetch('test', true))
			@proxy = options.fetch('proxy', nil)
			@no_proxy = Array(options.fetch('no_proxy', nil))
			@proxy_pac = options.fetch('proxy_pac', nil)
			@protocol_proxies = {}
			options.keys.select { |k| k =~ /\A.+_proxy\z/ }.each { |key|
				@protocol_proxies[key.sub(/_proxy\z/, '')] = options[key] unless key == 'no_proxy'
			}
		end

		def active?
			test.active?
		end

		def no_proxy?
			!no_proxy.empty?
		end

		def proxy?(protocol = nil)
			return proxy unless protocol
			protocol_proxies[protocol]
		end
	end
end

ChangeProxy::Location::NOPROXY = ChangeProxy::Location.new('(direct)', 'test' => true)
