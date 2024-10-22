# frozen_string_literal: true

module SuperDiff
  module Basic
    module InspectionTreeBuilders
      class Array < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          value.is_a?(::Array)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.only_when empty do |t2|
              # stree-ignore
              t2.as_lines_when_rendering_to_lines do |t3|
                t3.add_text '[]'
              end
            end

            t1.only_when nonempty do |t2|
              # stree-ignore
              t2.as_lines_when_rendering_to_lines(
                collection_bookend: :open
              ) do |t3|
                t3.add_text '['
              end

              # stree-ignore
              t2.nested do |t3|
                t3.insert_array_inspection_of(object)
              end

              # stree-ignore
              t2.as_lines_when_rendering_to_lines(
                collection_bookend: :close
              ) do |t3|
                t3.add_text ']'
              end
            end
          end
        end

        private

        def empty
          -> { object.empty? }
        end

        def nonempty
          -> { !object.empty? }
        end
      end
    end
  end
end
