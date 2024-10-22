# frozen_string_literal: true

module SuperDiff
  module ActiveRecord
    module InspectionTreeBuilders
      class ActiveRecordRelation < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          value.is_a?(::ActiveRecord::Relation)
        end

        def call
          Core::InspectionTree.new do |t1|
            # stree-ignore
            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :open
            ) do |t2|
              t2.add_text '#<ActiveRecord::Relation ['
            end

            # stree-ignore
            t1.nested do |t2|
              t2.insert_array_inspection_of(object)
            end

            # stree-ignore
            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :close
            ) do |t2|
              t2.add_text ']>'
            end
          end
        end
      end
    end
  end
end
