require "prettyprint"

module SuperDiff
  module PrettyPrinters
    class Array
      def self.pretty_print(array)
        new(array).pretty_print
      end

      def initialize(array)
        @array = array
      end

      def pretty_print
        if array.empty?
          "[]"
        else
          lines = []
          lines << "["

          array.each_with_index do |value, index|
            line = ""
            line << "  " + value.inspect

            if index != array.length-1
              line << ","
            end

            lines << line
          end

          lines << "]"

          lines.join("\n")
        end

        # PrettyPrint.format do |q|
          # breakable_group(q, open: "[", close: "]") do
            # array.each_with_index do |value, index|
              # q.text value.inspect

              # if index != array.length-1
                # q.text ","
                # q.breakable
              # end
            # end
          # end
        # end
      end

      def breakable_group(q, open:, close:, indent: 2)
        q.text open, open.length
        q.group_sub do
          q.nest(indent) do
            q.breakable("")
            yield
          end
        end
        q.breakable("")
        q.text close, close.length
      end

      private

      attr_reader :array, :output
    end
  end
end
