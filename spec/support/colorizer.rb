module SuperDiff
  module Tests
    module Colorizer
      def self.call(*args, **opts, &block)
        SuperDiff::Helpers.style(*args, **opts, &block)
      end
    end
  end
end
