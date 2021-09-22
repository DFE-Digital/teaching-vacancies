class SchoolGroupMembership < ApplicationRecord
  belongs_to :school
  belongs_to :school_group

  scope :marked_for_deletion, -> { where(do_not_delete: false) }

  def self.mark_all_records_for_deletion
    update_all(do_not_delete: false)
  end

  def self.delete_records_marked_for_deletion
    to_delete = marked_for_deletion.map { |m| m.school_group.name }
                                   .group_by { |x| x }
                                   .transform_values(&:length)
    Rollbar.log(:info, "Memberships to delete, by SchoolGroup: #{to_delete}")

    raise "Skipped deleting suspiciously high number of `SchoolGroupMembership`s (#{marked_for_deletion.count})" if marked_for_deletion.count > 150

    marked_for_deletion.delete_all
  end
end
