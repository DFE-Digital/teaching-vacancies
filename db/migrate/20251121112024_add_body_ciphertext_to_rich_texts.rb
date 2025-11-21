class AddBodyCiphertextToRichTexts < ActiveRecord::Migration[8.0]
  def change
    add_column :action_text_rich_texts, :body_ciphertext, :text
  end
end
