require 'rexml/document'

module ChangeProxy
	module Maven
		class Settings
			attr_reader :doc, :orig_doc_raw

			def self.load(path)
				new REXML::Document.new(File.read(path))
			end

			def initialize(doc)
				@orig_doc_raw = doc.to_s
				@doc = doc
				clean
			end

			def changed?
				to_s != orig_doc_raw
			end

			def add(protocol, proxy, no_proxy = [])
				return unless protocol
				return unless proxy

				el = proxies_el.add_element('proxy')
				el.add_element('id').tap       { |id| id.text = "chproxy-maven-#{protocol}" }
				el.add_element('active').tap   { |active| active.text = 'true' }
				el.add_element('protocol').tap { |proto| proto.text = protocol.to_s }
				el.add_element('host').tap     { |host| host.text = proxy.hostname }
				el.add_element('port').tap     { |port| port.text = proxy.port }
				if no_proxy && !no_proxy.empty?
					el.add_element('nonProxyHosts').tap { |nop| nop.text = no_proxy.join('|') }
				end
			end

			def to_s
				doc.to_s.sub(/>\s*<proxies>/m, ">\n\n<proxies>")
			end

			private

			def proxies_el
				@proxies_el ||= doc.root.add_element('proxies').tap do |el|
					doc.root.add_text("\n")
				end
			end

			def clean
				doc.elements.delete('settings/proxies')
			end
		end
	end
end
