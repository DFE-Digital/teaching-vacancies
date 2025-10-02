# frozen_string_literal: true

namespace :subscriptions do
  desc "Normalize phases in search_criteria for all subscriptions"
  # :nocov:
  task normalize_phases: :environment do
    Subscription.normalize_phases!
    puts "Normalized phases for subscriptions."
  end
  # :nocov:
end
