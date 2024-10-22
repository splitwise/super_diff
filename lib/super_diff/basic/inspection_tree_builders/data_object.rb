# frozen_string_literal: true

module SuperDiff
  module Basic
    module InspectionTreeBuilders
      class DataObject < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          SuperDiff::Core::Helpers.ruby_version_matches?('~> 3.2') &&
            value.is_a?(Data)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :open
            ) do |t2|
              t2.add_text "#<data #{object.class.name} "

              # stree-ignore
              t2.when_rendering_to_lines do |t3|
                t3.add_text '{'
              end
            end

            t1.nested { |t2| t2.insert_hash_inspection_of(object.to_h) }

            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :close
            ) do |t2|
              # stree-ignore
              t2.when_rendering_to_lines do |t3|
                t3.add_text '}'
              end

              t2.add_text '>'
            end
          end
        end
      end
    end
  end
end
