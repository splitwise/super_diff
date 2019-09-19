require "spec_helper"

RSpec.describe "Integration with Rails's ActiveRecord class", type: :integration do
  context "when using 'super_diff/rspec-rails'" do
    include_context "integration with ActiveRecord"

    def make_program(test)
      make_rspec_rails_test_program(test)
    end
  end

  context "when using 'super_diff/active_record'" do
    include_context "integration with ActiveRecord"

    def make_program(test)
      make_rspec_active_record_program(test)
    end
  end
end
