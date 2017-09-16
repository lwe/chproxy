module ChangeProxy
	module Cmds
		module Locations
			def self.included(thor)
				thor.class_eval do
					map %w[ls list] => :locations
					desc 'locations', 'List available and configured locations'
					def locations
						cfg = Config.load('spec/fixtures/chproxy.toml')
						(cfg.locations + [Location::NOPROXY]).each do |location|
							active = location == cfg.active_location
							message = "%s %s" % [location == cfg.active_location ? '*' : ' ', location.id]
							say message, cfg.color? && active ? :green : :clear
						end
					end
				end
			end
		end
	end
end
