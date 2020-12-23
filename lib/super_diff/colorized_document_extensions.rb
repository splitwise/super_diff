module SuperDiff
  module ColorizedDocumentExtensions
    def self.extended(extendee)
      extendee.singleton_class.class_eval do
        alias_method :normal, :text
      end
    end

    def expected(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff.configuration.expected_color, &block)
    end

    def actual(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff.configuration.actual_color, &block)
    end
  end
end
