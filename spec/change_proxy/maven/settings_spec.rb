require 'spec_helper'
require 'change_proxy/proxy_uri'
require 'change_proxy/maven/settings'

RSpec.describe ChangeProxy::Maven::Settings do
	it 'does smth' do
		settings = described_class.load('spec/fixtures/settings.xml')
		settings.add 'http', ChangeProxy::ProxyURI.parse('proxy.example.org:3128')
		settings.add 'https', ChangeProxy::ProxyURI.parse('proxy.example.org:3128'), %w{example.org example.net}
		puts settings.doc.to_s
		puts settings.changed?
	end
end
