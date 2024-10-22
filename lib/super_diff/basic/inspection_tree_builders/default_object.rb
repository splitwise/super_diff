# frozen_string_literal: true

module SuperDiff
  module Basic
    module InspectionTreeBuilders
      class DefaultObject < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(_value)
          true
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.only_when empty do |t2|
              t2.as_lines_when_rendering_to_lines do |t3|
                t3.add_text(
                  "#<#{object.class.name}:#{object_address_for(object)}>"
                )
              end
            end

            t1.only_when nonempty do |t2|
              t2.as_lines_when_rendering_to_lines(
                collection_bookend: :open
              ) do |t3|
                t3.add_text(
                  "#<#{object.class.name}:" + object_address_for(object)
                )

                # stree-ignore
                t3.when_rendering_to_lines do |t4|
                  t4.add_text ' {'
                end
              end

              # stree-ignore
              t2.when_rendering_to_string do |t3|
                t3.add_text ' '
              end

              t2.nested do |t3|
                t3.insert_separated_list(
                  object.instance_variables.sort
                ) do |t4, name|
                  # stree-ignore
                  t4.as_prefix_when_rendering_to_lines do |t5|
                    t5.add_text "#{name}="
                  end

                  t4.add_inspection_of object.instance_variable_get(name)
                end
              end

              t2.as_lines_when_rendering_to_lines(
                collection_bookend: :close
              ) do |t3|
                # stree-ignore
                t3.when_rendering_to_lines do |t4|
                  t4.add_text '}'
                end

                t3.add_text '>'
              end
            end
          end
        end

        private

        def empty
          -> { object.instance_variables.empty? }
        end

        def nonempty
          -> { !object.instance_variables.empty? }
        end
      end
    end
  end
end
