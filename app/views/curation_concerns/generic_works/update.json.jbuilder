json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.select {|f| ![:has_model].include? f }
json.representative_id @curation_concern.representative.id
json.thumbnail_path @curation_concern.thumbnail_path
json.download_path @curation_concern.download_path
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
  json.authorities Vocabulary.controls_for(property.last) do |authority|
    json.uri authority.rdf_subject.to_s
    json.absolute_path authority.absolute_path
  end
  json.label property.last[:term]
  json.type property.last[:type] || 'url'
  json.name property.last[:term]
end
