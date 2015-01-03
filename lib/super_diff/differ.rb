module SuperDiff
  class Differ
    module Helpers
      def type_of(value)
        case value
          when Fixnum then :number
          else value.class.to_s.downcase.to_sym
        end
      end

      def value_change_for(value)
        change = {:value => value, :type => type_of(value)}
        change[:size] = value.size if value.is_a?(Enumerable)
        change
      end

      def populate_common!(change)
        elements = change[:elements]
        if elements[:old] && elements[:new]
          elements[:common] = {}
          elements[:old].keys.each do |key|
            if elements[:new].has_key?(key)
              elements[:common][key] = (elements[:new][key] == elements[:old][key]) ? elements[:new][key] : nil
            end
          end
        end
      end
    end

    class LCSCallbacks
      include Helpers

      attr_reader :hunks

      def initialize(differ)
        @differ = differ
        @hunks = []
        @hunk = []
      end

      def match(event)
        receive_event(event)
      end

      def discard_a(event)
        receive_event(event)
      end

      def discard_b(event)
        receive_event(event)
      end

      def change(event)
        receive_event(event) do |change|
          elements = change[:elements]
          # Split the change into a missing and a surplus
          missing = {
            :state => :missing,
            :elements => {
              :old => elements[:old],
              :new => nil,
              :common => nil
            }
          }
          surplus = {
            :state => :surplus,
            :elements => {
              :old => nil,
              :new => elements[:new],
              :common => nil
            }
          }
          subhunks = []
          if (
            elements[:common] and
            type = elements[:common][:type] and
            @differ.respond_to?("diff_#{type}")
          )
            equal, subhunks = @differ.__send__("diff_#{type}", elements[:old][:value], elements[:new][:value])
          end
          [[missing, surplus], subhunks]
        end
      end

      def finish
        flush_hunk
      end

      def elements_equal?
        @hunks.size == 1 && @hunks[0][0] == :equal
      end

    private
      def receive_event(event)
        change = event_to_change(event)
        item = block_given? ? yield(change) : change
        flush_hunk if @hunk_state && (
          @hunk_state == :equal && change[:state] != :equal ||
          @hunk_state != :equal && change[:state] == :equal
        )
        add_change(item, change)
      end

      def add_change(item, change)
        @hunk << item
        @hunk_state ||= (change[:state] == :equal) ? :equal : :inequal
      end

      def flush_hunk
        @hunks << [@hunk_state, @hunk]
        @hunk_state = nil
        @hunk = []
      end

      def event_to_change(event)
        event = Diff::LCS::ContextChange.simplify(event)
        change = { :elements => {:old => nil, :new => nil, :common => nil} }
        change[:state] = case event.action
          when "-" then :missing
          when "+" then :surplus
          when "=" then :equal
          when "!" then :inequal
        end
        if event.old_element
          change[:elements][:old] = value_change_for(event.old_element).merge(:key => event.old_position)
        end
        if event.new_element
          change[:elements][:new] = value_change_for(event.new_element).merge(:key => event.new_position)
        end
        populate_common!(change)
        change
      end
    end

    include Helpers

    def diff!(old_element, new_element)
      @change = diff(old_element, new_element)
      self
    end

    def diff(old_element, new_element)
      change = {:elements => {:old => nil, :new => nil, :common => nil}}
      change[:elements][:old] = value_change_for(old_element) if old_element
      change[:elements][:new] = value_change_for(new_element) if new_element
      populate_common!(change)
      common_type = change[:elements][:common] && change[:elements][:common][:type]

      diff_method = "diff_#{common_type}"
      if common_type && respond_to?(diff_method, true)
        equal, details = __send__(diff_method, old_element, new_element)
      else
        equal = (old_element == new_element)
      end

      if old_element && new_element
        change[:state] = (equal ? :equal : :inequal)
      elsif old_element
        change[:state] = :missing
      elsif new_element
        change[:state] = :surplus
      end
      change[:details] = details if details
      change
    end

    # TODO: Useful?
    def report_to(stdout, change=@change)
      Reporter.new(stdout).report(change)
    end
    alias :report :report_to

    #---

    def diff_array(old_element, new_element)
      callbacks = LCSCallbacks.new(self)
      Diff::LCS.traverse_balanced(old_element, new_element, callbacks)
      callbacks.finish
      [callbacks.elements_equal?, callbacks.hunks]
    end

    def diff_hash(old_element, new_element)
      callbacks = LCSCallbacksHash.new(self)
      Diff::LCS.traverse_balanced(old_element, new_element, callbacks)
      callbacks.finish
      [callbacks.elements_equal?, callbacks.hunks]
    end

=begin
    def diff_hash(old_element, new_element)
      equal = true
      hunks = []
      hunk = []
      hunk_state = nil
      old_element.keys.each do |k|
        subchange = diff(old_element[k], new_element[k])
        if (
          hunk_state &&
          (
            (hunk_state == :equal && subchange[:state] != :equal) ||
            (hunk_state != :equal && subchange[:state] == :equal)
          )
        )
          hunks << hunk
          hunk = []
        end
        if subchange[:inequal]
          missing = {
            :state => :missing,
            :elements => {
              :old => subchange[:elements][:old],
              :new => nil,
              :common => nil
            }
          }
          surplus = {
            :state => :surplus,
            :elements => {
              :old => nil,
              :new => subchange[:elements][:new],
              :common => nil
            }
          }
          hunk << [ [missing, surplus], subchange[:details] ]
        else
          hunk << [ subchange, [] ]
        end
        hunk_state ||= (change[:state] == :equal) ? :equal : :inequal
        equal &&= (subchange[:state] == :equal)
      end
      if hunk_state != :inequal
        hunks << hunk
        hunk = []
      end
      (new_element.keys - old_element.keys).each do |k|
        equal = false
        subchange = diff(nil, new_element[k])
        details << [k, subchange]
      end
      [equal, details]
    end
=end
  end
end