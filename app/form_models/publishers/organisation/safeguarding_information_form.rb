class Publishers::Organisation::SafeguardingInformationForm < BaseForm
  validate :safeguarding_information_presence
  validate :safeguarding_information_does_not_exceed_maximum_words

  attr_accessor :safeguarding_information

  private

  def safeguarding_information_presence
    return if remove_html_tags(safeguarding_information).present?

    errors.add(:safeguarding_information, :blank)
  end

  def safeguarding_information_does_not_exceed_maximum_words
    errors.add(:safeguarding_information, :length) if number_of_words_exceeds_permitted_length?(100, safeguarding_information)
  end

  def remove_html_tags(field)
    regex = /<("[^"]*"|'[^']*'|[^'">])*>/

    field&.gsub(regex, "")
  end

  def number_of_words_exceeds_permitted_length?(number, attribute)
    remove_html_tags(attribute)&.split&.length&.>(number)
  end
end
