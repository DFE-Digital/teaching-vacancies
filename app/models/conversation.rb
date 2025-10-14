class Conversation < ApplicationRecord
  after_create :update_searchable_content

  belongs_to :job_application
  has_many :messages, dependent: :destroy
  has_many :jobseeker_messages, dependent: :destroy
  has_many :publisher_messages, dependent: :destroy

  scope :inbox, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :for_organisations, lambda { |org_ids|
    joins(job_application: :vacancy)
      .merge(Vacancy.in_organisation_ids(org_ids))
  }
  scope :with_unread_jobseeker_messages, lambda {
    joins(:messages)
      .where(messages: { type: "JobseekerMessage", read: false })
      .distinct
  }

  scope :ordered_by_unread_and_latest_message, lambda {
    order(has_unread_jobseeker_messages: :desc, last_message_at: :desc)
  }

  include PgSearch::Model

  pg_search_scope :search_by_keyword,
                  against: [:searchable_content],
                  using: {
                    tsearch: {
                      prefix: true,
                      any_word: true,
                      dictionary: "english",
                    },
                  }

  scope :search_ids_by_keyword, lambda { |q|
    search_by_keyword(q)
      .unscope(:order) # remove ORDER BY pg_search_rank; otherwise it would reference a column we're about to drop
      .reselect(:id)   # replace SELECT list so pg_search_rank/ts_rank aren’t selected
      .distinct        # can now use distinct to de-dupe because we don't have computed columns in select or order to conflict
  }

  def has_unread_messages_for_publishers?
    messages.any? { |msg| msg.is_a?(JobseekerMessage) && msg.unread? }
  end

  def update_searchable_content
    update!(searchable_content: generate_searchable_content)
  end

  def generate_searchable_content
    message_content = messages.filter_map do |message|
      message.content.to_plain_text
    end

    Search::Postgres::TsvectorGenerator.new(
      a: [job_application.vacancy.job_title],       # Job title (highest weight)
      b: [job_application.name],                    # Candidate name (mid weight)
      d: message_content,                           # Message content (lower weight)
    ).tsvector
  end
end
