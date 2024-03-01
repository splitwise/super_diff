module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      def self.const_missing(missing_const_name)
        if missing_const_name == :Base
          warn <<~EOT
            WARNING: SuperDiff::ObjectInspection::InspectionTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
            Please use SuperDiff::Core::AbstractInspectionTreeBuilder instead.
            #{caller_locations.join("\n")}
          EOT
          Core::AbstractInspectionTreeBuilder
        elsif Basic::InspectionTreeBuilders.const_defined?(missing_const_name)
          warn <<~EOT
          WARNING: SuperDiff::ObjectInspection::InspectionTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Basic::InspectionTreeBuilders::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        EOT
          Basic::InspectionTreeBuilders.const_get(missing_const_name)
        else
          super
        end
      end
    end

    module Nodes
      def self.const_missing(missing_const_name)
        if Core::InspectionTreeNodes.const_defined?(missing_const_name)
          warn <<~EOT
            WARNING: SuperDiff::ObjectInspection::Nodes::#{missing_const_name} is deprecated and will be removed in the next major release.
            Please use SuperDiff::Core::InspectionTreeNodes::#{missing_const_name} instead.
            #{caller_locations.join("\n")}
          EOT
          Core::InspectionTreeNodes.const_get(missing_const_name)
        else
          super
        end
      end
    end

    def self.const_missing(missing_const_name)
      if missing_const_name == :PrefixForNextNode
        warn <<~EOT
          WARNING: SuperDiff::ObjectInspection::PrefixForNextNode is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::PrefixForNextInspectionTreeNode instead.
          #{caller_locations.join("\n")}
        EOT
        Core::PrefixForNextInspectionTreeNode
      elsif missing_const_name == :PreludeForNextNode
        warn <<~EOT
          WARNING: SuperDiff::ObjectInspection::PreludeForNextNode is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::PreludeForNextInspectionTreeNode instead.
          #{caller_locations.join("\n")}
        EOT
        Core::PreludeForNextInspectionTreeNode
      elsif Core.const_defined?(missing_const_name)
        warn <<~EOT
          WARNING: SuperDiff::ObjectInspection::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        EOT
        Core.const_get(missing_const_name)
      else
        super
      end
    end
  end
end
