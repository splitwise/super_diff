require "spec_helper"

RSpec.describe "Integration with RSpec metadata for extra failure lines",
               type: :integration do
  it "displays extra_failure_lines of metadata" do
    as_both_colored_and_uncolored do |color_enabled|
      program =
        make_plain_test_program(<<~TEST, color_enabled: color_enabled, preserve_as_whole_file: true)
          RSpec.describe "test" do
            it { expect(true).to be(false) }

            after do
              RSpec.current_example.metadata[:extra_failure_lines] = "foo\nbar"  
            end
          end
        TEST

      expect(program).to produce_output_when_run("foo\nbar").in_color(color_enabled)
    end
  end
end
