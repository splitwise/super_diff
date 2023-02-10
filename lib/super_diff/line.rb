module SuperDiff
  class Line
    extend AttrExtras.mixin

    ICONS = { delete: "-", insert: "+", noop: " " }.freeze
    COLORS = { insert: :actual, delete: :expected, noop: :plain }.freeze

    rattr_initialize(
      [
        :type!,
        :indentation_level!,
        :value!,
        prefix: "",
        add_comma: false,
        children: [],
        elided: false,
        collection_bookend: nil,
        complete_bookend: nil
      ]
    )
    attr_query :add_comma?
    attr_query :elided?

    def clone_with(overrides = {})
      self.class.new(
        type: type,
        indentation_level: indentation_level,
        prefix: prefix,
        value: value,
        add_comma: add_comma?,
        children: children,
        elided: elided?,
        collection_bookend: collection_bookend,
        complete_bookend: complete_bookend,
        **overrides
      )
    end

    def icon
      ICONS.fetch(type)
    end

    def color
      COLORS.fetch(type)
    end

    def with_comma
      clone_with(add_comma: true)
    end

    def as_elided
      clone_with(elided: true)
    end

    def with_value_prepended(prelude)
      clone_with(value: prelude + value)
    end

    def with_value_appended(suffix)
      clone_with(value: value + suffix)
    end

    def prefixed_with(prefix)
      clone_with(prefix: prefix + self.prefix)
    end

    def with_complete_bookend(complete_bookend)
      clone_with(complete_bookend: complete_bookend)
    end

    def opens_collection?
      collection_bookend == :open
    end

    def closes_collection?
      collection_bookend == :close
    end

    def complete_bookend?
      complete_bookend != nil
    end
  end
end
