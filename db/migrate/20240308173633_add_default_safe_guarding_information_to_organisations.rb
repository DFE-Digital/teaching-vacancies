class AddDefaultSafeGuardingInformationToOrganisations < ActiveRecord::Migration[7.1]
  def change
    default = "Our organisation is committed to safeguarding and promoting the welfare of children, young people and vulnerable adults. " \
              "We expect all staff, volunteers and trustees to share this commitment.\n\n" \
              "Our recruitment process follows the keeping children safe in education guidance.\n\n" \
              "Offers of employment may be subject to the following checks (where relevant):\n" \
              "childcare disqualification\n" \
              "Disclosure and Barring Service (DBS)\n" \
              "medical\n" \
              "online and social media\n" \
              "prohibition from teaching\n" \
              "right to work\n" \
              "satisfactory references\n" \
              "suitability to work with children\n\n" \
              "You must tell us about any unspent conviction, cautions, reprimands or warnings under the Rehabilitation of Offenders Act 1974 (Exceptions) Order 1975."
    change_column_default :organisations, :safeguarding_information, from: nil, to: default
  end
end
