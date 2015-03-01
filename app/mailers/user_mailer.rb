class UserMailer < ActionMailer::Base
  default from: "team@interque.co"
  # layout 'mailer'

  def welcome_email(user)
    @user = user
    @url = 'http://jobs.interque.co/login'
    mail(to: @user.email, subject: 'Welcome')
  end
end
