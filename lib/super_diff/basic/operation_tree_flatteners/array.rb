# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeFlatteners
      class Array < Collection
        protected

        def open_token
          '['
        end

        def close_token
          ']'
        end
      end
    end
  end
end
