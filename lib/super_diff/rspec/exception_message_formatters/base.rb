module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      class Base
        extend AttrExtras.mixin

        def self.applies_to?(message)
          regex.match?(message.to_s)
        end

        def self.regex
          raise NotImplementedError.new(
            "Please implement .regex in your subclass",
          )
        end

        attr_private :message

        def self.call(message)
          new(message).call
        end

        def initialize(message)
          @message = message.to_s
        end

        def call
          ranges.map(&:to_s).join
        end

        protected

        def ranges
          @_ranges ||= StringTagger.call(
            string: message,
            regex: self.class.regex,
            colors: colors,
          )
        end
      end
    end
  end
end
