module SuperDiff
  class Configuration
    attr_reader(
      :extra_diff_formatter_classes,
      :extra_differ_classes,
      :extra_inspector_classes,
      :extra_operation_tree_builder_classes,
      :extra_operation_tree_classes,
    )
    attr_accessor(
      :actual_color,
      :border_color,
      :expected_color,
      :header_color,
    )

    def initialize
      @actual_color = :yellow
      @border_color = :blue
      @expected_color = :magenta
      @extra_diff_formatter_classes = [].freeze
      @extra_differ_classes = [].freeze
      @extra_inspector_classes = [].freeze
      @extra_operation_tree_builder_classes = [].freeze
      @extra_operation_tree_classes = [].freeze
      @header_color = :white
    end

    def add_extra_diff_formatter_classes(*classes)
      @extra_diff_formatter_classes =
        (@extra_diff_formatter_classes + classes).freeze
    end
    alias_method(
      :add_extra_diff_formatter_class,
      :add_extra_diff_formatter_classes,
    )

    def add_extra_differ_classes(*classes)
      @extra_differ_classes = (@extra_differ_classes + classes).freeze
    end
    alias_method :add_extra_differ_class, :add_extra_differ_classes

    def add_extra_inspector_classes(*classes)
      @extra_inspector_classes =
        (@extra_inspector_classes + classes).freeze
    end
    alias_method(
      :add_extra_inspector_class,
      :add_extra_inspector_classes,
    )

    def add_extra_operation_tree_builder_classes(*classes)
      @extra_operation_tree_builder_classes =
        (@extra_operation_tree_builder_classes + classes).freeze
    end
    alias_method(
      :add_extra_operation_tree_builder_class,
      :add_extra_operation_tree_builder_classes,
    )

    def add_extra_operation_tree_classes(*classes)
      @extra_operation_tree_classes =
        (@extra_operation_tree_classes + classes).freeze
    end
    alias_method(
      :add_extra_operation_tree_class,
      :add_extra_operation_tree_classes,
    )
  end
end
