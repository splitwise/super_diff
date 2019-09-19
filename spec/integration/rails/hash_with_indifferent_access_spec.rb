require "spec_helper"

RSpec.describe "Integration with Rails's HashWithIndifferentAccess", type: :integration do
  context "when using 'super_diff/rspec-rails'" do
    include_context "integration with HashWithIndifferentAccess"

    def make_program(test)
      make_rspec_rails_test_program(test)
    end
  end

  xcontext "when using 'super_diff/active_support'" do
    include_context "integration with HashWithIndifferentAccess"

    def make_program(test)
      make_rspec_active_support_program(test)
    end
  end
end
