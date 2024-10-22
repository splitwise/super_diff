# frozen_string_literal: true

module SuperDiff
  module RSpec
    module InspectionTreeBuilders
      class KindOf < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          SuperDiff::RSpec.a_kind_of_something?(value) ||
            SuperDiff::RSpec.kind_of_something?(value)
        end

        def call
          Core::InspectionTree.new do |t1|
            klass =
              if SuperDiff::RSpec.a_kind_of_something?(object)
                object.expected
              else
                object.instance_variable_get(:@klass)
              end

            t1.add_text "#<a kind of #{klass}>"
          end
        end
      end
    end
  end
end
