class DeleteOldNonDraftJobApplicationsJob < ApplicationJob
  queue_as :low

  OLD_THRESHOLD = 5.years.ago.freeze

  def perform
    JobApplication.after_submission
                  .where("submitted_at < ?", OLD_THRESHOLD)
                  .order("submitted_at desc")
                  .group_by(&:jobseeker_id).each_value do |ja_group|
      if JobApplication.where("submitted_at >= ?", OLD_THRESHOLD).where(jobseeker: ja_group.first.jobseeker).exists?
        ja_group.each(&:destroy)
      else
        ja_group[1..].each(&:destroy)
      end
    end
  end
end
