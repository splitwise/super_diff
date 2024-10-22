# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperDiff::Core::Configuration do
  it 'maintains frozen instance variables' do
    expect(described_class.new.instance_variables).to all(be_frozen)
  end

  describe '.new' do
    context 'when passed nothing' do
      subject(:config) { described_class.new }

      it 'creates a Configuration object with reasonable defaults' do
        expect(config.actual_color).to eq(:yellow)
      end
    end

    context 'when passed options' do
      subject(:config) { described_class.new(actual_color: :cyan) }

      it 'overrides the defaults with the provided options' do
        expect(config.actual_color).to eq(:cyan)
      end

      it 'uses the defaults for other options' do
        expect(config.border_color).to eq(:blue)
      end
    end
  end

  describe '.dup' do
    subject(:duplicated_config) { original_config.dup }

    let(:original_config) { described_class.new(overrides) }
    let(:in_both) { Class.new }
    let(:in_duplicated_only) { Class.new }
    let(:in_original_only) { Class.new }

    let(:overrides) do
      {
        extra_diff_formatter_classes: [],
        extra_differ_classes: [],
        extra_inspection_tree_builder_classes: [],
        extra_operation_tree_builder_classes: [],
        extra_operation_tree_classes: []
      }
    end

    %i[
      diff_formatter
      differ
      operation_tree_builder
      operation_tree
      inspection_tree_builder
    ].each do |object_type|
      it "duplicates extra #{object_type.to_s.tr('_', ' ')} classes" do
        add_method_name = :"add_extra_#{object_type}_class"
        get_method_name = :"extra_#{object_type}_classes"

        original_config.send(add_method_name, in_both)
        expect do
          duplicated_config.send(get_method_name) << in_duplicated_only
        end.to raise_error(FrozenError)
        duplicated_config.send(add_method_name, in_duplicated_only)
        original_config.send(add_method_name, in_original_only)

        expect(original_config.send(get_method_name)).to include(
          in_both,
          in_original_only
        )
        expect(original_config.send(get_method_name)).not_to include(
          in_duplicated_only
        )

        expect(duplicated_config.send(get_method_name)).to include(
          in_both,
          in_duplicated_only
        )
        expect(duplicated_config.send(get_method_name)).not_to include(
          in_original_only
        )
      end
    end
  end

  %i[
    diff_formatter
    differ
    operation_tree_builder
    operation_tree
    inspection_tree_builder
  ].each do |object_type|
    describe "#add_extra_#{object_type}_classes" do
      let(:config) { described_class.new }
      let(:new_class1) { Class.new }
      let(:new_class2) { Class.new }

      it 'appends multiple given classes' do
        config.send("add_extra_#{object_type}_classes", new_class1, new_class2)
        expect(config.send("extra_#{object_type}_classes")[-2..]).to eq(
          [new_class1, new_class2]
        )
      end

      it 'appends a single given class' do
        config.send("add_extra_#{object_type}_classes", new_class1)
        expect(config.send("extra_#{object_type}_classes")[-1]).to eq(
          new_class1
        )
      end
    end

    describe "#prepend_extra_#{object_type}_classes" do
      let(:config) { described_class.new }
      let(:new_class1) { Class.new }
      let(:new_class2) { Class.new }

      it 'prepends multiple given classes' do
        config.send(
          "prepend_extra_#{object_type}_classes",
          new_class1,
          new_class2
        )
        expect(config.send("extra_#{object_type}_classes")[..1]).to eq(
          [new_class1, new_class2]
        )
      end

      it 'prepends a single given class' do
        config.send("prepend_extra_#{object_type}_classes", new_class1)
        expect(config.send("extra_#{object_type}_classes")[0]).to eq(new_class1)
      end
    end
  end

  describe '#color_enabled?' do
    context 'when explicitly set' do
      it 'equals what was set' do
        [true, false].each do |value|
          SuperDiff.configuration.color_enabled.tap do |original|
            SuperDiff.configuration.color_enabled = value
            expect(SuperDiff.configuration.color_enabled?).to be(value)
            SuperDiff.configuration.color_enabled = original
          end
        end
      end
    end

    context 'when not explicitly set' do
      context 'when ENV["CI"] is true' do
        it 'is true' do
          color_enabled = nil
          ClimateControl.modify(CI: 'true') do
            color_enabled = SuperDiff.configuration.color_enabled?
          end
          expect(color_enabled).to be(true)
        end
      end

      context 'when ENV["CI"] is not true' do
        it "defaults to RSpec's config" do
          ClimateControl.modify(CI: nil) do
            %i[automatic on off].each do |value|
              RSpec.configuration.color_mode.tap do |original|
                RSpec.configuration.color_mode = value
                expect(SuperDiff.configuration.color_enabled?).to eq(
                  RSpec.configuration.color_enabled?
                )
                RSpec.configuration.color_mode = original
              end
            end
          end
        end
      end
    end
  end
end
