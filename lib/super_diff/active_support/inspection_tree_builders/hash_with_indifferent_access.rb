# frozen_string_literal: true

module SuperDiff
  module ActiveSupport
    module InspectionTreeBuilders
      class HashWithIndifferentAccess < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          value.is_a?(::HashWithIndifferentAccess)
        end

        def call
          Core::InspectionTree.new do |t1|
            # stree-ignore
            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :open
            ) do |t2|
              t2.add_text '#<HashWithIndifferentAccess {'
            end

            # stree-ignore
            t1.when_rendering_to_string do |t2|
              t2.add_text ' '
            end

            # stree-ignore
            t1.nested do |t2|
              t2.insert_hash_inspection_of(object)
            end

            # stree-ignore
            t1.when_rendering_to_string do |t2|
              t2.add_text ' '
            end

            # stree-ignore
            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :close
            ) do |t2|
              t2.add_text '}>'
            end
          end
        end
      end
    end
  end
end
