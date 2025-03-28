# frozen_string_literal: true

require 'zeus'
require 'zeus/plan'
require 'forwardable'

require_relative '../support/test_plan'

class CustomZeusPlan < Zeus::Plan
  extend Forwardable

  def_delegators(
    :@test_plan,
    :after_fork,
    :boot,
    :boot_active_support,
    :boot_active_record,
    :boot_rails,
    :boot_rails_engine_with_action_controller,
    :run_plain_test,
    :run_rspec_active_support_test,
    :run_rspec_active_record_test,
    :run_rspec_rails_test,
    :run_rspec_rails_engine_with_action_controller_test
  )

  def initialize(
    using_outside_of_zeus: false,
    color_enabled: false,
    super_diff_configuration: {}
  )
    super()
    @test_plan =
      TestPlan.new(
        using_outside_of_zeus: using_outside_of_zeus,
        color_enabled: color_enabled,
        super_diff_configuration: super_diff_configuration
      )
  end
end

Zeus.plan = CustomZeusPlan.new
