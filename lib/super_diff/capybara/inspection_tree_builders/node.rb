# frozen_string_literal: true

module SuperDiff
  module Capybara
    module InspectionTreeBuilders
      # A node holds the session, and through it the driver and the browser
      # connection. Walking its instance variables can take minutes, so it is
      # rendered the way Capybara prints it.
      class Node < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          value.is_a?(::Capybara::Node::Base) ||
            value.is_a?(::Capybara::Driver::Node)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.as_lines_when_rendering_to_lines do |t2|
              t2.add_text inspection
            end
          end
        end

        private

        def inspection
          object.inspect
        rescue StandardError
          "#<#{object.class.name}>"
        end
      end
    end
  end
end
