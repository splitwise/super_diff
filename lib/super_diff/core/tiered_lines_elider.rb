# frozen_string_literal: true

module SuperDiff
  module Core
    class TieredLinesElider
      SIZE_OF_ELISION = 1

      extend AttrExtras.mixin
      include Helpers

      method_object :lines

      def call
        all_lines_are_changed_or_unchanged? ? lines : elided_lines
      end

      private

      def all_lines_are_changed_or_unchanged?
        panes.size == 1 && panes.first.range == Range.new(0, lines.length - 1)
      end

      def elided_lines
        boxes_to_elide
          .reverse
          .reduce(lines) do |lines_with_elisions, box|
            with_box_elided(box, lines_with_elisions)
          end
      end

      def boxes_to_elide
        @boxes_to_elide ||=
          panes_to_consider_for_eliding.reduce([]) do |array, pane|
            array + (find_boxes_to_elide_within(pane) || [])
          end
      end

      def panes_to_consider_for_eliding
        panes.select { |pane| pane.type == :clean && pane.range.size > maximum }
      end

      def panes
        @panes ||=
          BuildPanes.call(dirty_panes: dirty_panes, lines: lines)
      end

      def dirty_panes
        @dirty_panes ||=
          lines
          .each_with_index
          .reject { |line, _index| line.type == :noop }
          .reduce([]) do |panes, (_, index)|
            if !panes.empty? && panes.last.range.end == index - 1
              panes[0..-2] + [panes[-1].extended_to(index)]
            else
              panes + [Pane.new(type: :dirty, range: index..index)]
            end
          end
      end

      def with_box_elided(box, lines)
        box_at_start_of_lines =
          box.range.begin == if lines.first.complete_bookend?
                               1
                             else
                               0
                             end

        box_at_end_of_lines =
          box.range.end == if lines.last.complete_bookend?
                             lines.size - 2
                           else
                             lines.size - 1
                           end

        if one_dimensional_line_tree? && outermost_box?(box)
          if box_at_start_of_lines
            with_start_of_box_elided(box, lines)
          elsif box_at_end_of_lines
            with_end_of_box_elided(box, lines)
          else
            with_middle_of_box_elided(box, lines)
          end
        else
          with_subset_of_lines_elided(
            lines,
            range: box.range,
            indentation_level: box.indentation_level
          )
        end
      end

      def outermost_box?(box)
        box.indentation_level == all_indentation_levels.min
      end

      def one_dimensional_line_tree?
        all_indentation_levels.size == 1
      end

      def all_indentation_levels
        lines
          .map(&:indentation_level)
          .select(&:positive?)
          .uniq
      end

      def find_boxes_to_elide_within(pane)
        set_of_boxes =
          normalized_box_groups_at_decreasing_indentation_levels_within(pane)

        total_size_before_eliding =
          lines[pane.range].reject(&:complete_bookend?).size

        if total_size_before_eliding > maximum
          if maximum.positive?
            set_of_boxes.find do |boxes|
              total_size_after_eliding =
                total_size_before_eliding -
                boxes.sum { |box| box.range.size - SIZE_OF_ELISION }
              total_size_after_eliding <= maximum
            end
          else
            set_of_boxes[-1]
          end
        else
          []
        end
      end

      def normalized_box_groups_at_decreasing_indentation_levels_within(pane)
        box_groups_at_decreasing_indentation_levels_within(pane).map(
          &method(:filter_out_boxes_fully_contained_in_others)
        ).map(&method(:combine_congruent_boxes))
      end

      def box_groups_at_decreasing_indentation_levels_within(pane)
        boxes_within_pane = boxes.select { |box| box.fits_fully_within?(pane) }

        possible_indentation_levels =
          boxes_within_pane
          .map(&:indentation_level)
          .select(&:positive?)
          .uniq
          .sort
          .reverse

        possible_indentation_levels.map do |indentation_level|
          boxes_within_pane.select do |box|
            box.indentation_level >= indentation_level
          end
        end
      end

      def filter_out_boxes_fully_contained_in_others(boxes)
        # First, sorts boxes by beginning ascending, range descending. (Boxes may
        # never share beginnings, so the latter may be useless, but this is at least
        # sufficient if unnecessary.)
        #
        # Then, iterate through each box, keeping track of the farthest "end" of any
        # box seen so far. If the current box we are on ends before (or on) that farthest
        # end, we know there is some box earlier in the sequence that begins <= this one
        # (because of the prior sorting), and ends >= this one; that is, the current box
        # is fully contained, and we can filter it out.
        sorted = boxes.sort_by { |box| [box.range.begin, -box.range.end] }
        max_end = -1

        sorted.reject do |box|
          contained = box.range.end <= max_end
          max_end = box.range.end if box.range.end > max_end
          contained
        end
      end

      def combine_congruent_boxes(boxes)
        combine(boxes, on: :indentation_level)
      end

      def combine(spannables, on:)
        criterion = on
        spannables.reduce([]) do |combined_spannables, spannable|
          if !combined_spannables.empty? &&
             spannable.range.begin <=
             combined_spannables.last.range.end + 1 &&
             spannable.public_send(criterion) ==
             combined_spannables.last.public_send(criterion)

            combined_spannables[0..-2] +
              [combined_spannables[-1].extended_to(spannable.range.end)]
          else
            combined_spannables + [spannable]
          end
        end
      end

      def boxes
        @boxes ||= BuildBoxes.call(lines)
      end

      def with_start_of_box_elided(box, lines)
        amount_to_elide =
          if maximum.positive?
            box.range.size - maximum + SIZE_OF_ELISION
          else
            box.range.size
          end

        with_subset_of_lines_elided(
          lines,
          range:
            Range.new(box.range.begin, box.range.begin + amount_to_elide - 1),
          indentation_level: box.indentation_level
        )
      end

      def with_end_of_box_elided(box, lines)
        amount_to_elide =
          if maximum.positive?
            box.range.size - maximum + SIZE_OF_ELISION
          else
            box.range.size
          end

        range =
          if amount_to_elide.positive?
            Range.new(box.range.end - amount_to_elide + 1, box.range.end)
          else
            box.range
          end

        with_subset_of_lines_elided(
          lines,
          range: range,
          indentation_level: box.indentation_level
        )
      end

      def with_middle_of_box_elided(box, lines)
        half_of_maximum, remainder =
          if maximum.positive?
            (maximum - SIZE_OF_ELISION).divmod(2)
          else
            [0, 0]
          end

        opening_length = half_of_maximum
        closing_length = half_of_maximum + remainder

        with_subset_of_lines_elided(
          lines,
          range:
            Range.new(
              box.range.begin + opening_length,
              box.range.end - closing_length
            ),
          indentation_level: box.indentation_level
        )
      end

      def with_subset_of_lines_elided(lines, range:, indentation_level:)
        with_slice_of_array_replaced(
          lines,
          range,
          Elision.new(
            indentation_level: indentation_level,
            children: lines[range].map(&:as_elided)
          )
        )
      end

      def maximum
        SuperDiff.configuration.diff_elision_maximum || 0
      end

      class BuildPanes
        extend AttrExtras.mixin

        method_object %i[dirty_panes! lines!]

        def call
          beginning + middle + ending
        end

        private

        def beginning
          if dirty_panes.empty? || dirty_panes.first.range.begin.zero?
            []
          else
            [
              Pane.new(
                type: :clean,
                range: Range.new(0, dirty_panes.first.range.begin - 1)
              )
            ]
          end
        end

        def middle
          if dirty_panes.size == 1
            dirty_panes
          else
            dirty_panes
              .each_with_index
              .each_cons(2)
              .reduce([]) do |panes, ((pane1, _), (pane2, index2))|
                panes +
                  [
                    pane1,
                    Pane.new(
                      type: :clean,
                      range:
                        Range.new(pane1.range.end + 1, pane2.range.begin - 1)
                    )
                  ] + (index2 == dirty_panes.size - 1 ? [pane2] : [])
              end
          end
        end

        def ending
          if dirty_panes.empty? ||
             dirty_panes.last.range.end >= lines.size - 1

            []
          else
            [
              Pane.new(
                type: :clean,
                range: Range.new(dirty_panes.last.range.end + 1, lines.size - 1)
              )
            ]
          end
        end
      end

      class Pane
        extend AttrExtras.mixin

        rattr_initialize %i[type! range!]

        def extended_to(new_end)
          self.class.new(type: type, range: range.begin..new_end)
        end
      end

      class BuildBoxes
        def self.call(lines)
          builder = new(lines)
          builder.build
          builder.final_boxes
        end

        attr_reader :final_boxes

        def initialize(lines)
          @lines = lines

          @open_collection_boxes = []
          @final_boxes = []
        end

        def build
          lines.each_with_index do |line, index|
            if line.opens_collection?
              open_new_collection_box(line, index)
            elsif line.closes_collection?
              extend_working_collection_box(index)
              close_working_collection_box
            else
              extend_working_collection_box(index) if open_collection_boxes.any?
              record_item_box(line, index)
            end
          end
        end

        private

        attr_reader :lines, :open_collection_boxes

        def extend_working_collection_box(index)
          open_collection_boxes.last.extend_to(index)
        end

        def close_working_collection_box
          final_boxes << open_collection_boxes.pop
        end

        def open_new_collection_box(line, index)
          open_collection_boxes << Box.new(
            indentation_level: line.indentation_level,
            range: index..index
          )
        end

        def record_item_box(line, index)
          final_boxes << Box.new(
            indentation_level: line.indentation_level,
            range: index..index
          )
        end
      end

      class Box
        extend AttrExtras.mixin

        rattr_initialize %i[indentation_level! range!]

        def fully_contains?(other)
          range.begin <= other.range.begin && range.end >= other.range.end
        end

        def fits_fully_within?(other)
          other.range.begin <= range.begin && other.range.end >= range.end
        end

        def extended_to(new_end)
          dup.tap { |clone| clone.extend_to(new_end) }
        end

        def extend_to(new_end)
          @range = range.begin..new_end
        end
      end

      class Elision
        extend AttrExtras.mixin

        rattr_initialize %i[indentation_level! children!]

        def type
          :elision
        end

        def prefix
          ''
        end

        def value
          '# ...'
        end

        def elided?
          true
        end

        def add_comma?
          false
        end
      end
    end
  end
end
