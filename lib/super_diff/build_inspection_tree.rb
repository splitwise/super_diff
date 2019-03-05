module SuperDiff
  class BuildInspectionTree
    def self.call(args)
      new(args).call
    end

    def initialize(opening:, middle:, closing:, level: 0)
      @opening = opening
      @middle = middle
      @closing = closing
      @level = level
    end

    def call
      InspectionTree.new([
        {
          level: level,
          value: opening,
          location: "opening",
        },
        *exploded_middle,
        {
          level: level,
          value: closing,
          location: "closing",
        },
      ])
    end

    private

    attr_reader :opening, :middle, :closing, :level

    def exploded_middle
      middle.map.with_index do |value, i|
        # node_value =
          # if value.is_a?(Array)
            # prefix, subinspection = value
            # subtree = BuildInspectionTree.call(
              # subinspection,
              # level: level + 1,
            # )
            # InspectionTree.new([
              # subtree[0].merge(value: prefix + subtree.first[:value]),
              # *subtree[1..-1],
            # ])
          # else
            # value
          # end

        {
          level: level + 1,
          value: value,
          first_item: i.zero?,
          last_item: (i == middle.size - 1),
          location: "middle",
        }
      end
    end
  end
end
