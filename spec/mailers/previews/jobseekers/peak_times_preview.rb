# Preview url
# http://localhost:3000/rails/mailers/jobseekers/peak_times/reminder
class Jobseekers::PeakTimesPreview < ActionMailer::Preview
  def reminder
    Jobseekers::PeakTimesMailer.reminder(Jobseeker.email_opt_in.limit(1).pick(:id))
  end
end
