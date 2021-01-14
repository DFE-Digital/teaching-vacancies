class JobseekerFailureApp < Devise::FailureApp
  UNAUTHENTICATED_FLASH_MESSAGES = {
    "/jobseekers/saved_jobs/new": { type: :notice, content: "messages.jobseekers.saved_jobs.unauthenticated" },
  }.freeze

  def redirect
    if custom_unauthenticated_flash?
      add_flash_message
      redirect_to redirect_url
    else
      super
    end
  end

  private

  def add_flash_message
    flash_info = UNAUTHENTICATED_FLASH_MESSAGES[request.original_fullpath.split("?").first.to_sym]
    flash[flash_info[:type]] = I18n.t(flash_info[:content])
  end

  def custom_unauthenticated_flash?
    UNAUTHENTICATED_FLASH_MESSAGES.key?(request.original_fullpath.split("?").first.to_sym)
  end
end
