# frozen_string_literal: true

module SuperDiff
  module Core
    class UnaryOperation
      extend AttrExtras.mixin

      rattr_initialize %i[name! collection! key! value! index!]
    end
  end
end
