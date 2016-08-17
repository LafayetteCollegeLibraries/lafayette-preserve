##
# A Controlled Vocabulary containing one or many Terms resolving to URI's
#
# Please see https://github.com/OregonDigital/ControlledVocabularyManager/blob/master/app/models/vocabulary.rb
class Vocabulary < Term
  configure :type => RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")
  property :title, :predicate => RDF::Vocab::DC.title
  property :publisher, :predicate => RDF::Vocab::DC.publisher
  property :sub_property_of, :predicate => RDF::RDFS.subPropertyOf
  property :range, :predicate => RDF::RDFS.range
  property :domain, :predicate => RDF::RDFS.domain
  property :is_referenced_by, :predicate => RDF::Vocab::DC.isReferencedBy # Reference the URI for predicates used to model attributes which are controlled

  def children
    vocab_with_children
  end

  def absolute_path
    # uri_segments = rdf_subject.to_s.split("http://#{Rails.application.routes.default_url_options[:vocab_domain]}/ns/")
    uri_segments = rdf_subject.to_s.split("/ns/")
    "//concerns.stage.lafayette.edu/" + ['vocabularies', uri_segments.last].join('/') + '.json'
  end

  def relative_path
    # Get the URI segment used for the vocabulary
    
    uri_segments = rdf_subject.to_s.split("http://#{Rails.application.routes.default_url_options[:vocab_domain]}/ns/")
    '/' + ['vocabularies', uri_segments.last].join('/') + '.json'
  end

  def persist!
    repository.insert(statements)
  end

  def self.controls_for(property) # Should be something comparable to range/domain in RDF
    # Query for vocabularies which control a given property

    sparql_client ||= SPARQL::Client.new(Rails.configuration.triplestore_adapter[:url])
    query_graph = ControlledQuery.new(sparql_client, property.predicate).run

    # repository = RDF::Blazegraph::Repository.new(Rails.configuration.triplestore_adapter[:url])
    # results = GraphToTerms.new(repository, query_graph).terms
    # results.sort_by{|i| i.rdf_subject.to_s.downcase}

    query_graph.subjects.map do |subject|
      Vocabulary.find(subject)
    end
  end

  private
  def vocab_with_children
    injector = TermInjector.new
    vocab = TermWithChildren.new(self, injector.child_node_finder)
    vocab.children
  end
end
