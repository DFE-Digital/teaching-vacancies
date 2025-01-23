class AddJobApplicationToProfessionalBodyMemberships < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference_concurrently :professional_body_memberships, :job_application, type: :uuid, foreign_key: true
  end
end
