module SuperDiff
  class Configuration
    attr_reader(
      :extra_diff_formatter_classes,
      :extra_differ_classes,
      :extra_inspection_tree_builder_classes,
      :extra_operation_tree_builder_classes,
      :extra_operation_tree_classes
    )
    attr_accessor(
      :actual_color,
      :border_color,
      :color_enabled,
      :diff_elision_enabled,
      :diff_elision_maximum,
      :elision_marker_color,
      :expected_color,
      :header_color,
      :key_enabled
    )

    def initialize(options = {})
      @actual_color = :yellow
      @border_color = :blue
      @color_enabled = color_enabled_by_default?
      @diff_elision_enabled = false
      @diff_elision_maximum = 0
      @elision_marker_color = :cyan
      @expected_color = :magenta
      @extra_diff_formatter_classes = [].freeze
      @extra_differ_classes = [].freeze
      @extra_inspection_tree_builder_classes = [].freeze
      @extra_operation_tree_builder_classes = [].freeze
      @extra_operation_tree_classes = [].freeze
      @header_color = :white
      @key_enabled = true

      merge!(options)
    end

    def initialize_dup(original)
      super
      @extra_differ_classes = original.extra_differ_classes.dup.freeze
      @extra_operation_tree_builder_classes =
        original.extra_operation_tree_builder_classes.dup.freeze
      @extra_operation_tree_classes =
        original.extra_operation_tree_classes.dup.freeze
      @extra_inspection_tree_builder_classes =
        original.extra_inspection_tree_builder_classes.dup.freeze
    end

    def color_enabled?
      @color_enabled
    end

    def diff_elision_enabled?
      @diff_elision_enabled
    end

    def key_enabled?
      @key_enabled
    end

    def merge!(configuration_or_options)
      options =
        if configuration_or_options.is_a?(self.class)
          configuration_or_options.to_h
        else
          configuration_or_options
        end

      options.each { |key, value| instance_variable_set("@#{key}", value) }

      updated
    end

    def updated
      SuperDiff::Csi.color_enabled = color_enabled?
    end

    def add_extra_diff_formatter_classes(*classes)
      @extra_diff_formatter_classes =
        (@extra_diff_formatter_classes + classes).freeze
    end
    alias_method(
      :add_extra_diff_formatter_class,
      :add_extra_diff_formatter_classes
    )

    def add_extra_differ_classes(*classes)
      @extra_differ_classes = (@extra_differ_classes + classes).freeze
    end
    alias_method :add_extra_differ_class, :add_extra_differ_classes

    def add_extra_inspection_tree_builder_classes(*classes)
      @extra_inspection_tree_builder_classes =
        (@extra_inspection_tree_builder_classes + classes).freeze
    end
    alias_method(
      :add_extra_inspection_tree_builder_class,
      :add_extra_inspection_tree_builder_classes
    )

    def add_extra_operation_tree_builder_classes(*classes)
      @extra_operation_tree_builder_classes =
        (@extra_operation_tree_builder_classes + classes).freeze
    end
    alias_method(
      :add_extra_operation_tree_builder_class,
      :add_extra_operation_tree_builder_classes
    )

    def add_extra_operation_tree_classes(*classes)
      @extra_operation_tree_classes =
        (@extra_operation_tree_classes + classes).freeze
    end
    alias_method(
      :add_extra_operation_tree_class,
      :add_extra_operation_tree_classes
    )

    def to_h
      {
        actual_color: actual_color,
        border_color: border_color,
        color_enabled: color_enabled?,
        diff_elision_enabled: diff_elision_enabled?,
        diff_elision_maximum: diff_elision_maximum,
        elision_marker_color: elision_marker_color,
        expected_color: expected_color,
        extra_diff_formatter_classes: extra_diff_formatter_classes.dup,
        extra_differ_classes: extra_differ_classes.dup,
        extra_inspection_tree_builder_classes:
          extra_inspection_tree_builder_classes.dup,
        extra_operation_tree_builder_classes:
          extra_operation_tree_builder_classes.dup,
        extra_operation_tree_classes: extra_operation_tree_classes.dup,
        header_color: header_color,
        key_enabled: key_enabled?
      }
    end

    private

    def color_enabled_by_default?
      ENV["CI"] == "true" || $stdout.respond_to?(:tty?) && $stdout.tty?
    end
  end
end
