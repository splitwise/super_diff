require "spec_helper"

RSpec.describe "Integration with ActiveSupport", type: :integration do
  context "when using 'super_diff/rspec-rails'" do
    include_context "integration with ActiveSupport"

    def make_program(test, color_enabled:)
      make_rspec_rails_test_program(test, color_enabled: color_enabled)
    end
  end

  context "when using 'super_diff/active_support'" do
    include_context "integration with ActiveSupport"

    def make_program(test, color_enabled:)
      make_rspec_active_record_program(test, color_enabled: color_enabled)
    end
  end
end
