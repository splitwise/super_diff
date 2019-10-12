module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      class Default < Base
        extend AttrExtras.mixin

        method_object :message

        def self.applies_to?(_message)
          true
        end

        def call
          message.to_s
        end
      end
    end
  end
end
