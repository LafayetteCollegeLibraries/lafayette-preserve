json.response do
  json.docs @presenter.documents.each do |doc|
    json.id doc.id
    json.title doc.title
    json.creator doc.creator

    CatalogController.concern_fields.each do |field|
      json.set! field, doc.fetch(field.to_s, nil)
    end

    json.type doc.human_readable_type
    json.contributor doc.contributor
    json.description doc.description
    json.keyword doc.keyword
    json.rights doc.rights
    json.publisher doc.publisher
    json.date_created doc.date_created
    json.date_original doc.date_original
    json.subject doc.subject
    json.language doc.language
    json.identifier doc.identifier
    json.based_near doc.based_near
    json.related_url doc.related_url
    json.bibliographic_citation doc['bibliographic_citation']
    json.source doc.source
    json.thumbnail_path doc['thumbnail_path_ss']
    json.date_artifact_upper doc['date_artifact_upper_dtsi']
    json.date_artifact_lower doc['date_artifact_lower_dtsi']
    json.uses_vocabulary []
    json.form []
    json.score doc['score']
  end
  json.facets @presenter.search_facets_as_json
  json.pages @presenter.pagination_info
  json.facet_counts @response['facet_counts']
end
