require "spec_helper"

RSpec.describe SuperDiff::TieredLinesElider, type: :unit do
  context "and the gem is configured with :diff_elision_maximum" do
    context "and :diff_elision_maximum is more than 0" do
      context "and the line tree contains a section of noops that does not span more than the maximum" do
        it "doesn't elide anything" do
          # Diff:
          #
          #   [
          #     "one",
          #     "two",
          #     "three",
          # -   "four",
          # +   "FOUR",
          #     "six",
          #     "seven",
          #     "eight",
          #   ]

          lines = [
            an_actual_line(
              type: :noop,
              indentation_level: 0,
              value: "[",
              collection_bookend: :open,
              complete_bookend: :open
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("one"),
              add_comma?: true
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("two"),
              add_comma?: true
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("three"),
              add_comma?: true
            ),
            an_actual_line(
              type: :delete,
              indentation_level: 1,
              value: %("four"),
              add_comma?: true
            ),
            an_actual_line(
              type: :insert,
              indentation_level: 1,
              value: %("FOUR"),
              add_comma?: true
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("five"),
              add_comma?: true
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("six"),
              add_comma?: true
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("seven")
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 0,
              value: "]",
              collection_bookend: :close,
              complete_bookend: :close
            )
          ]

          line_tree_with_elisions =
            with_configuration(
              diff_elision_enabled: true,
              diff_elision_maximum: 3
            ) { described_class.call(lines) }

          expect(line_tree_with_elisions).to match(
            [
              an_expected_line(type: :noop, indentation_level: 0, value: "["),
              an_expected_line(
                type: :noop,
                indentation_level: 1,
                value: %("one"),
                add_comma?: true
              ),
              an_expected_line(
                type: :noop,
                indentation_level: 1,
                value: %("two"),
                add_comma?: true
              ),
              an_expected_line(
                type: :noop,
                indentation_level: 1,
                value: %("three"),
                add_comma?: true
              ),
              an_expected_line(
                type: :delete,
                indentation_level: 1,
                value: %("four"),
                add_comma?: true
              ),
              an_expected_line(
                type: :insert,
                indentation_level: 1,
                value: %("FOUR"),
                add_comma?: true
              ),
              an_expected_line(
                type: :noop,
                indentation_level: 1,
                value: %("five"),
                add_comma?: true
              ),
              an_expected_line(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma?: true
              ),
              an_expected_line(
                type: :noop,
                indentation_level: 1,
                value: %("seven")
              ),
              an_expected_line(type: :noop, indentation_level: 0, value: "]")
            ]
          )
        end
      end

      context "and the line tree contains a section of noops that spans more than the maximum" do
        context "and the tree is one-dimensional" do
          context "and the line tree is just noops" do
            it "doesn't elide anything" do
              # Diff:
              #
              #   [
              #     "one",
              #     "two",
              #     "three",
              #     "four",
              #     "five",
              #     "six",
              #     "seven",
              #     "eight",
              #     "nine",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("six"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("seven"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("eight"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("nine")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 3
                ) { described_class.call(lines) }

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("nine")
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the line tree contains non-noops in addition to noops" do
            context "and the only noops that exist are above the only non-noops that exist" do
              it "elides the beginning of the noop so as to put it at the maximum" do
                # Diff:
                #
                #   [
                #     "one",
                #     "two",
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #   ]

                lines = [
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "[",
                    collection_bookend: :open,
                    complete_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]",
                    collection_bookend: :close,
                    complete_bookend: :close
                  )
                ]

                line_tree_with_elisions =
                  with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 3
                  ) { described_class.call(lines) }

                # Result:
                #
                #   [
                #     # ...
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #   ]

                expect(line_tree_with_elisions).to match(
                  [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "["
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("one"),
                          add_comma?: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("two"),
                          add_comma?: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("three"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("four"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("five"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("FIVE"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]"
                    )
                  ]
                )
              end
            end

            context "and the only noops that exist are below the only non-noops that exist" do
              it "elides the end of the noop so as to put it at the maximum" do
                # Diff:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     "four",
                #     "five",
                #   ]

                lines = [
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "[",
                    collection_bookend: :open,
                    complete_bookend: :open
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]",
                    collection_bookend: :close,
                    complete_bookend: :close
                  )
                ]

                line_tree_with_elisions =
                  with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 3
                  ) { described_class.call(lines) }

                # Result:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     "four",
                #     # ...
                #   ]

                expect(line_tree_with_elisions).to match(
                  [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "["
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("one"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("ONE"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("two"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("three"),
                      add_comma?: true
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("four"),
                          add_comma?: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("five"),
                          add_comma?: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]"
                    )
                  ]
                )
              end
            end

            context "and the noops flank the non-noops" do
              it "elides the beginning of the first noop and the end of the second noop so as to put them both at the maximum" do
                # Diff:
                #
                #   [
                #     "one",
                #     "two",
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #     "six",
                #     "seven",
                #     "eight",
                #     "nine",
                #   ]

                lines = [
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "[",
                    collection_bookend: :open,
                    complete_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("nine")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]",
                    collection_bookend: :close,
                    complete_bookend: :close
                  )
                ]

                line_tree_with_elisions =
                  with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 3
                  ) { described_class.call(lines) }

                # Result:
                #
                #   [
                #     # ...
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #     "six",
                #     "seven",
                #     # ...
                #   ]

                expect(line_tree_with_elisions).to match(
                  [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "["
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("one"),
                          add_comma?: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("two"),
                          add_comma?: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("three"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("four"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("five"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("FIVE"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("six"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("seven"),
                      add_comma?: true
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("eight"),
                          add_comma?: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("nine")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]"
                    )
                  ]
                )
              end
            end

            context "and the noops are flanked by the non-noops" do
              it "elides as much of the middle of the noop as to put it at the maximum" do
                # Diff:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     "four",
                #     "five",
                #     "six",
                #     "seven",
                #     "eight",
                # -   "nine",
                # +   "NINE",
                #   ]

                lines = [
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "[",
                    collection_bookend: :open,
                    complete_bookend: :open
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma?: true
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("nine")
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("NINE")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]",
                    collection_bookend: :close,
                    complete_bookend: :close
                  )
                ]

                line_tree_with_elisions =
                  with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 6
                  ) { described_class.call(lines) }

                # Result:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     # ...
                #     "six",
                #     "seven",
                #     "eight",
                # -   "nine",
                # +   "NINE",
                #   ]

                expect(line_tree_with_elisions).to match(
                  [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "["
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("one"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("ONE"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("two"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("three"),
                      add_comma?: true
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("four"),
                          add_comma?: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("five"),
                          add_comma?: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("six"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("seven"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("eight"),
                      add_comma?: true
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("nine")
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("NINE")
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]"
                    )
                  ]
                )
              end
            end
          end
        end

        context "and the tree is multi-dimensional" do
          context "and the line tree is just noops" do
            it "doesn't elide anything" do
              # Diff:
              #
              #   [
              #     "alpha",
              #     "beta",
              #     [
              #       "proton",
              #       [
              #         "electron",
              #         "photon",
              #         "gluon"
              #       ],
              #       "neutron"
              #     ],
              #     "digamma",
              #     "waw",
              #     "omega"
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("alpha"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("beta"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "[",
                  collection_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("proton"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("["),
                  collection_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("electron"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("photon"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("gluon")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("]"),
                  add_comma?: true,
                  collection_bookend: :close
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("neutron")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "]",
                  add_comma?: true,
                  collection_bookend: :close
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("digamma"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("waw"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("omega")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 5
                ) { described_class.call(lines) }

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("alpha"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("beta"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "["
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("[")
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("electron"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("photon"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("gluon")
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("]"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron")
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "]",
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("digamma"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("waw"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("omega")
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the line tree contains non-noops in addition to noops" do
            context "and the sequence of noops does not cross indentation level boundaries" do
              it "represents the smallest portion within the sequence as an elision (descending into sub-structures if necessary) to fit the whole sequence under the maximum" do
                # Diff:
                #
                #   [
                #     "alpha",
                #     "beta",
                #     [
                #       "proton",
                #       [
                #         "electron",
                #         "photon",
                #         "gluon"
                #       ],
                #       "neutron"
                #     ],
                # -   "digamma",
                # +   "waw",
                #     "omega"
                #   ]

                lines = [
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "[",
                    collection_bookend: :open,
                    complete_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("alpha"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("beta"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "[",
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("["),
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("electron"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("photon"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("gluon")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("]"),
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "]",
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("digamma"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("waw"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("omega")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]",
                    collection_bookend: :close,
                    complete_bookend: :close
                  )
                ]

                line_tree_with_elisions =
                  with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 5
                  ) { described_class.call(lines) }

                # Result:
                #
                #   [
                #     "alpha",
                #     "beta",
                #     [
                #       # ...
                #     ],
                # -   "digamma",
                # +   "waw",
                #     "omega"
                #   ]

                expect(line_tree_with_elisions).to match(
                  [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "["
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "["
                    ),
                    an_expected_elision(
                      indentation_level: 2,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("proton"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("[")
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 3,
                          value: %("electron"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 3,
                          value: %("photon"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 3,
                          value: %("gluon")
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("]"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("neutron")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "]",
                      add_comma: true
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("digamma"),
                      add_comma: true
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("omega")
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]"
                    )
                  ]
                )
              end
            end

            context "and the sequence of noops crosses indentation level boundaries" do
              context "assuming that, after the lines that fit completely inside those boundaries are elided, the sequence of noops is below the maximum" do
                it "only elides lines which fit completely inside the selected sections" do
                  # Diff:
                  #
                  #   [
                  #     "alpha",
                  #     [
                  #       "zeta",
                  #       "eta"
                  #     ],
                  #     "beta",
                  #     [
                  #       "proton",
                  #       "electron",
                  #       [
                  # -       "red",
                  # +       "blue",
                  #         "green"
                  #       ],
                  #       "neutron",
                  #       "charm",
                  #       "up",
                  #       "down"
                  #     ],
                  #     "waw",
                  #     "omega"
                  #   ]

                  lines = [
                    an_actual_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "[",
                      complete_bookend: :open,
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "[",
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("zeta"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("eta")
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "]",
                      add_comma: true,
                      collection_bookend: :close
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "[",
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("proton"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("electron"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "[",
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("green")
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "]",
                      add_comma: true,
                      collection_bookend: :close
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("neutron"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("charm"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("up"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("down")
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "]",
                      add_comma: true,
                      collection_bookend: :close
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("omega")
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]",
                      collection_bookend: :close,
                      complete_bookend: :close
                    )
                  ]

                  line_tree_with_elisions =
                    with_configuration(
                      diff_elision_enabled: true,
                      diff_elision_maximum: 5
                    ) { described_class.call(lines) }

                  expect(line_tree_with_elisions).to match(
                    [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 0,
                        value: "["
                      ),
                      an_expected_elision(
                        indentation_level: 1,
                        children: [
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: %("alpha"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: "["
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("zeta"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("eta")
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: "]",
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: %("beta"),
                            add_comma: true
                          )
                        ]
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "["
                      ),
                      an_expected_elision(
                        indentation_level: 2,
                        children: [
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("proton"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("electron"),
                            add_comma: true
                          )
                        ]
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "["
                      ),
                      an_expected_line(
                        type: :delete,
                        indentation_level: 3,
                        value: %("red"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :insert,
                        indentation_level: 3,
                        value: %("blue"),
                        add_comma: true
                      ),
                      an_expected_elision(
                        indentation_level: 3,
                        children: [
                          an_expected_line(
                            type: :noop,
                            indentation_level: 3,
                            value: %("green")
                          )
                        ]
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "]",
                        add_comma: true
                      ),
                      an_expected_elision(
                        indentation_level: 2,
                        children: [
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("neutron"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("charm"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("up"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("down")
                          )
                        ]
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "]",
                        add_comma: true
                      ),
                      an_expected_elision(
                        indentation_level: 1,
                        children: [
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: %("waw"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: %("omega")
                          )
                        ]
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 0,
                        value: "]"
                      )
                    ]
                  )
                end
              end

              context "when, after the lines that fit completely inside those boundaries are elided, the sequence of noops is still above the maximum" do
                it "elides the lines as much as possible" do
                  # Diff:
                  #
                  #   [
                  #     "alpha",
                  #     [
                  #       "beta",
                  #       "gamma"
                  #     ],
                  #     "pi",
                  #     [
                  #       [
                  # -       "red",
                  # +       "blue"
                  #       ]
                  #     ]
                  #   ]

                  lines = [
                    an_actual_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "[",
                      complete_bookend: :open,
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "[",
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("beta"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("gamma")
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "]",
                      collection_bookend: :close
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("pi"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "[",
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "[",
                      collection_bookend: :open
                    ),
                    an_actual_line(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true
                    ),
                    an_actual_line(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue")
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "]",
                      collection_bookend: :close
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "]",
                      collection_bookend: :close
                    ),
                    an_actual_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]",
                      collection_bookend: :close
                    )
                  ]

                  line_tree_with_elisions =
                    with_configuration(
                      diff_elision_enabled: true,
                      diff_elision_maximum: 5
                    ) { described_class.call(lines) }

                  # Result:
                  #
                  #   [
                  #     # ...
                  #     [
                  #       [
                  # -       "red",
                  # +       "blue"
                  #       ]
                  #     ]
                  #   ]

                  expect(line_tree_with_elisions).to match(
                    [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 0,
                        value: "[",
                        complete_bookend: :open,
                        collection_bookend: :open,
                        elided: false
                      ),
                      an_expected_elision(
                        indentation_level: 1,
                        children: [
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: %("alpha"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: "[",
                            collection_bookend: :open
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("beta"),
                            add_comma: true
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 2,
                            value: %("gamma")
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: "]",
                            collection_bookend: :close
                          ),
                          an_expected_line(
                            type: :noop,
                            indentation_level: 1,
                            value: %("pi"),
                            add_comma: true
                          )
                        ]
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "[",
                        collection_bookend: :open,
                        elided: false
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "[",
                        collection_bookend: :open,
                        elided: false
                      ),
                      an_expected_line(
                        type: :delete,
                        indentation_level: 3,
                        value: %("red"),
                        add_comma: true,
                        elided: false
                      ),
                      an_expected_line(
                        type: :insert,
                        indentation_level: 3,
                        value: %("blue"),
                        elided: false
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "]",
                        collection_bookend: :close,
                        elided: false
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "]",
                        collection_bookend: :close,
                        elided: false
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 0,
                        value: "]",
                        collection_bookend: :close,
                        elided: false
                      )
                    ]
                  )
                end
              end
            end
          end
        end

        context "and within the noops there is a long string of lines on the same level and one level deeper" do
          it "not only elides the deeper level but also part of the long string as well to reach the max" do
            # Diff:
            #
            #   [
            # -   "0",
            #     "1",
            #     "2",
            #     "3",
            #     "4",
            #     "5",
            #     "6",
            #     "7",
            #     "8",
            #     {
            #       foo: "bar",
            #       baz: "qux"
            #     },
            # +   "9"
            #   ]

            lines = [
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                prefix: "",
                value: "[",
                add_comma: false,
                complete_bookend: :open,
                collection_bookend: :open
              ),
              an_actual_line(
                type: :delete,
                indentation_level: 1,
                prefix: "",
                value: %("0"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                prefix: "",
                value: %("1"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                prefix: "",
                value: %("2"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                prefix: "",
                value: %("3"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("4"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("5"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("6"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("7"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("8"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: "{",
                add_comma: false,
                complete_bookend: nil,
                collection_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                prefix: "foo:",
                value: %("bar"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                prefix: "baz:",
                value: %("qux"),
                add_comma: false,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                prefix: "",
                value: "}",
                add_comma: false,
                complete_bookend: nil,
                collection_bookend: :close
              ),
              an_actual_line(
                type: :insert,
                indentation_level: 1,
                prefix: "",
                value: %("9"),
                add_comma: false,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                prefix: "",
                value: "]",
                add_comma: false,
                complete_bookend: :close,
                collection_bookend: :close
              )
            ]

            line_tree_with_elisions =
              with_configuration(
                diff_elision_enabled: true,
                diff_elision_maximum: 4
              ) { described_class.call(lines) }

            # Result:
            #
            #   [
            # -   "0",
            #     "1",
            #     # ...
            # +   "9"
            #   ]

            expect(line_tree_with_elisions).to match(
              [
                an_expected_line(
                  type: :noop,
                  indentation_level: 0,
                  prefix: "",
                  value: "[",
                  add_comma: false,
                  complete_bookend: :open,
                  collection_bookend: :open
                ),
                an_expected_line(
                  type: :delete,
                  indentation_level: 1,
                  prefix: "",
                  value: %("0"),
                  add_comma: true,
                  complete_bookend: nil,
                  collection_bookend: nil
                ),
                an_expected_elision(
                  indentation_level: 1,
                  children: [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      prefix: "",
                      value: %("1"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      prefix: "",
                      value: %("2"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      prefix: "",
                      value: %("3"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("4"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("5"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("6"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("7"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("8"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "{",
                      add_comma: false,
                      complete_bookend: nil,
                      collection_bookend: :open
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 2,
                      prefix: "foo:",
                      value: %("bar"),
                      add_comma: true,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 2,
                      prefix: "baz:",
                      value: %("qux"),
                      add_comma: false,
                      complete_bookend: nil,
                      collection_bookend: nil
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      prefix: "",
                      value: "}",
                      add_comma: false,
                      complete_bookend: nil,
                      collection_bookend: :close
                    )
                  ]
                ),
                an_expected_line(
                  type: :insert,
                  indentation_level: 1,
                  prefix: "",
                  value: %("9"),
                  add_comma: false,
                  complete_bookend: nil,
                  collection_bookend: nil
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 0,
                  prefix: "",
                  value: "]",
                  add_comma: false,
                  complete_bookend: :close,
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end
    end

    context "and :diff_elision_maximum is 0" do
      context "and the tree is one-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "one",
            #     "two",
            #     "three",
            #     "four",
            #     "five",
            #     "six",
            #     "seven",
            #     "eight",
            #     "nine",
            #   ]

            lines = [
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "[",
                collection_bookend: :open,
                complete_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("one"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("two"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("three"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("four"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("five"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("seven"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("eight"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("nine")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "]",
                collection_bookend: :close,
                complete_bookend: :close
              )
            ]

            line_tree_with_elisions =
              with_configuration(
                diff_elision_enabled: true,
                diff_elision_maximum: 0
              ) { described_class.call(lines) }

            expect(line_tree_with_elisions).to match(
              [
                an_expected_line(type: :noop, indentation_level: 0, value: "["),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("six"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("seven"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("eight"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("nine")
                ),
                an_expected_line(type: :noop, indentation_level: 0, value: "]")
              ]
            )
          end
        end

        context "and the line tree contains non-noops in addition to noops" do
          context "and the only noops that exist are above the only non-noops that exist" do
            it "elides the beginning of the noop" do
              # Diff:
              #
              #   [
              #     "one",
              #     "two",
              #     "three",
              #     "four",
              # -   "five",
              # +   "FIVE",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("FIVE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              #     # ...
              # -   "five",
              # +   "FIVE",
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("one"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the only noops that exist are below the only non-noops that exist" do
            it "elides the end of the noop" do
              # Diff:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     "two",
              #     "three",
              #     "four",
              #     "five",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("ONE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     # ...
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma?: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("five"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the noops flank the non-noops" do
            it "elides the beginning of the first noop and the end of the second noop" do
              # Diff:
              #
              #   [
              #     "one",
              #     "two",
              #     "three",
              #     "four",
              # -   "five",
              # +   "FIVE",
              #     "six",
              #     "seven",
              #     "eight",
              #     "nine",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("FIVE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("six"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("seven"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("eight"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("nine")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              #     # ...
              # -   "five",
              # +   "FIVE",
              #     # ...
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("one"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma?: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("six"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("seven"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("eight"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("nine")
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the noops are flanked by the non-noops" do
            it "elides the noop" do
              # Diff:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     "two",
              #     "three",
              #     "four",
              #     "five",
              #     "six",
              #     "seven",
              #     "eight",
              # -   "nine",
              # +   "NINE",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("ONE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("six"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("seven"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("eight"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("nine")
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("NINE")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     # ...
              # -   "nine",
              # +   "NINE",
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma?: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("five"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("six"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("seven"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("eight"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("nine")
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("NINE")
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end
        end
      end

      context "and the tree is multi-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            #     "digamma",
            #     "waw",
            #     "omega"
            #   ]

            lines = [
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "[",
                collection_bookend: :open,
                complete_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: "[",
                collection_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma?: true,
                collection_bookend: :close
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: "]",
                add_comma?: true,
                collection_bookend: :close
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("omega")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "]",
                collection_bookend: :close,
                complete_bookend: :close
              )
            ]

            line_tree_with_elisions =
              with_configuration(
                diff_elision_enabled: true,
                diff_elision_maximum: 0
              ) { described_class.call(lines) }

            expect(line_tree_with_elisions).to match(
              [
                an_expected_line(type: :noop, indentation_level: 0, value: "["),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("alpha"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("beta"),
                  add_comma?: true
                ),
                an_expected_line(type: :noop, indentation_level: 1, value: "["),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("proton"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("[")
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("electron"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("photon"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("gluon")
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("]"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("neutron")
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "]",
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("digamma"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("waw"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("omega")
                ),
                an_expected_line(type: :noop, indentation_level: 0, value: "]")
              ]
            )
          end
        end

        context "and the line tree contains non-noops in addition to noops" do
          context "and the sequence of noops does not cross indentation level boundaries" do
            it "elides the noops" do
              # Diff:
              #
              #   [
              #     "alpha",
              #     "beta",
              #     [
              #       "proton",
              #       [
              #         "electron",
              #         "photon",
              #         "gluon"
              #       ],
              #       "neutron"
              #     ],
              # -   "digamma",
              # +   "waw",
              #     "omega"
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("alpha"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("beta"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "[",
                  collection_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("proton"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: "[",
                  collection_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("electron"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("photon"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("gluon")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: "]",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("neutron")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "]",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("digamma"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("waw"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("omega")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              #     # ...
              # -   "digamma",
              # +   "waw",
              #     # ...
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("alpha"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("beta"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "["
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: %("proton"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "["
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 3,
                        value: %("electron"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 3,
                        value: %("photon"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 3,
                        value: %("gluon")
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "]",
                        add_comma: false
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: %("neutron")
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "]",
                        add_comma: false
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("digamma"),
                    add_comma: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("waw"),
                    add_comma: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("omega")
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the sequence of noops crosses indentation level boundaries" do
            context "assuming that, after the lines that fit completely inside those boundaries are elided, the sequence of noops is below the maximum" do
              it "only elides lines which fit completely inside the selected sections" do
                # Diff:
                #
                #   [
                #     "alpha",
                #     [
                #       "zeta",
                #       "eta"
                #     ],
                #     "beta",
                #     [
                #       "proton",
                #       "electron",
                #       [
                # -       "red",
                # +       "blue",
                #         "green"
                #       ],
                #       "neutron",
                #       "charm",
                #       "up",
                #       "down"
                #     ],
                #     "waw",
                #     "omega"
                #   ]

                lines = [
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "[",
                    complete_bookend: :open,
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("alpha"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "[",
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("zeta"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("eta")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "]",
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("beta"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "[",
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("electron"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: "[",
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 3,
                    value: %("red"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 3,
                    value: %("blue"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("green")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: "]",
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("charm"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("up"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("down")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "]",
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("waw"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("omega")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]",
                    collection_bookend: :close,
                    complete_bookend: :close
                  )
                ]

                line_tree_with_elisions =
                  with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 0
                  ) { described_class.call(lines) }

                # Result:
                #
                #   [
                #     # ...
                #     [
                #       # ...
                #       [
                # -       "red",
                # +       "blue",
                #         # ...
                #       ],
                #       # ...
                #     ],
                #     # ...
                #   ]

                expect(line_tree_with_elisions).to match(
                  [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "["
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("alpha"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: "["
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("zeta"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("eta")
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: "]",
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("beta"),
                          add_comma: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "["
                    ),
                    an_expected_elision(
                      indentation_level: 2,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("proton"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("electron"),
                          add_comma: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "["
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue"),
                      add_comma: true
                    ),
                    an_expected_elision(
                      indentation_level: 3,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 3,
                          value: %("green")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "]",
                      add_comma: true
                    ),
                    an_expected_elision(
                      indentation_level: 2,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("neutron"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("charm"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("up"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("down")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "]",
                      add_comma: true
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("waw"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("omega")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]"
                    )
                  ]
                )
              end
            end
          end
        end
      end

      context "and within the noops there is a long string of lines on the same level and one level deeper" do
        it "elides all the noops" do
          # Diff:
          #
          #   [
          # -   "0",
          #     "1",
          #     "2",
          #     "3",
          #     "4",
          #     "5",
          #     "6",
          #     "7",
          #     "8",
          #     {
          #       foo: "bar",
          #       baz: "qux"
          #     },
          # +   "9"
          #   ]

          lines = [
            an_actual_line(
              type: :noop,
              indentation_level: 0,
              prefix: "",
              value: "[",
              add_comma: false,
              complete_bookend: :open,
              collection_bookend: :open
            ),
            an_actual_line(
              type: :delete,
              indentation_level: 1,
              prefix: "",
              value: %("0"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: %("1"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: %("2"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: %("3"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("4"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("5"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("6"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("7"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("8"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: "{",
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: :open
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 2,
              prefix: "foo:",
              value: %("bar"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 2,
              prefix: "baz:",
              value: %("qux"),
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: "}",
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: :close
            ),
            an_actual_line(
              type: :insert,
              indentation_level: 1,
              prefix: "",
              value: %("9"),
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 0,
              prefix: "",
              value: "]",
              add_comma: false,
              complete_bookend: :close,
              collection_bookend: :close
            )
          ]

          line_tree_with_elisions =
            with_configuration(
              diff_elision_enabled: true,
              diff_elision_maximum: 0
            ) { described_class.call(lines) }

          # Result:
          #
          #   [
          # -   "0",
          #     # ...
          # +   "9"
          #   ]

          expect(line_tree_with_elisions).to match(
            [
              an_expected_line(
                type: :noop,
                indentation_level: 0,
                prefix: "",
                value: "[",
                add_comma: false,
                complete_bookend: :open,
                collection_bookend: :open
              ),
              an_expected_line(
                type: :delete,
                indentation_level: 1,
                prefix: "",
                value: %("0"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_expected_elision(
                indentation_level: 1,
                children: [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: %("1"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: %("2"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: %("3"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("4"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("5"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("6"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("7"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("8"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "{",
                    add_comma: false,
                    complete_bookend: nil,
                    collection_bookend: :open
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    prefix: "foo:",
                    value: %("bar"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    prefix: "baz:",
                    value: %("qux"),
                    add_comma: false,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: "}",
                    add_comma: false,
                    complete_bookend: nil,
                    collection_bookend: :close
                  )
                ]
              ),
              an_expected_line(
                type: :insert,
                indentation_level: 1,
                prefix: "",
                value: %("9"),
                add_comma: false,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_expected_line(
                type: :noop,
                indentation_level: 0,
                prefix: "",
                value: "]",
                add_comma: false,
                complete_bookend: :close,
                collection_bookend: :close
              )
            ]
          )
        end
      end
    end

    context "and :diff_elision_maximum is not specified" do
      context "and the tree is one-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "one",
            #     "two",
            #     "three",
            #     "four",
            #     "five",
            #     "six",
            #     "seven",
            #     "eight",
            #     "nine",
            #   ]

            lines = [
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "[",
                collection_bookend: :open,
                complete_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("one"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("two"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("three"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("four"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("five"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("seven"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("eight"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("nine")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "]",
                collection_bookend: :close,
                complete_bookend: :close
              )
            ]

            line_tree_with_elisions =
              with_configuration(
                diff_elision_enabled: true,
                diff_elision_maximum: 0
              ) { described_class.call(lines) }

            expect(line_tree_with_elisions).to match(
              [
                an_expected_line(type: :noop, indentation_level: 0, value: "["),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("six"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("seven"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("eight"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("nine")
                ),
                an_expected_line(type: :noop, indentation_level: 0, value: "]")
              ]
            )
          end
        end

        context "and the line tree contains non-noops in addition to noops" do
          context "and the only noops that exist are above the only non-noops that exist" do
            it "elides the beginning of the noop" do
              # Diff:
              #
              #   [
              #     "one",
              #     "two",
              #     "three",
              #     "four",
              # -   "five",
              # +   "FIVE",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("FIVE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              #     # ...
              # -   "five",
              # +   "FIVE",
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("one"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the only noops that exist are below the only non-noops that exist" do
            it "elides the end of the noop" do
              # Diff:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     "two",
              #     "three",
              #     "four",
              #     "five",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("ONE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     # ...
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma?: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("five"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the noops flank the non-noops" do
            it "elides the beginning of the first noop and the end of the second noop" do
              # Diff:
              #
              #   [
              #     "one",
              #     "two",
              #     "three",
              #     "four",
              # -   "five",
              # +   "FIVE",
              #     "six",
              #     "seven",
              #     "eight",
              #     "nine",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("FIVE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("six"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("seven"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("eight"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("nine")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              #     # ...
              # -   "five",
              # +   "FIVE",
              #     # ...
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("one"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma?: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("six"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("seven"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("eight"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("nine")
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the noops are flanked by the non-noops" do
            it "elides the noop" do
              # Diff:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     "two",
              #     "three",
              #     "four",
              #     "five",
              #     "six",
              #     "seven",
              #     "eight",
              # -   "nine",
              # +   "NINE",
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("one"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("ONE"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("two"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("three"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("four"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("five"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("six"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("seven"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("eight"),
                  add_comma?: true
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("nine")
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("NINE")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              # -   "one",
              # +   "ONE",
              #     # ...
              # -   "nine",
              # +   "NINE",
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma?: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma?: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("three"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("five"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("six"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("seven"),
                        add_comma?: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("eight"),
                        add_comma?: true
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("nine")
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("NINE")
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end
        end
      end

      context "and the tree is multi-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            #     "digamma",
            #     "waw",
            #     "omega"
            #   ]

            lines = [
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "[",
                collection_bookend: :open,
                complete_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: "[",
                collection_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma?: true,
                collection_bookend: :close
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: "]",
                add_comma?: true,
                collection_bookend: :close
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma?: true
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 1,
                value: %("omega")
              ),
              an_actual_line(
                type: :noop,
                indentation_level: 0,
                value: "]",
                collection_bookend: :close,
                complete_bookend: :close
              )
            ]

            line_tree_with_elisions =
              with_configuration(
                diff_elision_enabled: true,
                diff_elision_maximum: 0
              ) { described_class.call(lines) }

            expect(line_tree_with_elisions).to match(
              [
                an_expected_line(type: :noop, indentation_level: 0, value: "["),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("alpha"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("beta"),
                  add_comma?: true
                ),
                an_expected_line(type: :noop, indentation_level: 1, value: "["),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("proton"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("[")
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("electron"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("photon"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("gluon")
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("]"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("neutron")
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "]",
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("digamma"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("waw"),
                  add_comma?: true
                ),
                an_expected_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("omega")
                ),
                an_expected_line(type: :noop, indentation_level: 0, value: "]")
              ]
            )
          end
        end

        context "and the line tree contains non-noops in addition to noops" do
          context "and the sequence of noops does not cross indentation level boundaries" do
            it "elides the noops" do
              # Diff:
              #
              #   [
              #     "alpha",
              #     "beta",
              #     [
              #       "proton",
              #       [
              #         "electron",
              #         "photon",
              #         "gluon"
              #       ],
              #       "neutron"
              #     ],
              # -   "digamma",
              # +   "waw",
              #     "omega"
              #   ]

              lines = [
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "[",
                  collection_bookend: :open,
                  complete_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("alpha"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("beta"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "[",
                  collection_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("proton"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: "[",
                  collection_bookend: :open
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("electron"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("photon"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("gluon")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: "]",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("neutron")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: "]",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_actual_line(
                  type: :delete,
                  indentation_level: 1,
                  value: %("digamma"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :insert,
                  indentation_level: 1,
                  value: %("waw"),
                  add_comma: true
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("omega")
                ),
                an_actual_line(
                  type: :noop,
                  indentation_level: 0,
                  value: "]",
                  collection_bookend: :close,
                  complete_bookend: :close
                )
              ]

              line_tree_with_elisions =
                with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 0
                ) { described_class.call(lines) }

              # Result:
              #
              #   [
              #     # ...
              # -   "digamma",
              # +   "waw",
              #     # ...
              #   ]

              expect(line_tree_with_elisions).to match(
                [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "["
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("alpha"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("beta"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "["
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: %("proton"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "["
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 3,
                        value: %("electron"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 3,
                        value: %("photon"),
                        add_comma: true
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 3,
                        value: %("gluon")
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: "]",
                        add_comma: false
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 2,
                        value: %("neutron")
                      ),
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: "]",
                        add_comma: false
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("digamma"),
                    add_comma: true
                  ),
                  an_expected_line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("waw"),
                    add_comma: true
                  ),
                  an_expected_elision(
                    indentation_level: 1,
                    children: [
                      an_expected_line(
                        type: :noop,
                        indentation_level: 1,
                        value: %("omega")
                      )
                    ]
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]"
                  )
                ]
              )
            end
          end

          context "and the sequence of noops crosses indentation level boundaries" do
            context "assuming that, after the lines that fit completely inside those boundaries are elided, the sequence of noops is below the maximum" do
              it "only elides lines which fit completely inside the selected sections" do
                # Diff:
                #
                #   [
                #     "alpha",
                #     [
                #       "zeta",
                #       "eta"
                #     ],
                #     "beta",
                #     [
                #       "proton",
                #       "electron",
                #       [
                # -       "red",
                # +       "blue",
                #         "green"
                #       ],
                #       "neutron",
                #       "charm",
                #       "up",
                #       "down"
                #     ],
                #     "waw",
                #     "omega"
                #   ]

                lines = [
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "[",
                    complete_bookend: :open,
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("alpha"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "[",
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("zeta"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("eta")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "]",
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("beta"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "[",
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("electron"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: "[",
                    collection_bookend: :open
                  ),
                  an_actual_line(
                    type: :delete,
                    indentation_level: 3,
                    value: %("red"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :insert,
                    indentation_level: 3,
                    value: %("blue"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 3,
                    value: %("green")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: "]",
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("charm"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("up"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 2,
                    value: %("down")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "]",
                    add_comma: true,
                    collection_bookend: :close
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("waw"),
                    add_comma: true
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("omega")
                  ),
                  an_actual_line(
                    type: :noop,
                    indentation_level: 0,
                    value: "]",
                    collection_bookend: :close,
                    complete_bookend: :close
                  )
                ]

                line_tree_with_elisions =
                  with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 0
                  ) { described_class.call(lines) }

                # Result:
                #
                #   [
                #     # ...
                #     [
                #       # ...
                #       [
                # -       "red",
                # +       "blue",
                #         # ...
                #       ],
                #       # ...
                #     ],
                #     # ...
                #   ]

                expect(line_tree_with_elisions).to match(
                  [
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "["
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("alpha"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: "["
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("zeta"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("eta")
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: "]",
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("beta"),
                          add_comma: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "["
                    ),
                    an_expected_elision(
                      indentation_level: 2,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("proton"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("electron"),
                          add_comma: true
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "["
                    ),
                    an_expected_line(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true
                    ),
                    an_expected_line(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue"),
                      add_comma: true
                    ),
                    an_expected_elision(
                      indentation_level: 3,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 3,
                          value: %("green")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 2,
                      value: "]",
                      add_comma: true
                    ),
                    an_expected_elision(
                      indentation_level: 2,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("neutron"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("charm"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("up"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 2,
                          value: %("down")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 1,
                      value: "]",
                      add_comma: true
                    ),
                    an_expected_elision(
                      indentation_level: 1,
                      children: [
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("waw"),
                          add_comma: true
                        ),
                        an_expected_line(
                          type: :noop,
                          indentation_level: 1,
                          value: %("omega")
                        )
                      ]
                    ),
                    an_expected_line(
                      type: :noop,
                      indentation_level: 0,
                      value: "]"
                    )
                  ]
                )
              end
            end
          end
        end
      end

      context "and within the noops there is a long string of lines on the same level and one level deeper" do
        it "elides all the noops" do
          # Diff:
          #
          #   [
          # -   "0",
          #     "1",
          #     "2",
          #     "3",
          #     "4",
          #     "5",
          #     "6",
          #     "7",
          #     "8",
          #     {
          #       foo: "bar",
          #       baz: "qux"
          #     },
          # +   "9"
          #   ]

          lines = [
            an_actual_line(
              type: :noop,
              indentation_level: 0,
              prefix: "",
              value: "[",
              add_comma: false,
              complete_bookend: :open,
              collection_bookend: :open
            ),
            an_actual_line(
              type: :delete,
              indentation_level: 1,
              prefix: "",
              value: %("0"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: %("1"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: %("2"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: %("3"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("4"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("5"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("6"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("7"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: %("8"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              value: "{",
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: :open
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 2,
              prefix: "foo:",
              value: %("bar"),
              add_comma: true,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 2,
              prefix: "baz:",
              value: %("qux"),
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 1,
              prefix: "",
              value: "}",
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: :close
            ),
            an_actual_line(
              type: :insert,
              indentation_level: 1,
              prefix: "",
              value: %("9"),
              add_comma: false,
              complete_bookend: nil,
              collection_bookend: nil
            ),
            an_actual_line(
              type: :noop,
              indentation_level: 0,
              prefix: "",
              value: "]",
              add_comma: false,
              complete_bookend: :close,
              collection_bookend: :close
            )
          ]

          line_tree_with_elisions =
            with_configuration(
              diff_elision_enabled: true,
              diff_elision_maximum: 0
            ) { described_class.call(lines) }

          # Result:
          #
          #   [
          # -   "0",
          #     # ...
          # +   "9"
          #   ]

          expect(line_tree_with_elisions).to match(
            [
              an_expected_line(
                type: :noop,
                indentation_level: 0,
                prefix: "",
                value: "[",
                add_comma: false,
                complete_bookend: :open,
                collection_bookend: :open
              ),
              an_expected_line(
                type: :delete,
                indentation_level: 1,
                prefix: "",
                value: %("0"),
                add_comma: true,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_expected_elision(
                indentation_level: 1,
                children: [
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: %("1"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: %("2"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: %("3"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("4"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("5"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("6"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("7"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("8"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    value: "{",
                    add_comma: false,
                    complete_bookend: nil,
                    collection_bookend: :open
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    prefix: "foo:",
                    value: %("bar"),
                    add_comma: true,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 2,
                    prefix: "baz:",
                    value: %("qux"),
                    add_comma: false,
                    complete_bookend: nil,
                    collection_bookend: nil
                  ),
                  an_expected_line(
                    type: :noop,
                    indentation_level: 1,
                    prefix: "",
                    value: "}",
                    add_comma: false,
                    complete_bookend: nil,
                    collection_bookend: :close
                  )
                ]
              ),
              an_expected_line(
                type: :insert,
                indentation_level: 1,
                prefix: "",
                value: %("9"),
                add_comma: false,
                complete_bookend: nil,
                collection_bookend: nil
              ),
              an_expected_line(
                type: :noop,
                indentation_level: 0,
                prefix: "",
                value: "]",
                add_comma: false,
                complete_bookend: :close,
                collection_bookend: :close
              )
            ]
          )
        end
      end
    end
  end

  def an_actual_line(**args)
    add_comma = args.delete(:add_comma?) { false }
    SuperDiff::Line.new(**args, add_comma: add_comma)
  end

  def an_expected_line(type:, indentation_level:, value:, children: [], **rest)
    an_object_having_attributes(
      type: type,
      indentation_level: indentation_level,
      value: value,
      add_comma?: rest.fetch(:add_comma?, false),
      children: children,
      elided?: rest.fetch(:elided?, false)
    )
  end

  def an_expected_elision(indentation_level:, children:)
    an_expected_line(
      type: :elision,
      value: "# ...",
      indentation_level: indentation_level,
      children:
        children.map do |child|
          an_expected_line(**child.base_matcher.expected.merge(elided?: true))
        end,
      elided?: true
    )
  end
end
