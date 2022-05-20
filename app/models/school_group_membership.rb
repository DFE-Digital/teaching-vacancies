class SchoolGroupMembership < ApplicationRecord
  # Refuse to delete "stale" school group memberships if we would delete more than this many.
  # Last line of defence against corrupt school data imports.
  MAX_RECORDS_TO_BULK_DELETE = 150

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
    Sentry.capture_message("Memberships to delete, by SchoolGroup: #{to_delete}", level: :info)

    if marked_for_deletion.count > MAX_RECORDS_TO_BULK_DELETE
      raise "Exceeded maximum count of `SchoolGroupMembership`s to bulk delete "\
            "(#{marked_for_deletion.count})"
    end

    marked_for_deletion.destroy_all
  end
end
