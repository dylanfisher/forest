json.total_count @media_items.total_count
json.per_page @media_items.default_per_page

json.data @media_items do |item|
  json.id item.id
  json.text item.title
end
