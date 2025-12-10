class DropBodyFromActionTextRichTexts < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :action_text_rich_texts, :body, :text }
  end
end
