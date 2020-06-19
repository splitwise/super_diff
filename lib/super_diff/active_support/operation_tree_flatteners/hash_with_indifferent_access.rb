module SuperDiff
  module ActiveSupport
    module OperationTreeFlatteners
      class HashWithIndifferentAccess < SuperDiff::OperationTreeFlatteners::Hash
        protected

        def open_token
          "#<HashWithIndifferentAccess {"
        end

        def close_token
          "}>"
        end
      end
    end
  end
end
