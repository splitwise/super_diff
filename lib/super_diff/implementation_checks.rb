module SuperDiff
  module ImplementationChecks
    protected def unimplemented_instance_method!
      raise(
        NotImplementedError,
        "#{self.class} must implement ##{caller_locations(1, 1).first.label}",
        caller(1)
      )
    end

    protected def unimplemented_class_method!
      raise(
        NotImplementedError,
        "#{self} must implement .#{caller_locations(1, 1).first.label}",
        caller(1)
      )
    end
  end
end
