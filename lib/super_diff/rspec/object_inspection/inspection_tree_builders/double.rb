module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class Double < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            value.is_a?(::RSpec::Mocks::Double)
          end

          def call
            builder = self
            empty = -> { empty? }
            nonempty = -> { !empty? }

            SuperDiff::ObjectInspection::InspectionTree.new do
              only_when empty do
                as_lines_when_rendering_to_lines do
                  add_text do |object|
                    inspected_class = builder.inspected_class
                    inspected_name = builder.inspected_name
                    "#<#{inspected_class} #{inspected_name}>"
                  end
                end
              end

              only_when nonempty do
                as_lines_when_rendering_to_lines(collection_bookend: :open) do
                  add_text do |object|
                    inspected_class = builder.inspected_class
                    inspected_name = builder.inspected_name
                    "#<#{inspected_class} #{inspected_name}"
                  end

                  when_rendering_to_lines do
                    add_text " {"
                  end
                end

                when_rendering_to_string do
                  add_text " "
                end

                nested do |object|
                  insert_hash_inspection_of(builder.doubled_methods)
                end

                as_lines_when_rendering_to_lines(collection_bookend: :close) do
                  when_rendering_to_lines do
                    add_text "}"
                  end

                  add_text ">"
                end
              end
            end
          end

          def empty?
            doubled_methods.empty?
          end

          def nonempty?
            !empty?
          end

          def inspected_class
            case object
            when ::RSpec::Mocks::InstanceVerifyingDouble
              "InstanceDouble"
            when ::RSpec::Mocks::ClassVerifyingDouble
              "ClassDouble"
            when ::RSpec::Mocks::ObjectVerifyingDouble
              "ObjectDouble"
            else
              "Double"
            end
          end

          def inspected_name
            if object.instance_variable_get("@name")
              object.instance_variable_get("@name").inspect
            else
              "(anonymous)"
            end
          end

          def doubled_methods
            @_doubled_methods ||= doubled_method_names.reduce({}) do |hash, key|
              hash.merge(key => object.public_send(key))
            end
          end

          def doubled_method_names
            object.
              __send__(:__mock_proxy).
              instance_variable_get("@method_doubles").
              keys
          end
        end
      end
    end
  end
end
