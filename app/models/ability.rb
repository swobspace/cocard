# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :search, :search_form, :query, :to => :read
    alias_action :sindex, :ping, :to => :read

    @user = user
    if @user.nil? 
      # redirected to login page

    # role Admin overrides all other roles
    elsif @user.is_admin?
      can :manage, :all
      cannot %i[update destroy], Wobauth::Role

    # user has at least one role, perhaps more
    elsif @user.authorities.present?
      can [:read, :navigate], :all
      cannot [:read, :navigate], ClientCertificate

      if @user.role?(:reader)
        # nothing for now
      end

      if @user.role?(:connector_manager)
        can :manage, Connector
      else
        cannot [:read], Connector, :id_contract
      end

      if @user.role?(:card_manager)
        can :manage, Card
      else
        cannot [:read], Card, :private_information
      end

      if @user.role?(:card_terminal_manager)
        can :manage, CardTerminal
      end

      if @user.role?(:verify_pin)
        can [:read, :verify], VerifyPin
        can [:get_pin_status, :verify_pin], Card
      else
        cannot [:read, :verify], VerifyPin
      end

      if @user.role?(:support)
        can [:update], CardTerminal, [:room, :contact, :plugged_in]
      end
      
    else
      # user present, but no role assigned
    end
  end
end
