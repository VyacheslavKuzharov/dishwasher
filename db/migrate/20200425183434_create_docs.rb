class CreateDocs < ActiveRecord::Migration[6.0]
  def change
    create_table :docs do |t|
      t.jsonb :doc_data, default: {}

      t.timestamps
    end
  end
end
