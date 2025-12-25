class ApplicationMailer < ActionMailer::Base
  default from: -> { Cocard.mail_from }, to: ->{ Cocard.mail_to }
  layout "mailer"
end
