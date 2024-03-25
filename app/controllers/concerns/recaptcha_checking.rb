module RecaptchaChecking
  extend ActiveSupport::Concern

  SUSPICIOUS_RECAPTCHA_V3_THRESHOLD = 0.5

  # https://github.com/ambethia/recaptcha
  # Our approach combines Recaptcha V3 with Recaptcha V2 as a fallback, as documented here:
  # https://github.com/ambethia/recaptcha?tab=readme-ov-file#examples

  def recaptcha_protected(form: nil, fallback_template: :new)
    if recaptcha_is_valid?
      yield
    else
      @show_recaptcha = true
      form&.errors&.add(:recaptcha, t("recaptcha.error"))
      render fallback_template
    end
  end

  def recaptcha_is_valid?
    recaptcha_v3_is_valid? || recaptcha_v2_is_valid?
  end

  def recaptcha_v3_is_valid?
    verify_recaptcha(action: controller_name,
                     minimum_score: SUSPICIOUS_RECAPTCHA_V3_THRESHOLD,
                     secret_key: ENV.fetch("RECAPTCHA_V3_SECRET_KEY", ""))
  end

  def recaptcha_v2_is_valid?
    verify_recaptcha # Uses the default secret key from the initializer (V2)
  end
end
