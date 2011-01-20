module SuperDiff
  class Differ
    def initialize
    end
    
    def diff(expected, actual)
      {
        :expected => {:value => expected, :class => expected.class},
        :actual => {:value => actual, :class => actual.class},
        :same_class => (expected.class == actual.class)
      }
    end
  end
end