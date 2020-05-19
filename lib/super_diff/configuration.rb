module SuperDiff
  class Configuration
    attr_reader(
      :extra_differ_classes,
      :extra_operation_sequence_classes,
      :extra_operational_sequencer_classes,
      :extra_diff_formatter_classes,
      :extra_inspector_classes,
    )

    def initialize
      @extra_differ_classes = [].freeze
      @extra_operation_sequence_classes = [].freeze
      @extra_operational_sequencer_classes = [].freeze
      @extra_diff_formatter_classes = [].freeze
      @extra_inspector_classes = [].freeze
    end

    def add_extra_differ_classes(*classes)
      @extra_differ_classes = (@extra_differ_classes + classes).freeze
    end
    alias_method :add_extra_differ_class, :add_extra_differ_classes

    def add_extra_operational_sequencer_classes(*classes)
      @extra_operational_sequencer_classes =
        (@extra_operational_sequencer_classes + classes).freeze
    end
    alias_method(
      :add_extra_operational_sequencer_class,
      :add_extra_operational_sequencer_classes,
    )

    def add_extra_operation_sequence_classes(*classes)
      @extra_operation_sequence_classes =
        (@extra_operation_sequence_classes + classes).freeze
    end
    alias_method(
      :add_extra_operation_sequence_class,
      :add_extra_operation_sequence_classes,
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
  end
end
