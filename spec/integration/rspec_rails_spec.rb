require "spec_helper"

RSpec.describe "Integration with RSpec and Rails", type: :integration do
  it_behaves_like "integration with ActiveRecord"

  def make_program(test)
    make_rspec_rails_test_program(test)
  end
end
