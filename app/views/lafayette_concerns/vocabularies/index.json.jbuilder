json.vocabularies @vocabularies.each do |vocabulary|
  json.uri vocabulary.rdf_subject.to_s
  json.label vocabulary.label
  json.alt_label vocabulary.alt_label
  json.pref_label vocabulary.pref_label
  json.hidden_label vocabulary.hidden_label
  json.absolute_path vocabulary.absolute_path
  json.term_count vocabulary.children.length
end
