module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module MapExtension
        def call(object)
          if object.is_a?(::ActiveRecord::Base)
            Inspector
          else
            super
          end
        end
      end
    end
  end
end
