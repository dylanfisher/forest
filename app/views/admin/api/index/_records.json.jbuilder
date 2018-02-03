json.items records do |record|
  json.id record.id
  json.to_label record.to_label
  json.select2_response record.to_select2_response
  json.select2_selection record.to_select2_selection
end
