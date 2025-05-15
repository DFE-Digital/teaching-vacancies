class Publishers::PreInterviewChecksMailer < Publishers::BaseMailer
  def declarations(publisher:)
    @template = template
    @publisher = publisher
    @to = publisher.email

    @login_token = login_key_id

    view_mail(@template, to: @to, subject: I18n.t("publishers.temp_login.email.subject"))
  end
end
