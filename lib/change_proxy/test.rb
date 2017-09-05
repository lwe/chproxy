require 'open3'
require 'timeout'

module ChangeProxy
	module Test
		def self.factory(input)
			return ExecTest.new(input) if input.respond_to?(:to_str) && input[0] == "!" && input.size > 1
			return TrueTest.new if input
			raise ArgumentError, "no matching test found for: #{str}"
		end

		class ExecTest
			TIMEOUT_SECONDS = 2
			EXIT_OK = 0
			EXIT_TIMEOUT = -1

			attr_reader :cmd

			def initialize(cmd)
				@cmd = cmd[1..-1]
				@result = false
			end

			def active?
				@result ||= evaluate
				@result == EXIT_OK
			end

			private

			def evaluate
				Open3.popen3(cmd) do |stdin, stdout, stderr, process|
					begin
						Timeout.timeout(TIMEOUT_SECONDS) { process.value.to_i }
					rescue Timeout::Error
						Process.kill("KILL", process.pid)
						EXIT_TIMEOUT
					end
				end
			end
		end

		class TrueTest
			def active?; true end
		end
	end
end
