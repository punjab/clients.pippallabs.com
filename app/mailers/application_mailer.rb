class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAIL_FROM", "leads@pippallabs.test") }
  layout "mailer"
end
