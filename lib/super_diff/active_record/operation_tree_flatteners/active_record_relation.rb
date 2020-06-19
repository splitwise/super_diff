module SuperDiff
  module ActiveRecord
    module OperationTreeFlatteners
      class ActiveRecordRelation < SuperDiff::OperationTreeFlatteners::Collection
        protected

        def open_token
          "#<ActiveRecord::Relation ["
        end

        def close_token
          "]>"
        end
      end
    end
  end
end
