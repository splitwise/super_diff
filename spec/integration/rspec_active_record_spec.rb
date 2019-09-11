require "spec_helper"

RSpec.describe "Integration with ActiveRecord", type: :integration do
  include_context "integration with ActiveRecord"

  def make_program(test)
    make_rspec_active_record_program(test)
  end
end
