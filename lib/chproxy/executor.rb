module Chproxy
  class Executor
    def self.rewriter(cli, dest, label = nil)
      self.new(cli, dest, label) { |content| write(content) }
    end

    def self.deleter(cli, dest, label = nil)
      self.new(cli, dest, label) { |content| content ? write(content) : unlink }
    end

    attr_reader :cli, :dest, :label, :updater

    def dry_run?
      @dry_run
    end

    def update(content)
      update?(content) ? instance_exec(content, &updater) : skip
    end

    def update?(content)
      content.to_s.strip != existing_content.to_s.strip
    end

    private

    def initialize(cli, dest, label: nil, dry_run: false, &block)
      @cli = cli
      @dest = dest
      @label = label ? " #{label}" : ''
      @dry_run = @dry_run
      @updater = block
    end

    def write(content)
      File.open(dest, 'w') { |f| f.write(content.to_s) } unless dry_run?
      cli.say_status 'UPDATE', "chproxy:#{label} updated [changes] (#{dest})", :yellow

      true
    end

    def unlink
      return skip unless File.file?(dest)
      File.unlink(dest) unless dry_run?
      cli.say_status 'REMOVE', "chproxy:#{label} removed [no proxy] (#{dest})", :red

      true
    end

    def skip
      cli.say_status 'SKIP', "chproxy:#{label} still up-to-dat [no changes] (#{dest})", :green

      false
    end

    def existing_content
      return unless File.file?(dest)
      @existing_content ||= File.read(dest) rescue nil
    end
  end
end
