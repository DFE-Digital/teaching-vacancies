class EnableFuzzymatchstrExtension < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'fuzzystrmatch'
  end
end
