require 'spec_helper'
require 'change_proxy/proxy_uri'

RSpec.describe ChangeProxy::ProxyURI do
	context '.parse' do
		it 'returns nil for an empty stuff' do
			expect(described_class.parse(nil)).to be_nil
			expect(described_class.parse('')).to be_nil
			expect(described_class.parse("  \n")).to be_nil
		end

		it 'creates a ProxyURI instance' do
			expect(described_class.parse('cache:3128')).to be_a(described_class)
			expect(described_class.parse('cache:3128').hostname).to eq 'cache'
			expect(described_class.parse('cache:3128').port).to eq 3128
		end
	end

	context '== (equality)' do
		subject { described_class.new('cache:3128') }
		let(:other) { described_class.new('cache:3128') }
		let(:http) { described_class.new('http://cache:3128') }

		it 'is equals when URIs match' do
			expect(subject).to eq other
		end

		it 'is not equals when the URIs do not match (obviously)' do
			expect(subject).to_not eq http
		end
	end

	context 'Generic (cache:3128)' do
		subject { described_class.parse('cache:3128') }

		it 'has the #scheme, #hostname and #port right' do
			expect(subject.scheme).to be_nil
			expect(subject.hostname).to eq 'cache'
			expect(subject.port).to eq 3128
			expect(subject.to_s).to eq 'cache:3128'
		end
	end

	context 'Generic (cache.example.net:3128)' do
		subject { described_class.parse('cache.example.net:3128') }

		it 'has the #scheme, #hostname and #port right' do
			expect(subject.scheme).to be_nil
			expect(subject.hostname).to eq 'cache.example.net'
			expect(subject.port).to eq 3128
			expect(subject.to_s).to eq 'cache.example.net:3128'
		end
	end

	context 'HTTP (http://cache:3128)' do
		subject { described_class.parse('http://cache.example.net:3128') }

		it 'has the #scheme, #hostname and #port right' do
			expect(subject.scheme).to eq 'http'
			expect(subject.hostname).to eq 'cache.example.net'
			expect(subject.port).to eq 3128
			expect(subject.to_s).to eq 'http://cache.example.net:3128'
		end
	end

	context 'Socks5 (socks5://cache:3128)' do
		subject { described_class.parse('socks5://cache.example.net:3128') }

		it 'has the #scheme, #hostname and #port right' do
			expect(subject.scheme).to eq 'socks5'
			expect(subject.hostname).to eq 'cache.example.net'
			expect(subject.port).to eq 3128
			expect(subject.to_s).to eq 'socks5://cache.example.net:3128'
		end
	end
end
