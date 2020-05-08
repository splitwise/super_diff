module SuperDiff
  class Configuration
    attr_reader(
      :extra_differ_classes,
      :extra_operation_sequence_classes,
      :extra_operational_sequencer_classes,
      :extra_diff_formatter_classes,
    )

    def initialize
      @extra_differ_classes = [].freeze
      @extra_operation_sequence_classes = [].freeze
      @extra_operational_sequencer_classes = [].freeze
      @extra_diff_formatter_classes = [].freeze
    end

    def add_extra_differ_class(klass)
      @extra_differ_classes = (@extra_differ_classes + [klass]).freeze
    end

    def add_extra_operation_sequence_class(klass)
      @extra_operation_sequence_classes =
        (@extra_operation_sequence_classes + [klass]).freeze
    end

    def add_extra_operational_sequencer_class(klass)
      @extra_operational_sequencer_classes =
        (@extra_operational_sequencer_classes + [klass]).freeze
    end

    def add_extra_diff_formatter_class(klass)
      @extra_diff_formatter_classes =
        (@extra_diff_formatter_classes + [klass]).freeze
    end
  end
end
