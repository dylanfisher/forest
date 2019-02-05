class <%= migration_class_name %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :<%= table_name %> do |t|
<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
<% unless options.skip_sluggable? -%>
      t.string :slug
<% end -%>
<% unless options.skip_statusable? -%>
      t.integer :status, default: 1, null: false
<% end -%>
<% unless options.skip_blockable? -%>
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
<% unless options.skip_sluggable? -%>
    add_index :<%= table_name %>, :slug, unique: true
<% end -%>
<% unless options.skip_statusable? -%>
    add_index :<%= table_name %>, :status
<% end -%>
<% unless options.skip_blockable? -%>
    add_index :<%= table_name %>, :blockable_metadata, using: :gin
<% end -%>
  end
end
