module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module MapExtension
        def call(object)
          case object
          when ::ActiveRecord::Base
            Inspectors::ActiveRecordModel
          when ::ActiveRecord::Relation
            Inspectors::ActiveRecordRelation
          else
            super
          end
        end
      end
    end
  end
end
