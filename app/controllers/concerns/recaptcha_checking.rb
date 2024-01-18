module RecaptchaChecking
  extend ActiveSupport::Concern

  SUSPICIOUS_RECAPTCHA_THRESHOLD = 0.5

  # https://github.com/ambethia/recaptcha#verify_recaptcha
  # https://github.com/ambethia/recaptcha#recaptcha_reply
  def recaptcha_is_invalid?(model = nil)
    !verify_recaptcha(model: model, action: controller_name, minimum_score: SUSPICIOUS_RECAPTCHA_THRESHOLD) && recaptcha_reply
  end

  def handle_invalid_recaptcha(form: nil, score: nil)
    form_name = form.class.name.gsub("::", "").underscore.humanize if form.present?
    Sentry.with_scope do |scope|
      scope.set_tags("form.name": form_name, "recaptcha.score": score)
      Sentry.capture_message("Invalid recaptcha", level: :warning)
    end
    redirect_to invalid_recaptcha_path
  end
end
