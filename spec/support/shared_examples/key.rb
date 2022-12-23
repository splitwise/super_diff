shared_examples_for "a toggleable key" do
  context "if key_enabled is set to true" do
    it "produces the key" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = [
            "Afghanistan",
            "Aland Islands",
            "Albania",
            "Algeria",
            "American Samoa",
            "Andorra",
            "Angola",
            "Antarctica",
            "Antigua And Barbuda",
            "Argentina",
            "Armenia",
            "Aruba",
            "Australia"
          ]
          actual = [
            "Afghanistan",
            "Aland Islands",
            "Albania",
            "Algeria",
            "American Samoa",
            "Andorra",
            "Anguilla",
            "Antarctica",
            "Antigua And Barbuda",
            "Argentina",
            "Armenia",
            "Aruba",
            "Australia"
          ]
          expect(actual).to #{matcher}(expected)
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
          configuration: {
            key_enabled: true,
          },
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to #{matcher}(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              # rubocop:disable Layout/LineLength
              actual %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
              # rubocop:enable Layout/LineLength
            end

            line do
              plain "   to eq "
              # rubocop:disable Layout/LineLength
              expected %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
              # rubocop:enable Layout/LineLength
            end
          },
          diff: proc {
            plain_line          %|  [|
            plain_line          %|    "Afghanistan",|
            plain_line          %|    "Aland Islands",|
            plain_line          %|    "Albania",|
            plain_line          %|    "Algeria",|
            plain_line          %|    "American Samoa",|
            plain_line          %|    "Andorra",|
            expected_line       %|-   "Angola",|
            actual_line         %|+   "Anguilla",|
            plain_line          %|    "Antarctica",|
            plain_line          %|    "Antigua And Barbuda",|
            plain_line          %|    "Argentina",|
            plain_line          %|    "Armenia",|
            plain_line          %|    "Aruba",|
            plain_line          %|    "Australia"|
            plain_line          %|  ]|
          },
          key_enabled: true,
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "if key_enabled is set to false" do
    it "does not produce the key" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = [
            "Afghanistan",
            "Aland Islands",
            "Albania",
            "Algeria",
            "American Samoa",
            "Andorra",
            "Angola",
            "Antarctica",
            "Antigua And Barbuda",
            "Argentina",
            "Armenia",
            "Aruba",
            "Australia"
          ]
          actual = [
            "Afghanistan",
            "Aland Islands",
            "Albania",
            "Algeria",
            "American Samoa",
            "Andorra",
            "Anguilla",
            "Antarctica",
            "Antigua And Barbuda",
            "Argentina",
            "Armenia",
            "Aruba",
            "Australia"
          ]
          expect(actual).to #{matcher}(expected)
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
          configuration: {
            key_enabled: false,
          },
        )

        expected_output = build_expected_output(
          key_enabled: false,
          color_enabled: color_enabled,
          snippet: %|expect(actual).to #{matcher}(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              # rubocop:disable Layout/LineLength
              actual %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
              # rubocop:enable Layout/LineLength
            end

            line do
              plain "   to eq "
              # rubocop:disable Layout/LineLength
              expected %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
              # rubocop:enable Layout/LineLength
            end
          },
          diff: proc {
            plain_line          %|  [|
            plain_line          %|    "Afghanistan",|
            plain_line          %|    "Aland Islands",|
            plain_line          %|    "Albania",|
            plain_line          %|    "Algeria",|
            plain_line          %|    "American Samoa",|
            plain_line          %|    "Andorra",|
            expected_line       %|-   "Angola",|
            actual_line         %|+   "Anguilla",|
            plain_line          %|    "Antarctica",|
            plain_line          %|    "Antigua And Barbuda",|
            plain_line          %|    "Argentina",|
            plain_line          %|    "Armenia",|
            plain_line          %|    "Aruba",|
            plain_line          %|    "Australia"|
            plain_line          %|  ]|
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end
end
