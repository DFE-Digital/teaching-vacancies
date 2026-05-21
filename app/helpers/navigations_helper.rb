module NavigationsHelper
  def manage_jobs_active?
    current_page?(organisation_jobs_with_type_path) || request.original_fullpath =~ %r{^/organisation/jobs}
  end

  def schools_in_your_trust_active?
    request.original_fullpath =~ %r{^/publishers/schools}
  end

  def your_account_active?
    !current_page?(jobseekers_profile_path) && request.path.start_with?("/jobseekers")
  end
end
