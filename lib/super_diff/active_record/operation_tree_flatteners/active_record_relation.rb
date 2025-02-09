# frozen_string_literal: true

module SuperDiff
  module ActiveRecord
    module OperationTreeFlatteners
      class ActiveRecordRelation < Basic::OperationTreeFlatteners::Collection
        protected

        def open_token
          '#<ActiveRecord::Relation ['
        end

        def close_token
          ']>'
        end
      end
    end
  end
end
