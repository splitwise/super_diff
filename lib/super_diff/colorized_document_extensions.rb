module SuperDiff
  module ColorizedDocumentExtensions
    def self.extended(extendee)
      extendee.singleton_class.class_eval do
        alias_method :normal, :text
      end
    end

    def alpha(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff.configuration.alpha_color, &block)
    end

    def beta(*args, **opts, &block)
      colorize(*args, **opts, fg: SuperDiff.configuration.beta_color, &block)
    end
  end
end
