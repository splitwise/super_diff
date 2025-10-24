# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Integration with ActionDispatch', type: :integration, action_dispatch: true do
  context "when using 'super_diff/rspec-rails'" do
    include_context 'integration with ActionDispatch'

    def make_program(test, color_enabled:)
      make_rspec_rails_test_program(test, color_enabled: color_enabled)
    end
  end

  context "when using 'super_diff/action_dispatch'" do
    include_context 'integration with ActionDispatch'

    def make_program(test, color_enabled:)
      make_rspec_action_dispatch_program(test, color_enabled: color_enabled)
    end
  end
end
