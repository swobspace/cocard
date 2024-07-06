module BooleanHelper
  def to_boolean(value)
    return true if ['ja', 'true', '1', 'yes', 'on', 't'].include?(value.to_s.downcase)
    return false if ['nein', 'false', '0', 'no', 'off', 'f'].include?(value.to_s.downcase)  
    return nil
  end
end
