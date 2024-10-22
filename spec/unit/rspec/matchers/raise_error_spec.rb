# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "RSpec's `raise_error` matcher" do
  describe '#description' do
    context 'given only an exception class' do
      it 'returns the correct output' do
        expect(raise_error(RuntimeError).description).to eq(
          'raise a kind of RuntimeError'
        )
      end
    end

    context 'given only a string message' do
      it 'returns the correct output' do
        expect(raise_error('hell').description).to eq(
          %(raise a kind of Exception with message "hell")
        )
      end
    end

    context 'given only a regexp message' do
      it 'returns the correct output' do
        expect(raise_error(/hell/i).description).to eq(
          'raise a kind of Exception with message matching /hell/i'
        )
      end
    end

    context 'given both an exception and string message' do
      it 'returns the correct output' do
        expect(raise_error(RuntimeError, 'hell').description).to eq(
          %(raise a kind of RuntimeError with message "hell")
        )
      end
    end

    context 'given both an exception and regexp message' do
      it 'returns the correct output' do
        expect(raise_error(RuntimeError, /hell/i).description).to eq(
          'raise a kind of RuntimeError with message matching /hell/i'
        )
      end
    end

    context 'given a simple RSpec matcher' do
      it 'returns the correct output' do
        expect(raise_error(a_kind_of(RuntimeError)).description).to eq(
          'raise #<a kind of RuntimeError>'
        )
      end
    end

    context 'given a simple RSpec matcher and string message' do
      it 'returns the correct output' do
        expect(raise_error(a_kind_of(RuntimeError), 'boo').description).to eq(
          'raise #<a kind of RuntimeError> with message "boo"'
        )
      end
    end

    context 'given a simple RSpec matcher and regexp message' do
      it 'returns the correct output' do
        expect(raise_error(a_kind_of(RuntimeError), /boo/i).description).to eq(
          'raise #<a kind of RuntimeError> with message matching /boo/i'
        )
      end
    end

    context 'given a compound RSpec matcher' do
      it 'returns the correct output' do
        expect(raise_error(a_kind_of(Array).or(eq(true))).description).to eq(
          'raise #<a kind of Array or eq true>'
        )
      end
    end
  end
end
