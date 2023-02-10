module SuperDiff
  module UnitTests
    def with_configuration(configuration)
      old_configuration = SuperDiff.configuration.dup
      SuperDiff.configuration.merge!(configuration)
      yield.tap { SuperDiff.configuration.merge!(old_configuration) }
    end

    def colored(*args, **opts, &block)
      SuperDiff::Helpers.style(*args, **opts, &block).to_s.chomp
    end
  end
end
