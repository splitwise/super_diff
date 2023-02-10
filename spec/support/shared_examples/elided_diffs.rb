shared_examples_for "a matcher that supports elided diffs" do
  context "when comparing two one-dimensional data structures which feature a changed section flanked by unchanged sections" do
    context "if diff_elision_enabled is set to true" do
      it "elides the unchanged sections, preserving <maximum> number of lines within all unchanged sections (including the elision marker)" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              "Afghanistan",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Angola",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Australia"
            ]
            actual = [
              "Afghanistan",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Anguilla",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Australia"
            ]
            expect(actual).to #{matcher}(expected)
          TEST
          program =
            make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: true,
                diff_elision_maximum: 3
              }
            )

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected "
                    # rubocop:disable Layout/LineLength
                    actual %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                    # rubocop:enable Layout/LineLength
                  end

                  line do
                    plain "   to eq "
                    # rubocop:disable Layout/LineLength
                    expected %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                    # rubocop:enable Layout/LineLength
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  elision_marker_line "    # ..."
                  plain_line %|    "American Samoa",|
                  plain_line %|    "Andorra",|
                  expected_line %|-   "Angola",|
                  actual_line %|+   "Anguilla",|
                  plain_line %|    "Antarctica",|
                  plain_line %|    "Antigua And Barbuda",|
                  elision_marker_line "    # ..."
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "if diff_elision_enabled is set to false" do
      it "does not elide anything" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              "Afghanistan",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Angola",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Australia"
            ]
            actual = [
              "Afghanistan",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Anguilla",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Australia"
            ]
            expect(actual).to #{matcher}(expected)
          TEST
          program =
            make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: false,
                diff_elision_maximum: 3
              }
            )

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected "
                    # rubocop:disable Layout/LineLength
                    actual %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                    # rubocop:enable Layout/LineLength
                  end

                  line do
                    plain "   to eq "
                    # rubocop:disable Layout/LineLength
                    expected %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                    # rubocop:enable Layout/LineLength
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  plain_line %|    "Afghanistan",|
                  plain_line %|    "Aland Islands",|
                  plain_line %|    "Albania",|
                  plain_line %|    "Algeria",|
                  plain_line %|    "American Samoa",|
                  plain_line %|    "Andorra",|
                  expected_line %|-   "Angola",|
                  actual_line %|+   "Anguilla",|
                  plain_line %|    "Antarctica",|
                  plain_line %|    "Antigua And Barbuda",|
                  plain_line %|    "Argentina",|
                  plain_line %|    "Armenia",|
                  plain_line %|    "Aruba",|
                  plain_line %|    "Australia"|
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "when comparing two one-dimensional data structures which feature a unchanged section flanked by changed sections" do
    context "if diff_elision_enabled is set to true" do
      it "elides the unchanged sections, preserving <maximum> number of lines within all unchanged sections (including the elision marker)" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              "Afghanistan",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Angola",
              "Anguilla",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Australia"
            ]
            actual = [
              "Zambia",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Angola",
              "Anguilla",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Zimbabwe"
            ]
            expect(actual).to #{matcher}(expected)
          TEST
          program =
            make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: true,
                diff_elision_maximum: 3
              }
            )

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected "
                    # rubocop:disable Layout/LineLength
                    actual %|["Zambia", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Zimbabwe"]|
                    # rubocop:enable Layout/LineLength
                  end

                  line do
                    plain "   to eq "
                    # rubocop:disable Layout/LineLength
                    expected %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                    # rubocop:enable Layout/LineLength
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  expected_line %|-   "Afghanistan",|
                  actual_line %|+   "Zambia",|
                  plain_line %|    "Aland Islands",|
                  elision_marker_line "    # ..."
                  plain_line %|    "Aruba",|
                  expected_line %|-   "Australia"|
                  actual_line %|+   "Zimbabwe"|
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "if diff_elision_enabled is set to false" do
      it "does not elide anything" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              "Afghanistan",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Angola",
              "Anguilla",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Australia"
            ]
            actual = [
              "Zambia",
              "Aland Islands",
              "Albania",
              "Algeria",
              "American Samoa",
              "Andorra",
              "Angola",
              "Anguilla",
              "Antarctica",
              "Antigua And Barbuda",
              "Argentina",
              "Armenia",
              "Aruba",
              "Zimbabwe"
            ]
            expect(actual).to #{matcher}(expected)
          TEST
          program =
            make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: false,
                diff_elision_maximum: 3
              }
            )

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected "
                    # rubocop:disable Layout/LineLength
                    actual %|["Zambia", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Zimbabwe"]|
                    # rubocop:enable Layout/LineLength
                  end

                  line do
                    plain "   to eq "
                    # rubocop:disable Layout/LineLength
                    expected %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                    # rubocop:enable Layout/LineLength
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  expected_line %|-   "Afghanistan",|
                  actual_line %|+   "Zambia",|
                  plain_line %|    "Aland Islands",|
                  plain_line %|    "Albania",|
                  plain_line %|    "Algeria",|
                  plain_line %|    "American Samoa",|
                  plain_line %|    "Andorra",|
                  plain_line %|    "Angola",|
                  plain_line %|    "Anguilla",|
                  plain_line %|    "Antarctica",|
                  plain_line %|    "Antigua And Barbuda",|
                  plain_line %|    "Argentina",|
                  plain_line %|    "Armenia",|
                  plain_line %|    "Aruba",|
                  expected_line %|-   "Australia"|
                  actual_line %|+   "Zimbabwe"|
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "when comparing two multi-dimensional data structures which feature large unchanged sections" do
    context "if diff_elision_enabled is set to true" do
      it "elides the unchanged sections, preserving <maximum> number of lines within all unchanged sections (including the elision marker)" do
        # TODO see if we can correct the order of the keys here so it's not
        # totally weird
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              {
                "user_id": "18949452",
                "user": {
                  "id": 18949452,
                  "name": "Financial Times",
                  "screen_name": "FT",
                  "location": "London",
                  "entities": {
                    "url": {
                      "urls": [
                        {
                          "url": "http://t.co/dnhLQpd9BY",
                          "expanded_url": "http://www.ft.com/",
                          "display_url": "ft.com",
                          "indices": [
                            0,
                            22
                          ]
                        }
                      ]
                    },
                    "description": {
                      "urls": [
                        {
                          "url": "https://t.co/5BsmLs9y1Z",
                          "expanded_url": "http://FT.com",
                          "indices": [
                            65,
                            88
                          ]
                        }
                      ]
                    }
                  },
                  "listed_count": 37009,
                  "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                  "favourites_count": 38,
                  "utc_offset": nil,
                  "time_zone": nil,
                  "geo_enabled": false,
                  "verified": true,
                  "statuses_count": 273860,
                  "media_count": 51044,
                  "contributors_enabled": false,
                  "is_translator": false,
                  "is_translation_enabled": false,
                  "profile_background_color": "FFF1E0",
                  "profile_background_image_url_https": "https://abs.twimg.com/images/themes/theme1/bg.png",
                  "profile_background_tile": false,
                  "profile_image_url": "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                  "profile_image_extensions": {
                    "mediaStats": {
                      "r": {
                        "missing": nil
                      },
                      "ttl": -1
                    }
                  },
                  "profile_banner_extensions": {},
                  "blocking": false,
                  "blocked_by": false,
                  "want_retweets": false,
                  "advertiser_account_type": "none",
                  "advertiser_account_service_levels": [],
                  "profile_interstitial_type": "",
                  "business_profile_state": "none",
                  "translator_type": "none",
                  "followed_by": false,
                  "ext": {
                    "highlightedLabel": {
                      "ttl": -1
                    }
                  },
                  "require_some_consent": false
                },
                "token": "117"
              }
            ]
            actual = [
              {
                "user_id": "18949452",
                "user": {
                  "id": 18949452,
                  "name": "Financial Times",
                  "screen_name": "FT",
                  "location": "London",
                  "url": "http://t.co/dnhLQpd9BY",
                  "entities": {
                    "url": {
                      "urls": [
                        {
                          "url": "http://t.co/dnhLQpd9BY",
                          "expanded_url": "http://www.ft.com/",
                          "display_url": "ft.com",
                          "indices": [
                            0,
                            22
                          ]
                        }
                      ]
                    },
                    "description": {
                      "urls": [
                        {
                          "url": "https://t.co/5BsmLs9y1Z",
                          "display_url": "FT.com",
                          "indices": [
                            65,
                            88
                          ]
                        }
                      ]
                    }
                  },
                  "protected": false,
                  "listed_count": 37009,
                  "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                  "favourites_count": 38,
                  "utc_offset": nil,
                  "time_zone": nil,
                  "geo_enabled": false,
                  "verified": true,
                  "statuses_count": 273860,
                  "media_count": 51044,
                  "contributors_enabled": false,
                  "is_translator": false,
                  "is_translation_enabled": false,
                  "profile_background_color": "FFF1E0",
                  "profile_background_image_url": "http://abs.twimg.com/images/themes/theme1/bg.png",
                  "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                  "profile_image_extensions": {
                    "mediaStats": {
                      "r": {
                        "missing": nil
                      },
                      "ttl": -1
                    }
                  },
                  "profile_banner_extensions": {},
                  "blocking": false,
                  "blocked_by": false,
                  "want_retweets": false,
                  "advertiser_account_type": "none",
                  "profile_interstitial_type": "",
                  "business_profile_state": "none",
                  "translator_type": "none",
                  "followed_by": false,
                  "ext": {
                    "highlightedLabel": {
                      "ttl": -1
                    }
                  },
                  "require_some_consent": false
                },
                "token": "117"
              }
            ]
            expect(actual).to #{matcher}(expected)
          TEST
          program =
            make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: true,
                diff_elision_maximum: 10
              }
            )

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected "
                    # rubocop:disable Layout/LineLength
                    actual %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", url: "http://t.co/dnhLQpd9BY", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", display_url: "FT.com", indices: [65, 88] }] } }, protected: false, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                    # rubocop:enable Layout/LineLength
                  end

                  line do
                    plain "   to eq "
                    # rubocop:disable Layout/LineLength
                    expected %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", expanded_url: "http://FT.com", indices: [65, 88] }] } }, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_background_tile: false, profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", advertiser_account_service_levels: [], profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                    # rubocop:enable Layout/LineLength
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  plain_line "    {"
                  plain_line %|      user_id: "18949452",|
                  plain_line "      user: {"
                  plain_line "        id: 18949452,"
                  plain_line %|        name: "Financial Times",|
                  plain_line %|        screen_name: "FT",|
                  plain_line %|        location: "London",|
                  actual_line %|+       url: "http://t.co/dnhLQpd9BY",|
                  plain_line "        entities: {"
                  plain_line "          url: {"
                  plain_line "            urls: ["
                  elision_marker_line "              # ..."
                  plain_line "            ]"
                  plain_line "          },"
                  plain_line "          description: {"
                  plain_line "            urls: ["
                  plain_line "              {"
                  elision_marker_line "                # ..."
                  expected_line %|-               expanded_url: "http://FT.com",|
                  actual_line %|+               display_url: "FT.com",|
                  plain_line "                indices: ["
                  plain_line "                  65,"
                  plain_line "                  88"
                  plain_line "                ]"
                  plain_line "              }"
                  plain_line "            ]"
                  plain_line "          }"
                  plain_line "        },"
                  actual_line "+       protected: false,"
                  elision_marker_line "        # ..."
                  expected_line %|-       profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png",|
                  expected_line "-       profile_background_tile: false,"
                  expected_line %|-       profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
                  actual_line %|+       profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png",|
                  plain_line %|        profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
                  plain_line %|        profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592",|
                  plain_line "        profile_image_extensions: {"
                  elision_marker_line "          # ..."
                  plain_line "        },"
                  plain_line "        profile_banner_extensions: {},"
                  plain_line "        blocking: false,"
                  plain_line "        blocked_by: false,"
                  plain_line "        want_retweets: false,"
                  plain_line %|        advertiser_account_type: "none",|
                  expected_line "-       advertiser_account_service_levels: [],"
                  elision_marker_line "        # ..."
                  plain_line "      },"
                  plain_line %|      token: "117"|
                  plain_line "    }"
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "if diff_elision_enabled is set to false" do
      it "does not elide anything" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              {
                "user_id": "18949452",
                "user": {
                  "id": 18949452,
                  "name": "Financial Times",
                  "screen_name": "FT",
                  "location": "London",
                  "entities": {
                    "url": {
                      "urls": [
                        {
                          "url": "http://t.co/dnhLQpd9BY",
                          "expanded_url": "http://www.ft.com/",
                          "display_url": "ft.com",
                          "indices": [
                            0,
                            22
                          ]
                        }
                      ]
                    },
                    "description": {
                      "urls": [
                        {
                          "url": "https://t.co/5BsmLs9y1Z",
                          "expanded_url": "http://FT.com",
                          "indices": [
                            65,
                            88
                          ]
                        }
                      ]
                    }
                  },
                  "listed_count": 37009,
                  "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                  "favourites_count": 38,
                  "utc_offset": nil,
                  "time_zone": nil,
                  "geo_enabled": false,
                  "verified": true,
                  "statuses_count": 273860,
                  "media_count": 51044,
                  "contributors_enabled": false,
                  "is_translator": false,
                  "is_translation_enabled": false,
                  "profile_background_color": "FFF1E0",
                  "profile_background_image_url_https": "https://abs.twimg.com/images/themes/theme1/bg.png",
                  "profile_background_tile": false,
                  "profile_image_url": "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                  "profile_image_extensions": {
                    "mediaStats": {
                      "r": {
                        "missing": nil
                      },
                      "ttl": -1
                    }
                  },
                  "profile_banner_extensions": {},
                  "blocking": false,
                  "blocked_by": false,
                  "want_retweets": false,
                  "advertiser_account_type": "none",
                  "advertiser_account_service_levels": [],
                  "profile_interstitial_type": "",
                  "business_profile_state": "none",
                  "translator_type": "none",
                  "followed_by": false,
                  "ext": {
                    "highlightedLabel": {
                      "ttl": -1
                    }
                  },
                  "require_some_consent": false
                },
                "token": "117"
              }
            ]
            actual = [
              {
                "user_id": "18949452",
                "user": {
                  "id": 18949452,
                  "name": "Financial Times",
                  "screen_name": "FT",
                  "location": "London",
                  "url": "http://t.co/dnhLQpd9BY",
                  "entities": {
                    "url": {
                      "urls": [
                        {
                          "url": "http://t.co/dnhLQpd9BY",
                          "expanded_url": "http://www.ft.com/",
                          "display_url": "ft.com",
                          "indices": [
                            0,
                            22
                          ]
                        }
                      ]
                    },
                    "description": {
                      "urls": [
                        {
                          "url": "https://t.co/5BsmLs9y1Z",
                          "display_url": "FT.com",
                          "indices": [
                            65,
                            88
                          ]
                        }
                      ]
                    }
                  },
                  "protected": false,
                  "listed_count": 37009,
                  "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                  "favourites_count": 38,
                  "utc_offset": nil,
                  "time_zone": nil,
                  "geo_enabled": false,
                  "verified": true,
                  "statuses_count": 273860,
                  "media_count": 51044,
                  "contributors_enabled": false,
                  "is_translator": false,
                  "is_translation_enabled": false,
                  "profile_background_color": "FFF1E0",
                  "profile_background_image_url": "http://abs.twimg.com/images/themes/theme1/bg.png",
                  "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                  "profile_image_extensions": {
                    "mediaStats": {
                      "r": {
                        "missing": nil
                      },
                      "ttl": -1
                    }
                  },
                  "profile_banner_extensions": {},
                  "blocking": false,
                  "blocked_by": false,
                  "want_retweets": false,
                  "advertiser_account_type": "none",
                  "profile_interstitial_type": "",
                  "business_profile_state": "none",
                  "translator_type": "none",
                  "followed_by": false,
                  "ext": {
                    "highlightedLabel": {
                      "ttl": -1
                    }
                  },
                  "require_some_consent": false
                },
                "token": "117"
              }
            ]
            expect(actual).to #{matcher}(expected)
          TEST
          program =
            make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: false,
                diff_elision_maximum: 10
              }
            )

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected "
                    # rubocop:disable Layout/LineLength
                    actual %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", url: "http://t.co/dnhLQpd9BY", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", display_url: "FT.com", indices: [65, 88] }] } }, protected: false, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                    # rubocop:enable Layout/LineLength
                  end

                  line do
                    plain "   to eq "
                    # rubocop:disable Layout/LineLength
                    expected %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", expanded_url: "http://FT.com", indices: [65, 88] }] } }, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_background_tile: false, profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", advertiser_account_service_levels: [], profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                    # rubocop:enable Layout/LineLength
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  plain_line "    {"
                  plain_line %|      user_id: "18949452",|
                  plain_line "      user: {"
                  plain_line "        id: 18949452,"
                  plain_line %|        name: "Financial Times",|
                  plain_line %|        screen_name: "FT",|
                  plain_line %|        location: "London",|
                  actual_line %|+       url: "http://t.co/dnhLQpd9BY",|
                  plain_line "        entities: {"
                  plain_line "          url: {"
                  plain_line "            urls: ["
                  plain_line "              {"
                  plain_line %|                url: "http://t.co/dnhLQpd9BY",|
                  plain_line %|                expanded_url: "http://www.ft.com/",|
                  plain_line %|                display_url: "ft.com",|
                  plain_line "                indices: ["
                  plain_line "                  0,"
                  plain_line "                  22"
                  plain_line "                ]"
                  plain_line "              }"
                  plain_line "            ]"
                  plain_line "          },"
                  plain_line "          description: {"
                  plain_line "            urls: ["
                  plain_line "              {"
                  plain_line %|                url: "https://t.co/5BsmLs9y1Z",|
                  expected_line %|-               expanded_url: "http://FT.com",|
                  actual_line %|+               display_url: "FT.com",|
                  plain_line "                indices: ["
                  plain_line "                  65,"
                  plain_line "                  88"
                  plain_line "                ]"
                  plain_line "              }"
                  plain_line "            ]"
                  plain_line "          }"
                  plain_line "        },"
                  actual_line "+       protected: false,"
                  plain_line "        listed_count: 37009,"
                  plain_line %|        created_at: "Tue Jan 13 19:28:24 +0000 2009",|
                  plain_line "        favourites_count: 38,"
                  plain_line "        utc_offset: nil,"
                  plain_line "        time_zone: nil,"
                  plain_line "        geo_enabled: false,"
                  plain_line "        verified: true,"
                  plain_line "        statuses_count: 273860,"
                  plain_line "        media_count: 51044,"
                  plain_line "        contributors_enabled: false,"
                  plain_line "        is_translator: false,"
                  plain_line "        is_translation_enabled: false,"
                  plain_line %|        profile_background_color: "FFF1E0",|
                  expected_line %|-       profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png",|
                  expected_line "-       profile_background_tile: false,"
                  expected_line %|-       profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
                  actual_line %|+       profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png",|
                  plain_line %|        profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
                  plain_line %|        profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592",|
                  plain_line "        profile_image_extensions: {"
                  plain_line "          mediaStats: {"
                  plain_line "            r: {"
                  plain_line "              missing: nil"
                  plain_line "            },"
                  plain_line "            ttl: -1"
                  plain_line "          }"
                  plain_line "        },"
                  plain_line "        profile_banner_extensions: {},"
                  plain_line "        blocking: false,"
                  plain_line "        blocked_by: false,"
                  plain_line "        want_retweets: false,"
                  plain_line %|        advertiser_account_type: "none",|
                  expected_line "-       advertiser_account_service_levels: [],"
                  plain_line %|        profile_interstitial_type: "",|
                  plain_line %|        business_profile_state: "none",|
                  plain_line %|        translator_type: "none",|
                  plain_line "        followed_by: false,"
                  plain_line "        ext: {"
                  plain_line "          highlightedLabel: {"
                  plain_line "            ttl: -1"
                  plain_line "          }"
                  plain_line "        },"
                  plain_line "        require_some_consent: false"
                  plain_line "      },"
                  plain_line %|      token: "117"|
                  plain_line "    }"
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end
end
