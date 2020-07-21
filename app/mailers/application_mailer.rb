class ApplicationMailer < Mail::Notify::Mailer
  add_template_helper(NotifyViewHelper)
  add_template_helper(OrganisationHelper)
end
