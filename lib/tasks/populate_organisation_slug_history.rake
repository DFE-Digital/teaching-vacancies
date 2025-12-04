desc "Populate friendly_id_slugs table with current organisation slugs for history tracking"
task populate_organisation_slug_history: :environment do
  Organisation.not_out_of_scope.find_each do |org|
    FriendlyId::Slug.find_or_create_by!(
      slug: org.slug,
      sluggable: org,
    )
  end
end
