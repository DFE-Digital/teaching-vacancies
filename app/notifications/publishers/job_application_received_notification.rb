class Publishers::JobApplicationReceivedNotification < Noticed::Base
  deliver_by :database
  param :vacancy
end
