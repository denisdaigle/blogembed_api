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
  
  def help_email(recipient_name, recipient_email, subject, body)
    @recipient_name = recipient_name
    @recipient_email = recipient_email
    @subject = subject
    @body = body
    mail(to: "#{@recipient_name} <#{@recipient_email}>", from: "BlogEmbed.com Help Team <help@blogembed.com>", subject: @subject)
  end
  
  def hero_email(recipient_name, recipient_email, subject, body)
    @recipient_name = recipient_name
    @recipient_email = recipient_email
    @subject = subject
    @body = body
    mail(to: "#{@recipient_name} <#{@recipient_email}>", from: "Denis Daigle - Creator of BlogEmbed <denis@blogembed.com>", subject: @subject)
  end
  
end
