module ProfilesHelper
  def jobseeker_status(profile)
    [qualified_teacher_status_string(profile), right_to_work_status_string(profile)].compact.join(" ")
  end

  private

  def qualified_teacher_status_string(profile)
    case profile.qualified_teacher_status
    when "on_track"
      "On track to receive QTS."
    when "yes"
      "QTS gained in #{profile.qualified_teacher_status_year}."
    when "no"
      "Does not have QTS."
    else
      ""
    end
  end

  def right_to_work_status_string(profile)
    return nil if profile&.personal_details&.has_right_to_work_in_uk.nil?

    profile.personal_details.has_right_to_work_in_uk? ? "Has the right to work in the UK." : "Does not have the right to work in the UK."
  end
end
