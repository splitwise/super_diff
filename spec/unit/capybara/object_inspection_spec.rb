# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperDiff, type: :unit do
  describe '.inspect_object', 'for Capybara objects', capybara: true do
    let(:session) do
      app = ->(_env) { [200, { 'content-type' => 'text/html' }, ['<h1>Hello</h1>']] }
      Capybara::Session.new(:rack_test, app).tap { |s| s.visit('/') }
    end

    context 'given a Capybara::Node::Element' do
      context 'given as_lines: false' do
        it 'returns the inspection Capybara gives it' do
          string =
            described_class.inspect_object(session.find(:css, 'h1'), as_lines: false)
          expect(string).to eq(
            %(#<Capybara::Node::Element tag="h1" path="/html/body/h1">)
          )
        end
      end

      context 'given as_lines: true' do
        it 'returns the inspection Capybara gives it on one line' do
          tiered_lines =
            described_class.inspect_object(
              session.find(:css, 'h1'),
              as_lines: true,
              type: :noop,
              indentation_level: 1
            )

          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(#<Capybara::Node::Element tag="h1" path="/html/body/h1">)
              )
            ]
          )
        end
      end
    end

    context 'given a Capybara::Driver::Node' do
      it 'returns the inspection the driver gives it' do
        node = session.find(:css, 'h1').base
        string = described_class.inspect_object(node, as_lines: false)
        expect(string).to eq(node.inspect)
      end
    end

    context 'given a node whose inspection raises' do
      it 'returns the class name' do
        node = session.find(:css, 'h1')
        allow(node).to receive(:inspect).and_raise(StandardError)
        string = described_class.inspect_object(node, as_lines: false)
        expect(string).to eq('#<Capybara::Node::Element>')
      end
    end
  end
end
