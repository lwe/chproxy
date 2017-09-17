require 'cgi'
require 'rexml/document'

module ChangeProxy
	module IntelliJ
		# Only supports HTTP protocol (!)
		class Settings
			attr_reader :doc, :orig_doc

			ENABLED = '<option name="USE_HTTP_PROXY" value="true" />'
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
			end

			def changed?
				to_s != orig_doc
			end

			def set(proxy, auto_proxy, no_proxy = [])
				@doc = TEMPLATE % [(proxy ? "\n    #{ENABLED}" : ''),
													CGI::escapeHTML(proxy ? proxy.hostname : ''),
													CGI::escapeHTML(proxy ? proxy.port.to_s : ''),
													CGI::escapeHTML(proxy ? no_proxy.join(', ') : ''),
													CGI::escapeHTML(auto_proxy ? 'true' : 'false'),
													CGI::escapeHTML(auto_proxy ? auto_proxy.to_s : '')]
			end

			def to_s
				doc
			end
		end
	end
end
