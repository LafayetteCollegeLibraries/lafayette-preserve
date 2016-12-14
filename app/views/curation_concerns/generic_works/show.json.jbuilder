json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.select {|f| ![:has_model].include? f }
json.representative_id @curation_concern.representative.id
json.thumbnail_path @curation_concern.thumbnail_path
json.iiif_images @curation_concern.iiif_images
json.uses_vocabulary @vocabularies do |vocabulary|
  json.uri vocabulary.rdf_subject.to_s
  json.label vocabulary.label
  json.alt_label vocabulary.alt_label
  json.pref_label vocabulary.pref_label
  json.hidden_label vocabulary.hidden_label
  json.absolute_path vocabulary.absolute_path
  json.terms vocabulary.children do |term|
    json.uri term.rdf_subject.to_s
    json.label term.label
    json.alt_label term.alt_label
    json.pref_label term.pref_label
    json.hidden_label term.hidden_label
  end
end
json.form @curation_concern.class.properties.each do |property|
#  json.attribute property.last
#  json.vocabularies Vocabulary.controls_for(property.predicate)
  json.authorities Vocabulary.controls_for(property.last) do |authority|
    json.uri authority.rdf_subject.to_s
    json.absolute_path authority.absolute_path
  end
  json.label property.last[:term]
  json.type property.last[:type] || 'url'
#  json.accept nil
#  json.autocomplete nil
#  json.autofocus false
#  json.capture false
#  json.checked nil
#  json.disabled nil
#  json.height nil
#  json.inputmode nil
#  json.max nil
#  json.maxlength nil
#  json.min nil
#  json.minlength nil
#  json.multiple false
  json.name property.last[:term]
#  json.pattern nil
#  json.placeholder nil
#  json.readonly nil
#  json.required nil
#  json.selectionDirection nil
#  json.size nil
#  json.spellcheck nil
#  json.src nil
#  json.step nil
#  json.tabindex nil
#  json.value nil
#  json.webkitdirectory nil
#  json.width nil
end
