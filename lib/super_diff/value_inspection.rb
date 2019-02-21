module SuperDiff
  class ValueInspection
    def self.build_tree(inspection, level: 0)
      exploded_middle = inspection.middle.flat_map.with_index do |value, i|
        node_value =
          if value.is_a?(self)
            build_tree(value, level: level + 1)
          elsif value.is_a?(Array)
            prefix, subinspection = value
            subtree = build_tree(subinspection, level: level + 1)
            [
              subtree[0].merge(value: prefix + subtree.first[:value]),
              *subtree[1..-1]
            ]
          else
            value
          end

        {
          level: level + 1,
          value: node_value,
          first_item: (i == 0),
          last_item: (i == inspection.middle.size - 1),
          location: "middle",
        }
      end

      [
        { level: level, value: inspection.beginning, location: "beginning" },
        *exploded_middle,
        { level: level, value: inspection.end, location: "end" },
      ]
    end

    attr_reader :beginning, :middle, :end

    def initialize(args)
      @beginning = args.fetch(:beginning)
      @middle = args.fetch(:middle)
      @end = args.fetch(:end)
    end

    def build_tree(level: 0)
      self.class.build_tree(self, level: level)
    end
  end
end
