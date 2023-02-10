module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class TimeLike < Base
        def self.applies_to?(value)
          SuperDiff.time_like?(value)
        end

        def call
          InspectionTree.new do
            as_lines_when_rendering_to_lines(collection_bookend: :open) do
              add_text { |time| "#<#{time.class} " }

              when_rendering_to_lines { add_text "{" }
            end

            when_rendering_to_string do
              add_text do |time|
                time.strftime("%Y-%m-%d %H:%M:%S") +
                  (time.subsec == 0 ? "" : "+#{time.subsec.inspect}") + " " +
                  time.strftime("%:z") + (time.zone ? " (#{time.zone})" : "")
              end
            end

            when_rendering_to_lines do
              nested do |time|
                insert_separated_list(
                  %i[year month day hour min sec subsec zone utc_offset]
                ) do |name|
                  add_text name.to_s
                  add_text ": "
                  add_inspection_of time.public_send(name)
                end
              end
            end

            as_lines_when_rendering_to_lines(collection_bookend: :close) do
              when_rendering_to_lines { add_text "}" }

              add_text ">"
            end
          end
        end
      end
    end
  end
end
