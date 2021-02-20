class AddColumnToDocs < ActiveRecord::Migration[6.0]
  def change
    add_column :docs, :characters_data, :jsonb, default: {}
  end
end
