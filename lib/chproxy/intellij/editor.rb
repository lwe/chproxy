# frozen_string_literal: true

require 'thor/util'
require 'thor/error'
require 'chproxy/intellij/settings'

module Chproxy
  module IntelliJ
    # Custom Editor for IntelliJ settings, because IntelliJ only supports on/off modes.
    class Editor
      SETTINGS_XML = 'proxy.settings.xml'

      def self.settings_file(product)
        dir = Dir["#{Thor::Util.user_home}/Library/Preferences/#{product}*",
                  "#{Thor::Util.user_home}/.#{product}*"].sort.last

        raise Thor::Error, "No #{product} configuration directory not found." if !dir || !File.directory?(dir)

        File.join(dir, 'options', SETTINGS_XML)
      end

      def rewrite(env)
        Chproxy::IntelliJ::Settings.new.tap do |settings|
          settings.set env.proxy(:http),
                       env.proxy_raw(:auto),
                       env.no_proxy
        end
      end
    end
  end
end
