require "spec_helper"

# stree-ignore
common_constant_remappings = {
  "SuperDiff::ColorizedDocumentExtensions" => "SuperDiff::Core::ColorizedDocumentExtensions",
  "SuperDiff::Configuration" => "SuperDiff::Core::Configuration",
  # TODO: Add back?
  # "SuperDiff::DiffFormatters::Collection" => "SuperDiff::Basic::DiffFormatters::Collection",
  # "SuperDiff::DiffFormatters::MultilineString" => "SuperDiff::Basic::DiffFormatters::MultilineString",
  "SuperDiff::Differs::Array" => "SuperDiff::Basic::Differs::Array",
  "SuperDiff::Differs::Base" => "SuperDiff::Core::AbstractDiffer",
  "SuperDiff::Differs::CustomObject" => "SuperDiff::Basic::Differs::CustomObject",
  "SuperDiff::Differs::DateLike" => "SuperDiff::Basic::Differs::DateLike",
  "SuperDiff::Differs::DefaultObject" => "SuperDiff::Basic::Differs::DefaultObject",
  "SuperDiff::Differs::Hash" => "SuperDiff::Basic::Differs::Hash",
  "SuperDiff::Differs::MultilineString" => "SuperDiff::Basic::Differs::MultilineString",
  "SuperDiff::Differs::TimeLike" => "SuperDiff::Basic::Differs::TimeLike",
  "SuperDiff::Errors::NoDifferAvailableError" => "SuperDiff::Core::NoDifferAvailableError",
  "SuperDiff::GemVersion" => "SuperDiff::Core::GemVersion",
  "SuperDiff::Helpers" => "SuperDiff::Core::Helpers",
  "SuperDiff::ImplementationChecks" => "SuperDiff::Core::ImplementationChecks",
  "SuperDiff::Line" => "SuperDiff::Core::Line",
  "SuperDiff::ObjectInspection::InspectionTree" => "SuperDiff::Core::InspectionTree",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::Array" => "SuperDiff::Basic::InspectionTreeBuilders::Array",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::Base" => "SuperDiff::Core::AbstractInspectionTreeBuilder",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::CustomObject" => "SuperDiff::Basic::InspectionTreeBuilders::CustomObject",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::DateLike" => "SuperDiff::Basic::InspectionTreeBuilders::DateLike",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::DefaultObject" => "SuperDiff::Basic::InspectionTreeBuilders::DefaultObject",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::Hash" => "SuperDiff::Basic::InspectionTreeBuilders::Hash",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::Primitive" => "SuperDiff::Basic::InspectionTreeBuilders::Primitive",
  "SuperDiff::ObjectInspection::InspectionTreeBuilders::TimeLike" => "SuperDiff::Basic::InspectionTreeBuilders::TimeLike",
  "SuperDiff::ObjectInspection::Nodes::AsLinesWhenRenderingToLines" => "SuperDiff::Core::InspectionTreeNodes::AsLinesWhenRenderingToLines",
  "SuperDiff::ObjectInspection::Nodes::AsPrefixWhenRenderingToLines" => "SuperDiff::Core::InspectionTreeNodes::AsPrefixWhenRenderingToLines",
  "SuperDiff::ObjectInspection::Nodes::AsPreludeWhenRenderingToLines" => "SuperDiff::Core::InspectionTreeNodes::AsPreludeWhenRenderingToLines",
  "SuperDiff::ObjectInspection::Nodes::AsSingleLine" => "SuperDiff::Core::InspectionTreeNodes::AsSingleLine",
  "SuperDiff::ObjectInspection::Nodes::Base" => "SuperDiff::Core::InspectionTreeNodes::Base",
  "SuperDiff::ObjectInspection::Nodes::Inspection" => "SuperDiff::Core::InspectionTreeNodes::Inspection",
  "SuperDiff::ObjectInspection::Nodes::Nesting" => "SuperDiff::Core::InspectionTreeNodes::Nesting",
  "SuperDiff::ObjectInspection::Nodes::OnlyWhen" => "SuperDiff::Core::InspectionTreeNodes::OnlyWhen",
  "SuperDiff::ObjectInspection::Nodes::Text" => "SuperDiff::Core::InspectionTreeNodes::Text",
  "SuperDiff::ObjectInspection::Nodes::WhenEmpty" => "SuperDiff::Core::InspectionTreeNodes::WhenEmpty",
  "SuperDiff::ObjectInspection::Nodes::WhenNonEmpty" => "SuperDiff::Core::InspectionTreeNodes::WhenNonEmpty",
  "SuperDiff::ObjectInspection::Nodes::WhenRenderingToLines" => "SuperDiff::Core::InspectionTreeNodes::WhenRenderingToLines",
  "SuperDiff::ObjectInspection::Nodes::WhenRenderingToString" => "SuperDiff::Core::InspectionTreeNodes::WhenRenderingToString",
  "SuperDiff::ObjectInspection::PrefixForNextNode" => "SuperDiff::Core::PrefixForNextInspectionTreeNode",
  "SuperDiff::ObjectInspection::PreludeForNextNode" => "SuperDiff::Core::PreludeForNextInspectionTreeNode",
  "SuperDiff::OperationTreeBuilders::Array" => "SuperDiff::Basic::OperationTreeBuilders::Array",
  "SuperDiff::OperationTreeBuilders::Base" => "SuperDiff::Core::AbstractOperationTreeBuilder",
  "SuperDiff::OperationTreeBuilders::CustomObject" => "SuperDiff::Basic::OperationTreeBuilders::CustomObject",
  "SuperDiff::OperationTreeBuilders::DateLike" => "SuperDiff::Basic::OperationTreeBuilders::DateLike",
  "SuperDiff::OperationTreeBuilders::DefaultObject" => "SuperDiff::Basic::OperationTreeBuilders::DefaultObject",
  "SuperDiff::OperationTreeBuilders::Hash" => "SuperDiff::Basic::OperationTreeBuilders::Hash",
  "SuperDiff::OperationTreeBuilders::MultilineString" => "SuperDiff::Basic::OperationTreeBuilders::MultilineString",
  "SuperDiff::OperationTreeBuilders::TimeLike" => "SuperDiff::Basic::OperationTreeBuilders::TimeLike",
  "SuperDiff::OperationTreeFlatteners::Array" => "SuperDiff::Basic::OperationTreeFlatteners::Array",
  "SuperDiff::OperationTreeFlatteners::Base" => "SuperDiff::Core::AbstractOperationTreeFlattener",
  "SuperDiff::OperationTreeFlatteners::Collection" => "SuperDiff::Basic::OperationTreeFlatteners::Collection",
  "SuperDiff::OperationTreeFlatteners::CustomObject" => "SuperDiff::Basic::OperationTreeFlatteners::CustomObject",
  "SuperDiff::OperationTreeFlatteners::DefaultObject" => "SuperDiff::Basic::OperationTreeFlatteners::DefaultObject",
  "SuperDiff::OperationTreeFlatteners::Hash" => "SuperDiff::Basic::OperationTreeFlatteners::Hash",
  "SuperDiff::OperationTreeFlatteners::MultilineString" => "SuperDiff::Basic::OperationTreeFlatteners::MultilineString",
  "SuperDiff::OperationTrees::Array" => "SuperDiff::Basic::OperationTrees::Array",
  "SuperDiff::OperationTrees::Base" => "SuperDiff::Core::AbstractOperationTree",
  "SuperDiff::OperationTrees::CustomObject" => "SuperDiff::Basic::OperationTrees::CustomObject",
  "SuperDiff::OperationTrees::DefaultObject" => "SuperDiff::Basic::OperationTrees::DefaultObject",
  "SuperDiff::OperationTrees::Hash" => "SuperDiff::Basic::OperationTrees::Hash",
  "SuperDiff::OperationTrees::MultilineString" => "SuperDiff::Basic::OperationTrees::MultilineString",
  "SuperDiff::Operations::BinaryOperation" => "SuperDiff::Core::BinaryOperation",
  "SuperDiff::Operations::UnaryOperation" => "SuperDiff::Core::UnaryOperation",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::CollectionContainingExactly" => "SuperDiff::RSpec::InspectionTreeBuilders::CollectionContainingExactly",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::CollectionIncluding" => "SuperDiff::RSpec::InspectionTreeBuilders::CollectionIncluding",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::Double" => "SuperDiff::RSpec::InspectionTreeBuilders::Double",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::GenericDescribableMatcher" => "SuperDiff::RSpec::InspectionTreeBuilders::GenericDescribableMatcher",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::HashIncluding" => "SuperDiff::RSpec::InspectionTreeBuilders::HashIncluding",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::InstanceOf" => "SuperDiff::RSpec::InspectionTreeBuilders::InstanceOf",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::KindOf" => "SuperDiff::RSpec::InspectionTreeBuilders::KindOf",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::ObjectHavingAttributes" => "SuperDiff::RSpec::InspectionTreeBuilders::ObjectHavingAttributes",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::Primitive" => "SuperDiff::RSpec::InspectionTreeBuilders::Primitive",
  "SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::ValueWithin" => "SuperDiff::RSpec::InspectionTreeBuilders::ValueWithin",
  "SuperDiff::RecursionGuard" => "SuperDiff::Core::RecursionGuard",
  "SuperDiff::TieredLines" => "SuperDiff::Core::TieredLines",
  "SuperDiff::TieredLinesElider" => "SuperDiff::Core::TieredLinesElider",
  "SuperDiff::TieredLinesFormatter" => "SuperDiff::Core::TieredLinesFormatter",
}

