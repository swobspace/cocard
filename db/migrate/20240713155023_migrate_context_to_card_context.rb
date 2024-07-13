class MigrateContextToCardContext < ActiveRecord::Migration[7.1]
  def up
    Card.all.each do |card|
      unless card.context_id.nil?
        CardContext.find_or_create_by(card_id: card.id, context_id: card.context_id)
      end
    end
  end

  def down
    Card.all.each do |card|
      card.update(context_id: card.contexts.first&.id)
    end
  end
end
