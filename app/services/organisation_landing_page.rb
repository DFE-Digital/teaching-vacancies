class OrganisationLandingPage < LandingPage
  attr_reader :name

  def self.exists?(organisation_slug)
    Organisation.friendly.exists? organisation_slug
  end

  def self.[](organisation_slug)
    raise "No such organisation landing page: '#{organisation_slug}'" unless exists?(organisation_slug)

    organisation = Organisation.friendly.find(organisation_slug)

    new(organisation)
  end

  def initialize(organisation)
    @name = organisation.name
    @criteria = { organisation_slug: organisation.slug }
  end

  private

  def cache_key
    [:organisation_landing_page_count, name]
  end

  def translation_args
    super.merge(
      scope: [:landing_pages, "_organisation"],
      organisation: name,
    )
  end
end