# stree-ignore
active_record_constant_remappings = {
  "SuperDiff::ActiveRecord::ObjectInspection::InspectionTreeBuilders::ActiveRecordModel" => "SuperDiff::ActiveRecord::InspectionTreeBuilders::ActiveRecordModel",
  "SuperDiff::ActiveRecord::ObjectInspection::InspectionTreeBuilders::ActiveRecordRelation" => "SuperDiff::ActiveRecord::InspectionTreeBuilders::ActiveRecordRelation",
}

# stree-ignore
active_support_constant_remappings = {
  "SuperDiff::ActiveSupport::ObjectInspection::InspectionTreeBuilders::HashWithIndifferentAccess" => "SuperDiff::ActiveSupport::InspectionTreeBuilders::HashWithIndifferentAccess",
  "SuperDiff::ActiveSupport::ObjectInspection::InspectionTreeBuilders::OrderedOptions" => "SuperDiff::ActiveSupport::InspectionTreeBuilders::OrderedOptions",
}

common_constant_remappings.each do |old_constant_name, new_constant_name|
  RSpec.describe old_constant_name, type: :unit do
    it "maps to #{new_constant_name}" do
      capture_warnings do
        expect(Object.const_get(old_constant_name)).to be(
          Object.const_get(new_constant_name)
        )
      end
    end

    it "points users to #{new_constant_name} instead" do
      expect(old_constant_name).to be_deprecated_in_favor_of(new_constant_name)
    end
  end
