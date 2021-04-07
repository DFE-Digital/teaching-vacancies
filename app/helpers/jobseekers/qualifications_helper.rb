module Jobseekers::QualificationsHelper
  def param_key_digit(key)
    key.to_s.split(/\A(subject|grade)/).last.match(/\A\d+\z/).to_s
  end
end
