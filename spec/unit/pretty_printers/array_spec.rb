require "spec_helper"

RSpec.describe SuperDiff::PrettyPrinters::Array do
  context 'given an empty array' do
    it 'returns an array literal on one line' do
      expected = %([])

      actual = described_class.pretty_print([])

      expect(actual).to eq(expected)
    end
  end

  context 'given an array of numbers' do
    it 'returns an array literal containing the numbers' do
      expected = <<~OUTPUT.strip
        [
          1,
          2,
          3,
          4
        ]
      OUTPUT

      actual = described_class.pretty_print([1, 2, 3, 4])

      expect(actual).to eq(expected)
    end
  end

  context 'given an array of symbols' do
    it 'returns an array literal containing the symbols' do
      expected = <<~OUTPUT.strip
        [
          :time_traveler,
          :overtime,
          :pizza
        ]
      OUTPUT

      actual = described_class.pretty_print([:time_traveler, :overtime, :pizza])

      expect(actual).to eq(expected)
    end
  end

  context 'given an array of strings' do
    it 'returns an array literal containing inspected versions of the strings' do
      expected = <<~OUTPUT.strip
        [
          "these are some words and things",
          "those are also words! what do you know?!"
        ]
      OUTPUT

      actual = described_class.pretty_print([
        'these are some words and things',
        'those are also words! what do you know?!'
      ])

      expect(actual).to eq(expected)
    end
  end

  context 'given an array of objects' do
    it 'returns an array literal, where each object is pretty printed too' do
      people = [
        SuperDiff::Tests::Person.new(name: "Marty").tap { |person|
          allow(person).to receive(:object_id).and_return(1)
        },
        SuperDiff::Tests::Person.new(name: "Doc").tap { |person|
          allow(person).to receive(:object_id).and_return(2)
        }
      ]
      expected = <<~OUTPUT.strip
        [
          #<Person:0x0000001
            @name="Marty"
          >,
          #<Person:0x0000001
            @name="Marty"
          >
        ]
      OUTPUT

      actual = described_class.pretty_print([
      ])

      expect(actual).to eq(expected)
    end
  end
end
