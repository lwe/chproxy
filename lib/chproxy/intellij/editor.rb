# frozen_string_literal: true

require 'thor/util'
require 'thor/error'
require 'chproxy/intellij/settings'

module Chproxy
  module IntelliJ
    # Custom Editor for IntelliJ settings, because IntelliJ only supports on/off modes.
    class Editor
      attr_reader :file

      def self.settings_root(product)
        Dir["#{Thor::Util.user_home}/Library/Preferences/#{product}*",
            "#{Thor::Util.user_home}/.#{product}*"].sort.last || "#{Thor::Util.user_home}/.#{product}2017.2"
      end

      def initialize(file)
        raise Thor::Error, "Configuration file not found: #{file}" if !file || !File.exist?(file)

        @file = file
      end

      def rewrite(env)
        Chproxy::IntelliJ::Settings.load(file).tap do |props|
          props.set(env.proxy(:http),
                    env.proxy_raw(:auto),
                    env.no_proxy)
        end
      end
    end
  end
end
