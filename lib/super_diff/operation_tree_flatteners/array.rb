module SuperDiff
  module OperationTreeFlatteners
    class Array < Collection
      protected

      def open_token
        "["
      end

      def close_token
        "]"
      end
    end
  end
end
