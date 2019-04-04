module FeedbackHelper
  def rating_options
    [['Very satisfied', 5],
     ['Satisfied', 4],
     ['Neither satisfied or dissatisfied', 3],
     ['Dissatisfied', 2],
     ['Very dissatisfied', 1]]
  end
end
