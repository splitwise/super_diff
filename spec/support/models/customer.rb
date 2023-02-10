module SuperDiff
  module Test
    class Customer
      attr_reader :name, :shipping_address, :phone

      def initialize(name:, shipping_address:, phone:)
        @name = name
        @shipping_address = shipping_address
        @phone = phone
      end

      def ==(other)
        other.is_a?(self.class) && other.name == name &&
          other.shipping_address == shipping_address && other.phone == phone
      end

      def attributes_for_super_diff
        { name: name, shipping_address: shipping_address, phone: phone }
      end
    end
  end
end
