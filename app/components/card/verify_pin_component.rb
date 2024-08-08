# frozen_string_literal: true

class Card::VerifyPinComponent < ViewComponent::Base
  def initialize(card:, context:, force: false)
    @card = card
    @context = context
    @force = force
    @card_context = CardContext.where(card_id: card.id, context_id: context.id).first
  end

  def render?
    force || (card_context.pin_status == 'VERIFIABLE' && card_context.left_tries.to_i > 1)
  end

private
  attr_reader :card, :context, :force, :card_context

end