end

active_record_constant_remappings.each do |old_constant_name, new_constant_name|
  RSpec.describe old_constant_name, type: :unit, active_record: true do
    it "maps to #{new_constant_name}" do
      capture_warnings do
        expect(Object.const_get(old_constant_name)).to be(
          Object.const_get(new_constant_name)
        )
      end
    end

    it "points users to #{new_constant_name} instead" do
      expect(old_constant_name).to be_deprecated_in_favor_of(new_constant_name)
    end
  end
end

active_support_constant_remappings.each do |old_constant_name, new_constant_name|
  RSpec.describe old_constant_name, type: :unit, active_support: true do
    it "maps to #{new_constant_name}" do
      capture_warnings do
        expect(Object.const_get(old_constant_name)).to be(
          Object.const_get(new_constant_name)
        )
      end
    end

    it "points users to #{new_constant_name} instead" do
      expect(old_constant_name).to be_deprecated_in_favor_of(new_constant_name)
    end
  end
end

RSpec.describe "SuperDiff::Differs::Main.call", type: :unit do
  it "maps to SuperDiff.diff" do
    capture_warnings do
      diff_before = SuperDiff::Differs::Main.call(1, 2)
      diff_after = SuperDiff.diff(1, 2)
      expect(diff_before).to eq(diff_after)
    end
  end
end

RSpec.describe "SuperDiff::OperationTreeBuilders::Main.call", type: :unit do
  it "maps to SuperDiff.build_operation_tree_for" do
    capture_warnings do
      operation_tree_builder_before =
        SuperDiff::OperationTreeBuilders::Main.call(1, 2)
      operation_tree_builder_after = SuperDiff.build_operation_tree_for(1, 2)
      expect(operation_tree_builder_before).to eq(operation_tree_builder_after)
    end
  end
end

RSpec.describe "SuperDiff::OperationTrees::Main.call", type: :unit do
  it "maps to SuperDiff.find_operation_tree_for" do
    capture_warnings do
      operation_tree_before =
        SuperDiff::OperationTrees::Main.call(%i[foo bar baz])
      operation_tree_after = SuperDiff.find_operation_tree_for(%i[foo bar baz])
      expect(operation_tree_before).to eq(operation_tree_after)
    end
  end
end
