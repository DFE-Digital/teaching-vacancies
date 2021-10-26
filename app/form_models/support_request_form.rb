class SupportRequestForm
  include ActiveModel::Model

  attr_accessor(*%I[
    email_address
    is_for_whole_site
    issue
    name
    page
    screenshot
  ])

  validates :email_address, presence: true, email_address: true
  validates :issue, presence: true, length: { maximum: 1200 }
  validates :name, presence: true
  validates :is_for_whole_site, inclusion: { in: %w[yes no] }
  validates :page, presence: true, unless: :for_whole_site?

  def page
    for_whole_site? ? "Teaching Vacancies" : @page
  end

  def for_whole_site?
    is_for_whole_site == "yes"
  end
end
