class SetOrganisationSlugsJob < ApplicationJob
  queue_as :default

  def perform
    Organisation.find_each(batch_size: 50) do |organisation|
      organisation.save if organisation.slug.nil?
    end
  end
end
