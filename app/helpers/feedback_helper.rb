module FeedbackHelper
  def visit_purpose_options
    [['Find a job in teaching', 1],
     ['List a teaching job on the service', 2],
     ['Something else (tell us in the box below)', 3]]
  end

  def rating_options
    [['Very satisfied', 5],
     ['Satisfied', 4],
     ['Neither satisfied or dissatisfied', 3],
     ['Dissatisfied', 2],
     ['Very dissatisfied', 1]]
  end
end
