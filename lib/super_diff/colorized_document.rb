module SuperDiff
  class ColorizedDocument < Csi::ColorizedDocument
    alias_method :normal, :text
    # FIXME: Backward compatibility
    alias_method :plain, :normal

    def deleted(*args, **opts, &block)
      colorize(*args, **opts, fg: :red, &block)
    end

    def inserted(*args, **opts, &block)
      colorize(*args, **opts, fg: :green, &block)
    end
  end
end
