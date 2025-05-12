module Publishers
  module JobApplication
    class MarkAsReceivedForm
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      attribute :reference_satisfactory, :boolean
      validates :reference_satisfactory, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
