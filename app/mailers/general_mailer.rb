class GeneralMailer < ApplicationMailer

  default from: 'Denis Daigle <denis@blogembed.com>'

  def general_email(recipient_name, recipient_email, subject, body, link)
    @recipient_name = recipient_name
    @recipient_email = recipient_email
    @subject = subject
    @body = body
    @link = link
    mail(to: "#{@recipient_name} <#{@recipient_email}>", subject: @subject)
  end
  
end
