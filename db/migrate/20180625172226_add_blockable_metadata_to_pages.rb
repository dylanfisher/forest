class AddBlockableMetadataToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :blockable_metadata, :jsonb, default: {}
    add_index  :pages, :blockable_metadata, using: :gin
  end
end
