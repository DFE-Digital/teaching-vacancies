class ConvertLegacyJobRolesToJobRolesOnVacancies < ActiveRecord::Migration[5.2]
  def change
    Vacancy.where.not(legacy_job_roles: nil).in_batches(of: 100).each_record do |vacancy|
      job_roles = vacancy.legacy_job_roles.map do |job_role|
        if job_role == I18n.t("jobs.job_role_options.teacher")
          0
        elsif job_role == I18n.t("jobs.job_role_options.leadership")
          1
        elsif job_role == I18n.t("jobs.job_role_options.sen_specialist")
          2
        elsif job_role == I18n.t("jobs.job_role_options.nqt_suitable")
          3
        end
      end
      vacancy.update_columns(job_roles: job_roles)
    end
  end
end
