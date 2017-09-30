# frozen_string_literal: true

require 'cgi'

require 'chproxy/proxy_uri'

module Chproxy
  module IntelliJ
    # Represents an IntelliJ (or AndroidStudio et all) proxy.settings.xml file. Only has two modes:
    # enabled / disbaled.
    #
    # NOTE: Currently only supports HTTP proxies and PAC URL, SOCKS proxies are not supported, yet.
    class Settings
      attr_reader :doc, :orig_doc

      ENABLED = '<option name="USE_HTTP_PROXY" value="true" />'.freeze
      TEMPLATE = <<-XML.strip
        <application>
          <component name="HttpConfigurable">%s
            <option name="PROXY_HOST" value="%s" />
            <option name="PROXY_PORT" value="%s" />
            <option name="PROXY_EXCEPTIONS" value="%s" />
            <option name="USE_PAC_URL" value="%s" />
            <option name="PAC_URL" value="%s" />
          </component>
        </application>
      XML

      def self.load(path)
        new File.read(path)
      end

      def initialize(doc)
        @orig_doc = doc
        set(nil, nil, [])
      end

      def changed?
        to_s != orig_doc
      end

      def set(proxy, auto_proxy, no_proxy = [])
        proxy ||= Chproxy::ProxyURI::NONE
        auto_proxy ||= Chproxy::ProxyURI::NONE
        @doc = format TEMPLATE, enabled_tag(proxy).to_s,
                      CGI.escapeHTML(proxy.hostname.to_s),
                      CGI.escapeHTML(proxy.port.to_s),
                      CGI.escapeHTML(no_proxy(proxy, no_proxy).to_s),
                      CGI.escapeHTML(auto_proxy.empty? ? 'false' : 'true'),
                      CGI.escapeHTML(auto_proxy.to_s)
      end

      def to_s
        doc
      end

      private

      def enabled_tag(proxy)
        "\n    #{ENABLED}" unless proxy.empty?
      end

      def no_proxy(proxy, no_proxy)
        no_proxy.join(', ') unless proxy.empty?
      end
    end
  end
end
