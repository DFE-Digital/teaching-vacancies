module FeedbackHelper
  def visit_purpose_options
    [['Find a job in teaching', :find_teaching_job],
     ['List a teaching job on the service', :list_teaching_job],
     ['Something else (tell us in the box below)', :other_purpose]]
  end

  def rating_options
    [['Very satisfied', 5],
     ['Satisfied', 4],
     ['Neither satisfied or dissatisfied', 3],
     ['Dissatisfied', 2],
     ['Very dissatisfied', 1]]
  end
end
