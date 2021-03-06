class <%= migration_class_name %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :<%= table_name %> do |t|
<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
      t.timestamps
    end
<% attributes.select(&:token?).each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>, unique: true
<% end -%>
<% attributes_with_index.each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
<% end -%>

    reversible do |change|
      change.up do
        unless BlockKind.find_by_name('<%= class_name %>')
          BlockKind.create name: '<%= class_name %>',
                           record_type: '<%= block_record_type %>',
                           category: '<%= block_category %>'
        end
      end

      change.down do
        BlockKind.where(name: '<%= class_name %>').destroy_all
      end
    end
  end
end
