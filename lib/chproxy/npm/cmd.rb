require 'chproxy/npm/config'

require 'chproxy/env'
require 'chproxy/editor'
require 'chproxy/executor'

module Chproxy
  module Npm
    module Cmd
      def self.included(klass)
        klass.module_eval do
          desc 'npm [config]', 'Updates the npm/yarn config file.'
          def npm(config = "#{Thor::Util.user_home}/.npmrc")
            editor = Chproxy::Editor.new(Chproxy::Npm::Config, config, protocols)
            executor = Chproxy::Executor.rewriter(self, config,
                                                  dry_run: dry_run?,
                                                  label: 'npm config')
            executor.update(editor.rewrite(Chproxy::Env.env))
          end
        end
      end
    end
  end
end
