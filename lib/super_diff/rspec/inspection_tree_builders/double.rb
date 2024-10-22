# frozen_string_literal: true

module SuperDiff
  module RSpec
    module InspectionTreeBuilders
      class Double < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          value.is_a?(::RSpec::Mocks::Double)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.only_when method(:empty?) do |t2|
              t2.as_lines_when_rendering_to_lines do |t3|
                t3.add_text("#<#{inspected_class} #{inspected_name}>")
              end
            end

            t1.only_when method(:nonempty?) do |t2|
              t2.as_lines_when_rendering_to_lines(
                collection_bookend: :open
              ) do |t3|
                t3.add_text("#<#{inspected_class} #{inspected_name}")

                # stree-ignore
                t3.when_rendering_to_lines do |t4|
                  t4.add_text ' {'
                end
              end

              # stree-ignore
              t2.when_rendering_to_string do |t3|
                t3.add_text ' '
              end

              # stree-ignore
              t2.nested do |t3|
                t3.insert_hash_inspection_of doubled_methods
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

        def empty?
          doubled_methods.empty?
        end

        def nonempty?
          !empty?
        end

        def inspected_class
          case object
          when ::RSpec::Mocks::InstanceVerifyingDouble
            'InstanceDouble'
          when ::RSpec::Mocks::ClassVerifyingDouble
            'ClassDouble'
          when ::RSpec::Mocks::ObjectVerifyingDouble
            'ObjectDouble'
          else
            'Double'
          end
        end

        def inspected_name
          if object.instance_variable_get('@name')
            object.instance_variable_get('@name').inspect
          else
            '(anonymous)'
          end
        end

        def doubled_methods
          @doubled_methods ||=
            doubled_method_names.reduce({}) do |hash, key|
              hash.merge(key => object.public_send(key))
            end
        end

        def doubled_method_names
          object
            .__send__(:__mock_proxy)
            .instance_variable_get('@method_doubles')
            .keys
        end
      end
    end
  end
end
