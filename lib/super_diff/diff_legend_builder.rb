module SuperDiff
  class DiffLegendBuilder
    extend AttrExtras.mixin

    method_object :expected

    def call
      SuperDiff::Helpers.style do
        line do
          header "Diff:"
        end

        newline

        line do
          border "┌ (Key) ──────────────────────────┐"
        end

        line do
          border "│ "
          alpha "‹-› in expected, not in actual"
          border "  │"
        end

        line do
          border "│ "
          beta "‹+› in actual, not in expected"
          border "  │"
        end

        line do
          border "│ "
          plain "‹ › in both expected and actual"
          border " │"
        end

        line do
          border "└─────────────────────────────────┘"
        end
      end
    end
  end
end
