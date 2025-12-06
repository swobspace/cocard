# frozen_string_literal: true

class TIClient::SchedulerComponent < ViewComponent::Base
  def initialize(ti_client:)
    @ti_client = ti_client
    @state = ti_client.hintergrundaufgaben
  end

  def state_class
    case state
    when "RUNNING"
      "badge text-bg-success"
    when "PAUSED"
      "badge text-bg-alert"
    else
      "badge text-bg-secondary"
    end
  end

private
  attr_reader :ti_client, :state
end
