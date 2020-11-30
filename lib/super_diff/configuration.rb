module SuperDiff
  class Configuration
    attr_reader(
      :extra_differ_classes,
      :extra_operation_tree_builder_classes,
      :extra_operation_tree_classes,
      :extra_diff_formatter_classes,
      :extra_inspector_classes,
      :alpha_color,
      :beta_color,
      :border_color,
      :header_color,
    )

    def initialize
      @extra_differ_classes = [].freeze
      @extra_operation_tree_builder_classes = [].freeze
      @extra_operation_tree_classes = [].freeze
      @extra_diff_formatter_classes = [].freeze
      @extra_inspector_classes = [].freeze
      @alpha_color = :magenta
      @beta_color = :yellow
      @border_color = :blue
      @header_color = :white
    end

    def add_extra_differ_classes(*classes)
      @extra_differ_classes = (@extra_differ_classes + classes).freeze
    end
    alias_method :add_extra_differ_class, :add_extra_differ_classes

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

    def add_extra_diff_formatter_classes(*classes)
      @extra_diff_formatter_classes =
        (@extra_diff_formatter_classes + classes).freeze
    end
    alias_method(
      :add_extra_diff_formatter_class,
      :add_extra_diff_formatter_classes,
    )

    def add_extra_inspector_classes(*classes)
      @extra_inspector_classes =
        (@extra_inspector_classes + classes).freeze
    end
    alias_method(
      :add_extra_inspector_class,
      :add_extra_inspector_classes,
    )

    def set_alpha_color(color)
      @alpha_color = color
    end
    alias_method(
      :set_expected_color,
      :set_alpha_color
    )

    def set_beta_color(color)
      @beta_color = color
    end
    alias_method(
      :set_actual_color,
      :set_beta_color
    )

    def set_border_color(color)
      @border_color = color
    end

    def set_header_color(color)
      @header_color = color
    end
  end
end
