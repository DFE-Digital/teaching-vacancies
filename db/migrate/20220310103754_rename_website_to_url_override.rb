class RenameWebsiteToUrlOverride < ActiveRecord::Migration[6.1]
  def change
    rename_column :organisations, :website, :url_override
  end
end
