module SuperDiff
  module Tests
    module Colorizer
      def self.call(*args, **opts, &block)
        SuperDiff::ColorizedDocument.colorize(*args, **opts, &block)
      end
    end
  end
end
