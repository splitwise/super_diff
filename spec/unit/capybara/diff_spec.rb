# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperDiff, type: :unit do
  describe '.diff', 'for Capybara objects', capybara: true do
    let(:session) do
      app = ->(_env) { [200, { 'content-type' => 'text/html' }, ['<h1>Hello</h1><h2>World</h2>']] }
      Capybara::Session.new(:rack_test, app).tap { |s| s.visit('/') }
    end

    let(:expected) { session.find(:css, 'h1') }
    let(:actual) { session.find(:css, 'h2') }

    context 'given two Capybara::Node::Elements' do
      it 'diffs the inspections Capybara gives them' do
        expect(described_class.diff(expected, actual)).to eq(<<~DIFF.chomp)
          - #<Capybara::Node::Element tag="h1" path="/html/body/h1">
          + #<Capybara::Node::Element tag="h2" path="/html/body/h2">
        DIFF
      end

      it 'does not read their instance variables' do
        allow(expected).to receive(:instance_variables).and_call_original
        allow(actual).to receive(:instance_variables).and_call_original

        described_class.diff(expected, actual)

        expect(expected).not_to have_received(:instance_variables)
        expect(actual).not_to have_received(:instance_variables)
      end
    end

    context 'given two Capybara::Driver::Nodes' do
      it 'diffs the inspections the driver gives them' do
        expect(described_class.diff(expected.base, actual.base)).to eq(<<~DIFF.chomp)
          - #<Capybara::RackTest::Node tag="h1" path="/html/body/h1">
          + #<Capybara::RackTest::Node tag="h2" path="/html/body/h2">
        DIFF
      end
    end

    context 'given nodes of different classes' do
      it 'diffs the inspections Capybara gives them' do
        expect(described_class.diff(session.document, actual)).to eq(<<~DIFF.chomp)
          - #<Capybara::Document>
          + #<Capybara::Node::Element tag="h2" path="/html/body/h2">
        DIFF
      end
    end

    context 'given nodes inside a collection' do
      it 'diffs the inspections Capybara gives them' do
        expect(described_class.diff({ heading: expected }, { heading: actual })).to eq(<<~DIFF.chomp)
          \s {
          -   heading: #<Capybara::Node::Element tag="h1" path="/html/body/h1">
          +   heading: #<Capybara::Node::Element tag="h2" path="/html/body/h2">
          \s }
        DIFF
      end
    end
  end
end
