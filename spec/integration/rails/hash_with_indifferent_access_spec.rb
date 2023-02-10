require "spec_helper"

RSpec.describe "Integration with Rails's HashWithIndifferentAccess",
               type: :integration,
               active_record: true do
  context "when using 'super_diff/rspec-rails'" do
    include_context "integration with HashWithIndifferentAccess"

    def make_program(test, color_enabled:)
      make_rspec_rails_test_program(test, color_enabled: color_enabled)
    end
  end

  context "when using 'super_diff/active_support'" do
    include_context "integration with HashWithIndifferentAccess"

    def make_program(test, color_enabled:)
      make_rspec_active_support_program(test, color_enabled: color_enabled)
    end
  end
end
