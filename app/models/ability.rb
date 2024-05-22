# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :search, :search_form, :query, :to => :read
    alias_action :sindex, :to => :read

    @user = user
    if @user.nil?
      can :read, Home
    elsif @user.is_admin?
      can :manage, :all
      cannot %i[update destroy], :roles, ro: true
    elsif @user.role?(:reader)
      can [:read, :navigate], :all
    end
  end
end
