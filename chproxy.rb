# frozen_string_literal: true

# AdHoc Homebrew formula to install chproxy / chpup on macOS.
#
#    brew install https://raw.githubusercontent.com/lwe/chproxy/master/chproxy.rb
#
class Chproxy < Formula
  desc 'The missing proxy management CLI for gradle, maven & others.'
  version '0.1.0'
  homepage 'https://github.com/lwe/chproxy'
  head 'https://github.com/lwe/chproxy.git', using: :git

  def install
    ENV['GEM_HOME'] = libexec
    ENV['GEM_PATH'] = libexec
    system 'gem', 'build', 'chproxy.gemspec'
    system 'gem', 'install', 'chproxy-*.gem', '--no-ri', '--no-rdoc'
    bin.install libexec/'bin/chproxy'
    bin.env_script_all_files(libexec/'bin', GEM_HOME: ENV['GEM_HOME'], GEM_PATH: ENV['GEM_PATH'])
  end

  test do
    system "#{bin}/chproxy", '--version'
  end
end
