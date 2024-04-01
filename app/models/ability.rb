# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user
    if @user.nil?
      can :read, Home
    else
      can :manage, :all
    end
  end
end
