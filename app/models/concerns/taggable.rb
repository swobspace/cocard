module Taggable
  extend ActiveSupport::Concern
  included do
    attr_accessor :tag_list_input

    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings

    before_validation :set_tags_from_input

    scope :tagged_with, -> (tag_name) { joins(:tags).where(tags: { name: tag_name }).distinct }
  end

  def tag_list
    tags.map(&:name)
  end

  def tag_list=(array)
    cleaned_tags = array.map(&:strip).reject(&:empty?)
    self.tags = cleaned_tags.map { |tag_name| Tag.find_or_create_by(name: tag_name)}
  end

  def set_tags_from_input
    new_tags = JSON.parse(self.tag_list_input.presence || "[]").map { |h| h["value"] }
    # self.tags.delete_all
    tags_to_remove = tag_list - new_tags
    self.tags.where(name: tags_to_remove) do |tag|
      self.tags.delete(tag)
    end
    self.tag_list = new_tags
  end

  module ClassMethods
    def tags
      Tag.joins(:taggings)
        .where(taggings: { taggable_type: name })
        .order(:name)
        .map(&:name)
    end
  end
end

