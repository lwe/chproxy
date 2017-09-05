require 'change_proxy/hooks/shell'
require 'change_proxy/hooks/gradle'

module ChangeProxy
	module Hooks
		REGISTRY = {
			'shell' => ChangeProxy::Hooks::Shell,
			'gradle' => ChangeProxy::Hooks::Gradle
		}.freeze

		def self.exists?(hook)
			REGISTRY[hook.to_s]
		end
	end
end
