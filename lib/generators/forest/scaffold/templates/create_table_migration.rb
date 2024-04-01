class <%= migration_class_name %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :<%= table_name %> do |t|
<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
<% unless options.skip_sluggable? || options.skip_all? -%>
      t.string :slug
<% end -%>
<% unless options.skip_statusable? || options.skip_all? -%>
      t.integer :status, default: 1, null: false
<% end -%>
<% unless options.skip_blockable? || options.skip_all? -%>
      t.jsonb :blockable_metadata, default: {}
<% end -%>

      t.timestamps
    end
<% attributes.select(&:token?).each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>, unique: true
<% end -%>
<% attributes_with_index.each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
<% end -%>
<% unless options.skip_sluggable? || options.skip_all? -%>
    add_index :<%= table_name %>, :slug, unique: true
<% end -%>
<% unless options.skip_statusable? || options.skip_all? -%>
    add_index :<%= table_name %>, :status
<% end -%>
<% unless options.skip_blockable? || options.skip_all? -%>
    add_index :<%= table_name %>, :blockable_metadata, using: :gin
<% end -%>
  end
end
