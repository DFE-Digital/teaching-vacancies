# Preview all emails at http://localhost:3000/rails/mailers
class AlertPreview < ActionMailer::Preview
  def alert
    unless Subscription.any? && Vacancy.count > 1
      raise "I don't want to mess up your development database with factory-created records, so this preview won't
            run unless there is >=1 subscription and >=2 vacancies in the database."
    end

    AlertMailer.alert(Subscription.first.id, Vacancy.all.take(2).pluck(:id))
  end
end
