# frozen_string_literal: true

module SuperDiff
  module Basic
    module InspectionTreeBuilders
      class DateLike < Core::AbstractInspectionTreeBuilder
        def self.applies_to?(value)
          SuperDiff.date_like?(value)
        end

        def call
          Core::InspectionTree.new do |t1|
            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :open
            ) do |t2|
              t2.add_text "#<#{object.class} "

              # stree-ignore
              t2.when_rendering_to_lines do |t3|
                t3.add_text '{'
              end
            end

            t1.when_rendering_to_string do |t2|
              t2.add_text object.strftime('%Y-%m-%d')
            end

            t1.when_rendering_to_lines do |t2|
              t2.nested do |t3|
                t3.insert_separated_list(%i[year month day]) do |t4, name|
                  t4.add_text name.to_s
                  t4.add_text ': '
                  t4.add_inspection_of object.public_send(name)
                end
              end
            end

            t1.as_lines_when_rendering_to_lines(
              collection_bookend: :close
            ) do |t2|
              # stree-ignore
              t2.when_rendering_to_lines do |t3|
                t3.add_text '}'
              end

              t2.add_text '>'
            end
          end
        end
      end
    end
  end
end
