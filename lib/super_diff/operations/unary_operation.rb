module SuperDiff
  module Operations
    class UnaryOperation
      extend AttrExtras.mixin

      rattr_initialize %i[name! collection! key! value! index!]
    end
  end
end
