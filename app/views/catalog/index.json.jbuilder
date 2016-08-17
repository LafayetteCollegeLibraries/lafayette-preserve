
# json.docs @presenter.documents
# json.facets @presenter.search_facets_as_json
# json.pages @presenter.pagination_info

json.resources @presenter.documents.each do |doc|
#    json.doc doc
    json.id doc.id
    json.title doc.title
    json.creator doc.creator

    # GenericWork.fields.select {|f| ![:has_model].include? f }.each do |field|
    CatalogController.concern_fields.each do |field|
      json.set! field, doc.fetch(field.to_s, nil)
    end

    json.contributor doc.contributor
    json.description doc.description
    json.keyword doc.keyword
    json.rights doc.rights
    json.publisher doc.publisher
    json.date_created doc.date_created
    json.subject doc.subject
    json.language doc.language
    json.identifier doc.identifier
    json.based_near doc.based_near
    json.related_url doc.related_url
    json.bibliographic_citation doc['bibliographic_citation']
    json.source doc.source
    json.thumbnail_path doc['thumbnail_path_ss']
    json.uses_vocabulary []
    json.form []
  end
