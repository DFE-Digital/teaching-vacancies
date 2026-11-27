class Jobseekers::AccountsController < Jobseekers::BaseController
  def show
    @unread_notifications_count = current_jobseeker.notifications.unread.count
  end

  def help; end

  def account_found; end

  def account_not_found; end
end
