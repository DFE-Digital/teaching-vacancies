class TransactionAuditor < ApplicationRecord
  validates :task, uniqueness: { scope: :date }

  class Logger
    attr_reader :task, :date

    def initialize(task, date)
      @task = task
      @date = date
    end

    def performed?
      TransactionAuditor.exists?(task: task, date: date, success: true)
    end

    def log_success
      log(task, date, true)
    end

    def log_failure
      log(task, date, false)
    end

    private

    def log(task, date, success)
      TransactionAuditor.where(task: task, date: date).first_or_create.update(success: success)
    end
  end
end
