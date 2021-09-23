module NavigationsHelper
  def find_jobs_active?
    current_page?(root_path) || request.original_fullpath =~ %r{jobs[/?]}
  end

  def your_account_active?
    request.path.start_with?("/jobseekers")
  end
end
