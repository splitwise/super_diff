module SuperDiff
  module Test
    module OutputHelpers
      def self.bookended(text)
        divider("START") + text + "\n" + divider("END")
      end

      def self.divider(title = "")
        total_length = 72
        start_length = 3

        string = ""
        string << ("-" * start_length)
        string << title
        string << "-" * (total_length - start_length - title.length)
        string << "\n"
        string
      end
    end
  end
end
