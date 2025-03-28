module Publishers
  class BaseMailer < ::GovukNotifyMailer
    include MailerDfeAnalytics
  end
end
