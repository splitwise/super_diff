module SuperDiff
  module ObjectInspection
    module Inspectors
      class TimeLike < Base
        def self.applies_to?(value)
          SuperDiff.time_like?(value)
        end

        protected

        def inspection_tree
          InspectionTree.new do
            add_text do |time|
              "#<#{time.class} "
            end

            when_singleline do
              add_text do |time|
                time.strftime("%Y-%m-%d %H:%M:%S") +
                  (time.subsec == 0 ? "" : "+#{time.subsec.inspect}") +
                  " " + time.strftime("%:z") +
                  (time.zone ? " (#{time.zone})" : "")
              end
            end

            when_multiline do
              add_text "{"

              nested do |time|
                add_break " "

                insert_separated_list(
                  [
                    :year,
                    :month,
                    :day,
                    :hour,
                    :min,
                    :sec,
                    :subsec,
                    :zone,
                    :utc_offset
                  ],
                  separator: ","
                ) do |name|
                  add_text name.to_s
                  add_text ": "
                  add_inspection_of time.public_send(name)
                end
              end

              add_break

              add_text "}"
            end

            add_text ">"
          end
        end
      end
    end
  end
end
