# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user
    if @user.nil?
      can :read, Home
    else
      can :manage, :all
      cannot %i[update destroy], :roles, ro: true
    end
  end
end
