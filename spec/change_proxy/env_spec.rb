require 'spec_helper'
require 'change_proxy/env'

RSpec.describe ChangeProxy::Env do
	let(:none_env) do
		described_class.new('USER' => 'bella', 'HOME' => '/home/bella', 'TERM' => 'xterm', 'OTHER' => 'foo', 'didum' => 'bar')
	end

	let(:empty_env) do
		described_class.new('USER' => 'bella', 'HOME' => '/home/bella', 'TERM' => 'xterm',
			'proxy' => '',
			'http_proxy' => "\t  ",
			'no_proxy' => "   \t,  ")
	end

	let(:proxy_env) do
		described_class.new(
			'USER' => 'bella', 'HOME' => '/home/bella', 'TERM' => 'xterm',
			'proxy' => 'proxy.example.net:1234',
			'no_proxy' => 'example.org,example.net,example.com,192.168.0.0/16')
	end

	let(:proto_proxy_env) do
		described_class.new(
			'USER' => 'bella', 'HOME' => '/home/bella', 'TERM' => 'xterm',
			'proxy' => 'proxy.example.net:1234',
		 	'http_proxy' => 'http://proxy:3000',)
	end

	let(:upcase_proxy_env) do
		described_class.new(
			'USER' => 'bella', 'HOME' => '/home/bella', 'TERM' => 'xterm',
			'PROXY' => 'proxy.example.net:1234',
		 	'RSYNC_PROXY' => 'socks5://proxy.example.net:3000',
			'NO_PROXY' => 'example.net')
	end

	let(:override_proxy_env) do
		described_class.new(
			'USER' => 'bella', 'HOME' => '/home/bella', 'TERM' => 'xterm',
			'PROXY' => 'proxy.example.net:1234',
		 	'RSYNC_PROXY' => 'socks5://proxy.example.net:1234',
			'NO_PROXY' => 'example.net',
			'rsync_proxy' => 'socks5://proxy.example.net:3000',
			'proxy' => 'proxy.example.net:3000')
	end

	let(:proto_only_env) do
		described_class.new(
			'USER' => 'bella', 'HOME' => '/home/bella', 'TERM' => 'xterm',
			'http_proxy' => 'proxy.example.net:1234')
	end

	context '#proxy?' do
		context 'called with nil' do
			it 'returns falsey when "proxy"/"PROXY" is not set' do
				expect(none_env.proxy?).to be_falsey
				expect(proto_only_env.proxy?).to be_falsey
				expect(empty_env.proxy?).to be_falsey
			end

			it 'returns truthy when "proxy" is set' do
				expect(proxy_env.proxy?).to be_truthy
			end

			it 'returns truthy when "PROXY" is set' do
				expect(upcase_proxy_env.proxy?).to be_truthy
			end
		end

		context 'called with :protocol' do
			it 'returns falsey when there is no proxy' do
				expect(none_env.proxy?(:http)).to be_falsey
				expect(empty_env.proxy?(:http)).to be_falsey
			end

			it 'returns falsey when "http_proxy" is set, but "proxy" is not (requirement)' do
				expect(proto_only_env.proxy?(:http)).to be_falsey
			end

			it 'returns falsey when "proxy" is set, but "http_proxy" is not' do
				expect(proxy_env.proxy?(:http)).to be_falsey
			end

			it 'returns truthy when "http_proxy" is set' do
				expect(proto_proxy_env.proxy?(:http)).to be_truthy
			end

			it 'returns truthy when "RSYNC_PROXY" is set' do
				expect(upcase_proxy_env.proxy?(:rsync)).to be_truthy
			end
		end
	end

	context '#proxy' do
		context 'called with nil' do
			it 'returns nil when there is no proxy' do
				expect(none_env.proxy).to be_nil
				expect(empty_env.proxy).to be_nil
			end

			it 'returns proxy.example.net:1234 URI when "proxy" is set' do
				expect(proxy_env.proxy).to eq ChangeProxy::ProxyURI.parse('proxy.example.net:1234')
			end

			it 'returns proxy.example.net:1234 URI when "PROXY" is set' do
				expect(upcase_proxy_env.proxy).to eq ChangeProxy::ProxyURI.parse('proxy.example.net:1234')
			end

			it 'returns proxy.example.net:3000 URI when "PROXY" and "proxy" is set (lowercase wins!)' do
				expect(override_proxy_env.proxy).to eq ChangeProxy::ProxyURI.parse('proxy.example.net:3000')
			end
		end

		[:http, "http", :HTTP, "HTTP"].each do |proto|
			context "called with #{proto.inspect}" do
				it 'returns nil when there is no "proxy" or "http_proxy" is set' do
					expect(none_env.proxy(proto)).to be_nil
					expect(empty_env.proxy(proto)).to be_nil
				end

				it 'returns proxy.example.net:1234 URI when only "proxy" is set (fallback)' do
					expect(proxy_env.proxy(proto)).to eq ChangeProxy::ProxyURI.parse('proxy.example.net:1234')
				end

				it 'returns proxy.example.net:1234 URI when only "PROXY" is set (fallback)' do
					expect(upcase_proxy_env.proxy(proto)).to eq ChangeProxy::ProxyURI.parse('proxy.example.net:1234')
				end

				it 'returns http://proxy:3000 URL when "http_proxy" is set (overrides "proxy")' do
					expect(proto_proxy_env.proxy(proto)).to eq ChangeProxy::ProxyURI.parse('http://proxy:3000')
				end
			end
		end

		[:rsync, "rsync", :RSYNC, "RSYNC"].each do |proto|
			context "called with #{proto.inspect}" do
				it 'returns socks5://proxy.example.net:3000 when "RSYNC_PROXY" is set (overrides "PROXY" and "proxy")' do
					expect(upcase_proxy_env.proxy(proto)).to eq ChangeProxy::ProxyURI.parse('socks5://proxy.example.net:3000')
				end

				it 'returns socks5://proxy.example.net:3000 when "rsync_proxy" is set (overrides "RSYNC_PROXY" and "proxy")' do
					expect(upcase_proxy_env.proxy(proto)).to eq ChangeProxy::ProxyURI.parse('socks5://proxy.example.net:3000')
				end
			end
		end
	end

	context '#proxy_raw (lookup without fallback)' do
		it 'returns nil when "http_proxy" is not set, but "proxy" is' do
			expect(proxy_env.proxy_raw(:http)).to be_nil
		end

		it 'returns http://proxy:3000 when "http_proxy" is set' do
			expect(proto_proxy_env.proxy_raw(:http)).to eq ChangeProxy::ProxyURI.parse('http://proxy:3000')
		end
	end

	context '#no_proxy' do
		it 'returns an empty array when not set' do
			expect(none_env.no_proxy).to eq []
			expect(empty_env.no_proxy).to eq []
		end

		it 'returns an array from entries when "no_proxy" is set' do
			expect(proxy_env.no_proxy).to eq %w{example.org example.net example.com 192.168.0.0/16}
		end

		it 'returns an array from entries when "NO_PROXY" is set' do
			expect(upcase_proxy_env.no_proxy).to eq %w{example.net}
		end
	end
end
