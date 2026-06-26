module Publishers::DfeSignIn
  # Maintains the relevant mappings between DfE Sign In organisation category/type IDs and the corresponding "concept" in our system.
  # They are used to determine which organisations are supported for sign in, and which are not.
  # Source of truth for these id mappings:
  # https://github.com/DFE-Digital/login.dfe.public-api#how-do-ids-map-to-categories-and-types
  module OrgIdMappings
    # Organisation Category IDs
    # DO NOT confuse these with the GIAS Download Organisation "Group Type (code)". They are not meant to match.
    CATEGORIES = {
      single_establishment: "001",
      local_authority: "002",
      multi_academy_trust: "010",
      single_academy_trust: "013",
    }.freeze

    # These are the organisation types that we do not support signing in as.
    # This list should be kept in sync with the list in Organisation::OUT_OF_SCOPE_DETAILED_SCHOOL_TYPES.
    # The GIAS and DfE Sign In data use slightly different names for the same organisation types, but the idea is that if a
    # type of organisation is out of scope for GIAS imports, it should also be out of scope for DfE Sign In.
    #
    # Note about allowing new types in the future:
    # If we want to allow one of these types in the future, it won't be enough to just remove it from this list.
    # We will also need to update the DfE Sign-in Policies rules/conditions to allow these types of organisations to grant
    # TV service access to their users.
    # We cannot manage these policies ourselves. It will need to be raised as a ServiceDesk ticket with DfE Sign-in team
    # to make any changes to the policies.
    OUT_OF_SCOPE_TYPES = [
      {
        "10" => "Other independent special school",
        "11" => "Other independent school",
        "18" => "Further education",
        "25" => "Offshore schools",
        "26" => "Service children’s education",
        "27" => "Miscellaneous",
        "29" => "Higher education institutions",
        "30" => "Welsh establishment",
        "32" => "Special post 16 institution",
        "37" => "British schools overseas",
        "49" => "Online provider",
        "56" => "Institution funded by other government department",
      },
    ].freeze

    def self.out_of_scope_type?(type_id)
      OUT_OF_SCOPE_TYPES.any? { |types| types.key?(type_id) }
    end
  end
end
