module SuperDiff
  module ObjectInspection
    module Inspectors
      define :default_object do
        add_text do |object|
          "#<%<class>s:0x%<id>x" % {
            class: object.class,
            id: object.object_id * 2,
          }
        end

        when_multiline do
          add_text " {"
        end

        nested do |object|
          add_break " "

          insert_separated_list(
            object.instance_variables.sort,
            separator: build_node(:when_multiline, ","),
          ) do |name|
            add_text name.to_s
            add_text "="
            add_inspection_of object.instance_variable_get(name)
          end
        end

        add_break

        when_multiline do
          add_text "}"
        end

        add_text ">"
      end
    end
  end
end
