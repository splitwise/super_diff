# frozen_string_literal: true

module SuperDiff
  module Core
    module ColorizedDocumentExtensions
      def self.extended(extendee)
        extendee.singleton_class.class_eval { alias_method :normal, :text }
      end

      %i[actual border elision_marker expected header].each do |method_name|
        define_method(method_name) do |*args, **opts, &block|
          colorize(
            *args,
            **opts,
            fg: SuperDiff.configuration.public_send("#{method_name}_color"),
            &block
          )
        end
      end
    end
  end
end
