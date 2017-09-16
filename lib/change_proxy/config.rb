require 'toml'
require 'change_proxy/location'

module ChangeProxy
	class Config
		DEFAULT_PROTOCOLS = %w{http https ftp}
		DEFAULT_TIMEOUT = 2

		attr_reader :protocols, :timeout, :color, :locations, :options

		def self.load(path)
			new(TOML.load_file(path))
		end

		def initialize(options)
			@options = options || {}

			# [core]
			core = @options['core'] || {}
			@protocols = Array(core.fetch('protocols', DEFAULT_PROTOCOLS)).map(&:to_s).map(&:downcase)
			@timeout = core.fetch('timeout', DEFAULT_TIMEOUT).to_i
			@color = core.fetch('color', 'auto')
			@term_color = `/usr/bin/env tput colors 2>/dev/null`.chomp.to_i > 1

			# [location.X]
			@locations = @options.fetch('location', {}).map do |loc, cfg|
				ChangeProxy::Location.new loc, cfg
			end
		end

		def color?
			(color == 'auto' && term_color?) || color.to_s == 'true'
		end

		def term_color?
			@term_color
		end

		def active_location
			@active ||= locations.find(&:active?) || ChangeProxy::Location::NOPROXY
		end
	end
end
