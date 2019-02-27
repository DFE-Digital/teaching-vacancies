class ApplicationMailer < Mail::Notify::Mailer
  add_template_helper(NotifyViewHelper)
end
