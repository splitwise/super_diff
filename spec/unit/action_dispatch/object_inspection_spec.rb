# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperDiff, type: :unit do
  describe '.inspect_object', 'for ActionDispatch objects', action_dispatch: true do
    context 'given an ActionDispatch::Request' do
      context 'given as_lines: false' do
        it 'returns an inspected version of the object' do
          string =
            described_class.inspect_object(
              ActionDispatch::Request.new(
                {
                  'REQUEST_METHOD' => 'PUT',
                  'REMOTE_ADDR' => '10.0.0.1',
                  Rack::RACK_URL_SCHEME => 'http',
                  'HTTP_HOST' => 'host.local'
                }
              ),
              as_lines: false
            )
          expect(string).to eq(
            %(#<ActionDispatch::Request PUT "http://host.local" for 10.0.0.1>)
          )
        end
      end

      context 'given as_lines: true' do
        it 'returns an inspected version of the object on one line' do
          tiered_lines =
            described_class.inspect_object(
              ActionDispatch::Request.new(
                {
                  'REQUEST_METHOD' => 'PUT',
                  'REMOTE_ADDR' => '10.0.0.1',
                  Rack::RACK_URL_SCHEME => 'http',
                  'HTTP_HOST' => 'host.local'
                }
              ),
              as_lines: true,
              type: :noop,
              indentation_level: 1
            )

          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: '#<ActionDispatch::Request PUT "http://host.local" for 10.0.0.1>'
              )
            ]
          )
        end
      end
    end
  end
end
