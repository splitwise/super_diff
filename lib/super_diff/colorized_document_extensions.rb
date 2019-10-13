module SuperDiff
  module ColorizedDocumentExtensions
    def self.extended(extendee)
      extendee.singleton_class.class_eval do
        alias_method :normal, :text
      end
    end

    def alpha(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff::COLORS.fetch(:alpha), &block)
    end

    def beta(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff::COLORS.fetch(:beta), &block)
    end

    def highlight(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff::COLORS.fetch(:highlight), &block)
    end
  end
end
