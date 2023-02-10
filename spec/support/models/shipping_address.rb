module SuperDiff
  module Test
    class ShippingAddress
      attr_reader :line_1, :line_2, :city, :state, :zip

      def initialize(line_1:, line_2:, city:, state:, zip:)
        @line_1 = line_1
        @line_2 = line_2
        @city = city
        @state = state
        @zip = zip
      end

      def ==(other)
        other.is_a?(self.class) && other.line_1 == line_1 &&
          other.line_2 == line_2 && other.city == city &&
          other.state == state && other.zip == zip
      end

      def attributes_for_super_diff
        { line_1: line_1, line_2: line_2, city: city, state: state, zip: zip }
      end
    end
  end
end
