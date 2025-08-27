# frozen_string_literal: true

class PublisherMessage < Message
  belongs_to :sender, class_name: "Publisher"
end
