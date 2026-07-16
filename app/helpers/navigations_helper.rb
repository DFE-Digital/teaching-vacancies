module NavigationsHelper
  def find_jobs_active?
    current_page?(root_path) || request.original_fullpath =~ %r{^/jobs[/?]}
  end

  def manage_jobs_active?
    current_page?(organisation_jobs_with_type_path) || request.original_fullpath =~ %r{^/organisation/jobs}
  end

  def messages_active?
    request.original_fullpath =~ %r{^/publishers/candidate_messages}
  end

  def candidate_profiles_active?
    request.original_fullpath =~ %r{^/publishers/jobseeker_profiles}
  end

  def statistics_active?
    request.original_fullpath =~ %r{^/publishers/current_year_statistics}
  end

  def notifications_active?
    request.original_fullpath =~ %r{^/publishers/notifications}
  end

  def schools_in_your_trust_active?
    request.original_fullpath =~ %r{^/publishers/schools}
  end

  def your_account_active?
    !current_page?(jobseekers_profile_path) && request.path.start_with?("/jobseekers")
  end
end
