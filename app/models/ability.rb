# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :search, :search_form, :query, :to => :read
    alias_action :sindex, :ping, :to => :read

    @user = user
    if @user.nil? 
      # redirected to login page
    elsif @user.is_admin?
      can :manage, :all
      cannot %i[update destroy], :roles, ro: true
    else
      can [:read, :navigate], :all
      cannot [:read, :navigate], ClientCertificate
    end
  end
end
