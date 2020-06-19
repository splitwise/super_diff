require "spec_helper"

RSpec.describe SuperDiff::TieredLinesFormatter, type: :unit do
  it "formats the given lines as an array of strings with appropriate colors and indentation" do
    tiered_lines = [
      line(
        type: :noop,
        indentation_level: 0,
        value: %([),
      ),
      line(
        type: :noop,
        indentation_level: 1,
        value: %("foo"),
        add_comma: true,
      ),
      line(
        type: :noop,
        indentation_level: 1,
        value: %({),
      ),
      line(
        type: :noop,
        indentation_level: 2,
        prefix: %(one: ),
        value: %("fish"),
        add_comma: true,
      ),
      line(
        type: :delete,
        indentation_level: 2,
        prefix: %(two: ),
        value: %("fish"),
        add_comma: true,
      ),
      line(
        type: :insert,
        indentation_level: 2,
        prefix: %(two: ),
        value: %("FISH"),
        add_comma: true,
      ),
      line(
        type: :noop,
        indentation_level: 2,
        prefix: %(hard: ),
        value: %([),
      ),
      elision(
        indentation_level: 3,
        value: %(# ...),
        children: [
          line(
            type: :noop,
            indentation_level: 3,
            value: %("a"),
          ),
          line(
            type: :noop,
            indentation_level: 3,
            value: %("b"),
          ),
          line(
            type: :noop,
            indentation_level: 3,
            value: %("c"),
          ),
        ],
      ),
      line(
        type: :noop,
        indentation_level: 2,
        value: %(]),
        add_comma: true,
      ),
      line(
        type: :insert,
        indentation_level: 2,
        prefix: %(blue: ),
        value: %("fish"),
        add_comma: true,
      ),
      line(
        type: :insert,
        indentation_level: 2,
        prefix: %(stew: ),
        value: %("fish"),
      ),
      line(
        type: :noop,
        indentation_level: 1,
        value: %(}),
        add_comma: true,
      ),
      line(
        type: :noop,
        indentation_level: 1,
        value: %(∙∙∙),
        add_comma: true,
      ),
      line(
        type: :delete,
        indentation_level: 1,
        value: %("baz"),
        add_comma: true,
      ),
      line(
        type: :insert,
        indentation_level: 1,
        value: %(2),
        add_comma: true,
      ),
      line(
        type: :noop,
        indentation_level: 1,
        value: %("qux"),
        add_comma: true,
      ),
      line(
        type: :delete,
        indentation_level: 1,
        value: %("blargh"),
        add_comma: true,
      ),
      line(
        type: :delete,
        indentation_level: 1,
        value: %("zig"),
        add_comma: true,
      ),
      line(
        type: :delete,
        indentation_level: 1,
        value: %("zag"),
      ),
      line(
        type: :noop,
        indentation_level: 0,
        value: %(]),
      ),
    ]

    actual_diff = described_class.call(tiered_lines)

    expected_diff = colored do
      plain_line          %(  [)
      plain_line          %(    "foo",)
      plain_line          %(    {)
      plain_line          %(      one: "fish",)
      expected_line       %(-     two: "fish",)
      actual_line         %(+     two: "FISH",)
      plain_line          %(      hard: [)
      elision_marker_line %(        # ...)
      plain_line          %(      ],)
      actual_line         %(+     blue: "fish",)
      actual_line         %(+     stew: "fish")
      plain_line          %(    },)
      plain_line          %(    ∙∙∙,)
      expected_line       %(-   "baz",)
      actual_line         %(+   2,)
      plain_line          %(    "qux",)
      expected_line       %(-   "blargh",)
      expected_line       %(-   "zig",)
      expected_line       %(-   "zag")
      plain_line          %(  ])
    end

    expect(actual_diff).to eq(expected_diff)
  end

  def line(type:, indentation_level:, value:, prefix: "", add_comma: false)
    double(
      :line,
      type: type,
      indentation_level: indentation_level,
      prefix: prefix,
      value: value,
      add_comma?: add_comma,
    )
  end

  def elision(indentation_level:, value:, children:)
    double(
      :elision,
      type: :elision,
      indentation_level: indentation_level,
      prefix: "",
      value: value,
      add_comma?: false,
      children: children,
    )
  end
end
