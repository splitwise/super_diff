# frozen_string_literal: true

shared_examples_for 'integration with ActionDispatch' do
  context 'when testing attributes of an ActionDispatch::TestResponse' do
    it 'produces the correct failure message when used in the positive' do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~RUBY
          request = ActionDispatch::TestRequest.create
          response = ActionDispatch::TestResponse.new(200, {}, []).tap do |response|
            response.request = request
          end

          # The other attributes of TestResponse differ across Rails versions. We don't care about them
          # for the purposes of this test.
          ActionDispatch::TestResponse.define_method(:attributes_for_super_diff) { {request: request} }

          expect(response).to be_bad_request
        RUBY
        program =
          make_rspec_action_dispatch_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: 'expect(response).to be_bad_request',
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain '                     Expected '
                  actual '#<ActionDispatch::TestResponse request: #<ActionDispatch::TestRequest GET "http://test.host/" for 0.0.0.0>>'
                end

                line do
                  plain 'to return a truthy result for '
                  expected 'bad_request?'
                  plain ' or '
                  expected 'bad_requests?'
                end
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end
end
