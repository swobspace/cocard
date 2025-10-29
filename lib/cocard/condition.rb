module Cocard
  module Condition

    def set_condition(state, message)
      self[:condition] = state
      self[:condition_message] =  [ shortcut(state),
                                    I18n.t(state, scope: 'cocard.condition'),
                                    message
                                  ].compact.join(' ')
      if state == Cocard::States::OK
        if respond_to?(:last_ok) and respond_to?(:last_check) and
           last_check >= Cocard.grace_period.before(Time.current)
          self[:last_ok] = Time.current
        end
        if respond_to?(:close_acknowledge)
          close_acknowledge
        end
      end
    end

  private

    def shortcut(condition)
      shortcut = Cocard::States::flag(condition)
    end

  end
end
