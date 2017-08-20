json.total_count @pages.total_count
json.per_page @pages.default_per_page

json.data @pages do |item|
  json.id item.id
  json.text item.title
end
