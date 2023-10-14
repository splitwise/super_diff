module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class DateLike < Base
        def self.applies_to?(value)
          SuperDiff.date_like?(value)
        end

        def call
          InspectionTree.new do
            as_lines_when_rendering_to_lines(collection_bookend: :open) do
              add_text { |date| "#<#{date.class} " }

              when_rendering_to_lines { add_text "{" }
            end

            when_rendering_to_string do
              add_text do |date|
                date.strftime("%Y-%m-%d")
              end
            end

            when_rendering_to_lines do
              nested do |date|
                insert_separated_list(
                  %i[year month day]
                ) do |name|
                  add_text name.to_s
                  add_text ": "
                  add_inspection_of date.public_send(name)
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
