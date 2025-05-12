namespace :db do
  desc "Update working_patterns to replace 'job_share' with 'part_time' and set is_job_share to true"
  task remove_double_linkings: :environment do
    JobApplication.includes(:training_and_cpds, :employments, :professional_body_memberships, :qualifications).find_each do |ja|
      JobApplication.transaction do
        ja.training_and_cpds.reject { |t| t.jobseeker_profile_id.nil? }.each { |tr| tr.update_column(:jobseeker_profile_id, nil) }
        ja.employments.reject { |t| t.jobseeker_profile_id.nil? }.each { |tr| tr.update_column(:jobseeker_profile_id, nil) }
        ja.professional_body_memberships.reject { |t| t.jobseeker_profile_id.nil? }.each { |tr| tr.update_column(:jobseeker_profile_id, nil) }
        ja.qualifications.reject { |t| t.jobseeker_profile_id.nil? }.each { |tr| tr.update_column(:jobseeker_profile_id, nil) }
      end
    end
    JobseekerProfile.includes(:training_and_cpds, :employments, :professional_body_memberships, :qualifications).find_each do |ja|
      JobseekerProfile.transaction do
        ja.training_and_cpds.reject { |t| t.job_application_id.nil? }.each { |tr| tr.update_column(:job_application_id, nil) }
        ja.employments.reject { |t| t.job_application_id.nil? }.each { |tr| tr.update_column(:job_application_id, nil) }
        ja.professional_body_memberships.reject { |t| t.job_application_id.nil? }.each { |tr| tr.update_column(:job_application_id, nil) }
        ja.qualifications.reject { |t| t.job_application_id.nil? }.each { |tr| tr.update_column(:job_application_id, nil) }
      end
    end
  end
end
