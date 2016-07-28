json.extract! @collection, *[:id] + @collection.class.fields.select {|f| ![:has_model].include? f }
json.form @collection.class.properties.each do |property|
  json.attribute property.last
  json.label property.last[:term]
  json.type property.last[:type] || 'url'
  json.accept nil
  json.autocomplete nil
  json.autofocus false
  json.capture false
  json.checked nil
  json.disabled nil
  json.height nil
  json.inputmode nil
  json.max nil
  json.maxlength nil
  json.min nil
  json.minlength nil
  json.multiple false
  json.name property.last[:term]
  json.pattern nil
  json.placeholder nil
  json.readonly nil
  json.required nil
  json.selectionDirection nil
  json.size nil
  json.spellcheck nil
  json.src nil
  json.step nil
  json.tabindex nil
  json.value nil
  json.webkitdirectory nil
  json.width nil
end
