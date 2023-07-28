class AddFriendlyIdSlugsSluggableIdSluggableTypeIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :friendly_id_slugs, ["sluggable_id", "sluggable_type"], name: :index_friendly_id_slugs_sluggable_id_sluggable_type, algorithm: :concurrently
  end
end
