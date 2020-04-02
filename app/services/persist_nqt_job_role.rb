module PersistNQTJobRole
  # Only necessary until changes to search are implemented
  # TODO remove after migration to remove newly qualified teacher column
  def persist_nqt_job_role_to_nqt_attribute(form)
    job_roles = params.require(form)[:job_roles]

    if job_roles&.include?(I18n.t('jobs.job_role_options.nqt_suitable'))
      params[form][:newly_qualified_teacher] = true
    elsif job_roles
      params[form][:newly_qualified_teacher] = false
    end
  end
end
