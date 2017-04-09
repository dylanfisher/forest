json.total_count @page_groups.total_count
json.per_page @page_groups.default_per_page

json.data @page_groups do |item|
  json.id item.id
  json.text item.title
end
