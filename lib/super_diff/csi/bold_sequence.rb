# frozen_string_literal: true

module SuperDiff
  module Csi
    class BoldSequence
      def to_s
        "\e[1m"
      end
    end
  end
end
