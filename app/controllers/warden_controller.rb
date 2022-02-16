# The actions in this controller are used by devise/warden when there is
# a "failure" in authentication.  This can be when the user attempts
# something they need to be logged in for (forced login), they try to log in but
# it fails (failed login), or their session times out (a special case of forced
# login).  Warden/devise call this a "recall" action.
#
# See the `Authenticated` controller mixin and session controller(s) for where
# we hook these in.
class WardenController < ApplicationController
  include ReturnPathTracking::Helpers

  def jobseeker_forced_login
    forced_login(:jobseeker)
  end

  def publisher_forced_login
    forced_login(:publisher)
  end

  def jobseeker_failed_login
    failed_login(:jobseeker)
  end

  def publisher_failed_login
    failed_login(:jobseeker)
  end

  private

  def forced_login(scope)
    if attempted_path
      store_return_location(attempted_path, scope: scope)
    end

    params_hash = {
      redirected: true,
    }

    params_hash[:login_failure] = login_failure if login_failure

    redirect_to send("new_#{scope}_session_path", params_hash)
  end

  def failed_login(scope)
    redirect_to send("new_#{scope}_session_path", login_failure: login_failure)
  end

  def attempted_path
    request.env.dig("warden.options", :attempted_path)
  end

  def login_failure
    return :timeout if flash[:timedout]

    request.env.dig("warden.options", :message)
  end
end
