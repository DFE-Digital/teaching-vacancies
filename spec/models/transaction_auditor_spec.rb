require "rails_helper"

RSpec.describe TransactionAuditor, type: :model do
  let(:date) { Time.zone.today }
  context "validations" do
    it "validates uniqueness of task and date" do
      TransactionAuditor.create(task: "unique task", date: date)
      duplicate = TransactionAuditor.new(task: "unique task", date: date)

      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:task]).to include("must have a unique entry for a date")
    end
  end
end

RSpec.describe TransactionAuditor::Logger, type: :model do
  let(:date) { Time.zone.today }
  describe "#performed?" do
    context "checks if a task has already been performed successfuly" do
      it "returns true if the task has already been executed" do
        TransactionAuditor::Logger.new("a-task", date).log_success
        expect(TransactionAuditor::Logger.new("a-task", date).performed?).to be true
      end

      it "returns false if the task has failed to be performed" do
        TransactionAuditor::Logger.new("another-task", date).log_failure
        expect(TransactionAuditor::Logger.new("a-task", date).performed?).to be false
      end
    end
  end

  describe "#log_success" do
    it "logs the successful execution of a task" do
      TransactionAuditor::Logger.new("a-task", date).log_success
      expect(TransactionAuditor.find_by(task: "a-task").success).to be true
    end

    it "does not create a duplicate entry for a task execution" do
      TransactionAuditor::Logger.new("a-task", date).log_success
      TransactionAuditor::Logger.new("a-task", date).log_success

      expect(TransactionAuditor.where(task: "a-task").count).to eq(1)
    end

    it "updates a failed execution to successful" do
      TransactionAuditor::Logger.new("a-task", date).log_failure
      TransactionAuditor::Logger.new("a-task", date).log_success

      task_audit = TransactionAuditor.where(task: "a-task")
      expect(task_audit.count).to eq(1)
      expect(task_audit.first.success).to eq(true)
    end
  end

  describe "#log_failure" do
    it "logs the failed execution of a task" do
      TransactionAuditor::Logger.new("a-task", date).log_failure
      expect(TransactionAuditor.find_by(task: "a-task").success).to be false
    end

    it "does not create a duplicate entry for a task execution" do
      TransactionAuditor::Logger.new("a-task", date).log_failure
      TransactionAuditor::Logger.new("a-task", date).log_failure

      expect(TransactionAuditor.where(task: "a-task").count).to eq(1)
    end
  end
end
