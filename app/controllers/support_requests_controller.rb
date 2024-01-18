class SupportRequestsController < ApplicationController
  include RecaptchaChecking

  def new
    @form = SupportRequestForm.new
  end

  def create
    @form = SupportRequestForm.new(form_params)

    if @form.invalid?
      render :new
    elsif recaptcha_is_invalid?
      handle_invalid_recaptcha(form: @form, score: recaptcha_reply["score"])
    else
      Zendesk.create_request!(
        attachments: [@form.screenshot],
        comment: @form.issue,
        email_address: @form.email_address,
        name: @form.name,
        subject: @form.page,
      )

      redirect_to root_path, success: t(".success")
    end
  end

  private

  def form_params
    params.require(:support_request_form).permit(*%I[
      email_address
      is_for_whole_site
      issue
      name
      page
      screenshot
    ])
  end
end
