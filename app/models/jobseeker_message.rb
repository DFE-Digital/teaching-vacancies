# frozen_string_literal: true

class JobseekerMessage < Message
  belongs_to :sender, class_name: "Jobseeker"
end
