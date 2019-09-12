module SuperDiff
  module OperationSequences
    autoload :Array, "super_diff/operation_sequences/array"
    autoload :Base, "super_diff/operation_sequences/base"
    autoload :CustomObject, "super_diff/operation_sequences/custom_object"
    autoload :DefaultObject, "super_diff/operation_sequences/default_object"
    autoload :Hash, "super_diff/operation_sequences/hash"
  end
end
