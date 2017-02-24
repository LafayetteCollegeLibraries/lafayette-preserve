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

  delegate :vocabulary_id, :leaf, :to => :term_uri, :prefix => true

  def include?(term)
    segments = path.split('/')
    term_segments = term.path.split('/')
    term_segments.first == segments.first
  end

  def children
    vocab_with_children
  end

  def absolute_path
    uri_segments = rdf_subject.to_s.split("/ns/")
    Rails.configuration.absolute_url + ['/vocabularies', uri_segments.last].join('/') + '.json'
  end

  def relative_path
    # Get the URI segment used for the vocabulary
    uri_segments = rdf_subject.to_s.split("http://#{ENV['VOCAB_DOMAIN'] || 'authority.localhost.localdomain'}/ns/")
    '/' + ['vocabularies', uri_segments.last].join('/') + '.json'
  end

  def persist!
    destroy
    repository.insert(statements)
  end

  def self.controls_for(property) # Should be something comparable to range/domain in RDF
    # Query for vocabularies which control a given property
    sparql_client ||= SPARQL::Client.new(ENV['TRIPLESTORE_URL'])
    query_graph = ControlledQuery.new(sparql_client, property.predicate).run

    query_graph.subjects.map do |subject|
      Vocabulary.find(subject)
    end
  end

  def self.find(uri)
    # Not certain why, but this invokes RestClient#send_delete_request when Vocabulary or Term is instantiated?
    query_graph = SingleQuery.new(sparql_client, RDF::URI.new(uri)).run

    results = GraphToTerms.new(repository, query_graph).terms(klass: self)
    raise ActiveTriples::NotFound if results.length == 0
    results.sort_by{|i| i.rdf_subject.to_s.downcase}.first
  end

  def self.all(*args)
    results = super(*args)
    results.reject { |term| not term.is_a? Vocabulary }
  end

  private
  def vocab_with_children
    injector = TermInjector.new
    vocab = TermWithChildren.new(self, injector.child_node_finder)
    vocab.children
  end
end
