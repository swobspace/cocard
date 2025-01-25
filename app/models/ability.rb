# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :search, :search_form, :query, :to => :read
    alias_action :sindex, :ping, :to => :read
    alias_action :failed, :to => :read
    alias_action :import_p12_form, :import_p12, :to => :create

    @user = user
    if @user.nil? 
      # redirected to login page

    # role Admin overrides all other roles
    elsif @user.is_admin?
      can :manage, :all
      can :update, CardTerminal, :description
      cannot %i[update destroy], Wobauth::Role

    # user has at least one role, perhaps more
    elsif @user.authorities.present?
      can [:read, :navigate], :all
      can :create, Note
      cannot [:read, :navigate], ClientCertificate

      if @user.role?(:reader)
        # nothing for now
      end

      if @user.role?(:connector_manager)
        can :manage, Connector
        can :manage, Note, notable_type: ['Log', 'Connector']
      else
        cannot [:read], Connector, :id_contract
      end

      if @user.role?(:card_manager)
        can :manage, Card
        can :manage, Note, notable_type: ['Log', 'Card']
        can [:read, :verify], VerifyPin
      else
        cannot [:read], Card, :private_information
      end

      if @user.role?(:card_terminal_manager)
        can :manage, CardTerminal
        can :update, CardTerminal, :description
        can :manage, Note, notable_type: ['Log', 'CardTerminal']
      end

      if @user.role?(:verify_pin)
        can [:read, :verify], VerifyPin
        can [:get_pin_status, :verify_pin], Card
        can [:reboot], Connector
      elsif !@user.role?(:card_manager)
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
