json.uri @vocabulary.rdf_subject.to_s
json.label @vocabulary.label
json.alt_label @vocabulary.alt_label
json.pref_label @vocabulary.pref_label
json.hidden_label @vocabulary.hidden_label
json.absolute_path @vocabulary.absolute_path
json.terms @vocabulary.children do |term|
  json.uri term.rdf_subject.to_s
  json.label term.label
  json.alt_label term.alt_label
  json.pref_label term.pref_label
  json.hidden_label term.hidden_label
end
