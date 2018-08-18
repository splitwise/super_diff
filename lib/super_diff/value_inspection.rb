module SuperDiff
  class ValueInspection
    attr_reader :beginning, :middle, :end

    def initialize(args)
      @beginning = args.fetch(:beginning)
      @middle = args.fetch(:middle)
      @end = args.fetch(:end)
    end
  end
end
