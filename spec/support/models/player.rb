module SuperDiff
  module Test
    class Player
      attr_reader :handle, :character, :inventory, :shields, :health, :ultimate

      def initialize(
        handle:,
        character:,
        inventory:,
        shields:,
        health:,
        ultimate:
      )
        @handle = handle
        @character = character
        @inventory = inventory
        @shields = shields
        @health = health
        @ultimate = ultimate
      end

      def ==(other)
        other.is_a?(self.class) && other.handle == handle &&
          other.character == character && other.inventory == inventory &&
          other.shields == shields && other.health == health &&
          other.ultimate == ultimate
      end
    end
  end
end
