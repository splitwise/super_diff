module SuperDiff
  class GemVersion
    def initialize(version)
      @version = Gem::Version.new(version.to_s)
    end

    def <(other)
      compare?(:<, other)
    end

    def <=(other)
      compare?(:<=, other)
    end

    def ==(other)
      compare?(:==, other)
    end

    def >=(other)
      compare?(:>=, other)
    end

    def >(other)
      compare?(:>, other)
    end

    def =~(other)
      Gem::Requirement.new(other).satisfied_by?(version)
    end

    def to_s
      version.to_s
    end

    private

    attr_reader :version

    def compare?(operator, other_version)
      Gem::Requirement.new("#{operator} #{other_version}").satisfied_by?(
        version
      )
    end
  end
end
