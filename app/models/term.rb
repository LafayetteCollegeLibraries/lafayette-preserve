##
# A Term within a Vocabulary
#
# Please see https://github.com/OregonDigital/ControlledVocabularyManager/blob/master/app/models/term.rb
class Term < ActiveTriples::Resource
  include ActiveTriplesAdapter
  include ActiveModel::Validations

  attr_accessor :commit_history

  configure :base_uri => "http://#{Rails.application.routes.default_url_options[:vocab_domain]}/ns/"
  configure :repository => :default
  configure :type => RDF::URI("http://www.w3.org/2004/02/skos/core#Concept")

  property :label, :predicate => RDF::RDFS.label
  property :alternate_name, :predicate => RDF::URI("http://schema.org/alternateName")
  property :date, :predicate => RDF::Vocab::DC.date
  property :comment, :predicate => RDF::RDFS.comment
  property :is_replaced_by, :predicate => RDF::Vocab::DC.isReplacedBy
  property :see_also, :predicate => RDF::RDFS.seeAlso
  property :is_defined_by, :predicate => RDF::RDFS.isDefinedBy
  property :same_as, :predicate => RDF::OWL.sameAs
  property :modified, :predicate => RDF::Vocab::DC.modified
  property :issued, :predicate => RDF::Vocab::DC.issued
  property :pref_label, :predicate => RDF::Vocab::SKOS.prefLabel
  property :alt_label, :predicate => RDF::Vocab::SKOS.altLabel
  property :hidden_label, :predicate => RDF::Vocab::SKOS.hiddenLabel

  delegate :vocabulary_id, :leaf, :to => :term_uri, :prefix => true

  validate :not_blank_node


  def term_uri
    TermUri.new(rdf_subject)
  end

  private
  def repository
    # rdf_statement = RDF::Statement.new(:subject => rdf_subject)
    # @repository ||= TriplestoreRepository.new(rdf_statement, Rails.configuration.triplestore_adapter['type'], Rails.configuration.triplestore_adapter['url'])
    # @repository ||= RDF::Repository.new(uri: Rails.configuration.triplestore_adapter[:url])
    @repository ||= RDF::Blazegraph::Repository.new(Rails.configuration.triplestore_adapter[:url])
  end

  def not_blank_node
    errors.add(:id, "can not be blank") if node?
  end
end
