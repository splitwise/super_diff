module SuperDiff
  module Operations
    class UnaryOperation
      extend AttrExtras.mixin

      rattr_initialize [:name!, :collection!, :key!, :value!, :index!]
    end
  end
end
