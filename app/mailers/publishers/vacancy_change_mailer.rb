class Publishers::VacancyChangeMailer < Publishers::BaseMailer
  def notify(publisher:)
    @publisher = publisher
    @subject = I18n.t("publishers.vacancy_change_mailer.notify.subject")

    send_email(to: publisher.email, subject: @subject)
  end
end
