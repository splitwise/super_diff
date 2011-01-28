module SuperDiff
  class RecursiveDiffer
    class Event
      def self.from(lcs_diff_event)
        new(
          lcs_diff_event.action,
          lcs_diff_event.old_position,
          lcs_diff_event.old_element,
          lcs_diff_event.new_position,
          lcs_diff_event.new_element
        )
      end

      attr_reader :action
      attr_reader :old_position
      attr_reader :old_element
      attr_reader :new_position
      attr_reader :new_element
      attr_accessor :children

      include Comparable
      include Diff::LCS::ChangeTypeTests

      def initialize(action, old_position, old_element, new_position, new_element, children=[])
        @action = action
        @old_position = old_position
        @old_element = old_element
        @new_position = new_position
        @new_element = new_element
        @children = children
      end

      def ==(other)
        other.is_a?(self.class) and
        (@action == other.action) and
        (@old_position == other.old_position) and
        (@new_position == other.new_position) and
        (@old_element == other.old_element) and
        (@new_element == other.new_element) and
        (@children == other.children)
      end

      def <=>(other)
        [@action, @old_position, @new_position, @old_element, @new_element] <=> [other.action, other.old_position, other.new_position, other.old_element, other.new_element]
      end

      def inspect
        %Q(#<#{self.class}:#{__id__} @action=#{@action} positions=[#{@old_position},#{@new_position}] elements=[#{@old_element.inspect},#{@new_element.inspect}] @children=#{@children.inspect}>)
      end

      def pretty_print(q)
        attributes = {
          :action => @action,
          :positions => [@old_position, @new_position],
          :elements => [@old_element, @new_element],
          :children => @children
        }
        q.group(0, "#<#{self.class}", ">") {
          q.breakable " "
          q.group(1) {
            q.seplist(attributes) {|pair|
              q.text pair.first.to_s
              q.text ": "
              q.pp pair.last
            }
          }
        }
      end
    end

    class Callbacks
      attr_reader :diffs

      def initialize
        @diffs = []
      end

      def match(event)
        event = Diff::LCS::ContextChange.simplify(event)
        event = Event.from(event)
        @diffs << event
      end

      def discard_a(event)
        event = Diff::LCS::ContextChange.simplify(event)
        event = Event.from(event)
        @diffs << event
      end

      def discard_b(event)
        event = Diff::LCS::ContextChange.simplify(event)
        event = Event.from(event)
        @diffs << event
      end

      def change(event)
        event = Diff::LCS::ContextChange.simplify(event)
        event = Event.from(event)
        if Array === event.old_element && Array === event.new_element
          #puts "Array elements detected, so comparing those"
          event.children = RecursiveDiffer.diff(event.old_element, event.new_element)
          #pp :children => event.children
        end
        @diffs << event
      end
    end

    def self.diff(seq1, seq2)
      Diff::LCS.sdiff(seq1, seq2, Callbacks)
    end
  end
end