# frozen_string_literal: true

require 'rexml/document'

module Chproxy
  module Maven
    # Represents a Maven (2.x) settings.xml.
    class Settings
      attr_reader :doc, :orig_doc_raw

      def self.load(path)
        new REXML::Document.new(File.read(path))
      end

      def initialize(doc)
        @orig_doc_raw = doc.to_s
        @doc = doc
        @doc.elements.delete('settings/proxies')
      end

      def changed?
        to_s != orig_doc_raw
      end

      def add(protocol, proxy, no_proxy = [])
        raise ArgumentError, 'missing protocol' if protocol.to_s.strip.empty?
        return unless proxy

        el = proxies_el.add_element('proxy')
        add_id       el, protocol
        add_status   el, proxy
        add_protocol el, protocol
        add_proxy    el, proxy
        add_no_proxy el, no_proxy
      end

      def to_s
        doc.to_s.sub(/>\s*<proxies>/m, ">\n\n<proxies>")
      end

      private

      def add_id(el, protocol)
        el.add_element('id').tap { |id| id.text = "chproxy-maven-#{protocol}" }
      end

      def add_status(el, active)
        el.add_element('active').tap { |st| st.text = active ? 'true' : 'false' }
      end

      def add_protocol(el, protocol)
        el.add_element('protocol').tap { |proto| proto.text = protocol.to_s }
      end

      def add_proxy(el, proxy)
        el.add_element('host').tap { |host| host.text = proxy.hostname }
        el.add_element('port').tap { |port| port.text = proxy.port }
      end

      def add_no_proxy(el, no_proxy)
        return if !no_proxy || no_proxy.empty?
        el.add_element('nonProxyHosts').tap { |nop| nop.text = no_proxy.join('|') }
      end

      def proxies_el
        @proxies_el ||= doc.root.add_element('proxies').tap { doc.root.add_text("\n") }
      end
    end
  end
end
