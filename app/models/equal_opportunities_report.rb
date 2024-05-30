class EqualOpportunitiesReport < ApplicationRecord
  belongs_to :vacancy

  validates :vacancy, uniqueness: true

  def trigger_event
    event = DfE::Analytics::Event.new.with_type(:equal_opportunities_report_published)
    DfE::Analytics::SendEvents.do([event])
  end
end
