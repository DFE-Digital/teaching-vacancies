module Publishers::DfeSignIn
  module Parsing
    def la_code(user)
      # The organisation in the user from the DSI response contains an establishment number, which
      # matches the LA code if the organisation is an LA.
      # Category '002' denotes an LA.
      # To be consistent with trusts and schools, we only send the LA code to BigQuery if the organisation
      # is of the right type (i.e. it's an LA).

      # There is a different schema for the approvers and users API responses:
      if user.dig("organisation", "Category") == "002"
        user.dig("organisation", "EstablishmentNumber")
      elsif user.dig("organisation", "category", "id") == "002"
        user.dig("organisation", "establishmentNumber")
      end
    end
  end
end
