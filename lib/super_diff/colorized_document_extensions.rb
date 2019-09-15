module SuperDiff
  module ColorizedDocumentExtensions
    def self.extended(extendee)
      extendee.singleton_class.class_eval do
        alias_method :normal, :text
      end
    end

    def deleted(*args, **opts, &block)
      colorize(*args, **opts, fg: :red, &block)
    end

    def inserted(*args, **opts, &block)
      colorize(*args, **opts, fg: :green, &block)
    end
  end
end
