if Rails.env.production? 
  if Mirco.smtp_settings.nil?
    ActionMailer::Base.delivery_method = :file
  else
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = Cocard.smtp_settings
  end
end
