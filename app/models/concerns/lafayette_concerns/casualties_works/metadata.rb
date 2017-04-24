module LafayetteConcerns::CasualtiesWorks
  module Metadata
    extend ActiveSupport::Concern

    included do
      property :title_name, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/titleName") do |index|
        index.as :stored_searchable, :facetable
      end

      property :description_class, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionClass") do |index|
        index.type :text
        index.as :stored_searchable
      end
      
      property :date_birth_display, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      # This should be reconciled with an ontology for place names
      # e. g. GeoNames or the Getty Thesaurus for Names
      property :coverage_place_birth, predicate: ::RDF::Vocab::DC11.coverage do |index|
        index.as :stored_searchable, :facetable
      end

      property :description_military_branch, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionMilitaryBranch") do |index|
        index.type :text
        index.as :stored_searchable
      end

      # A controlled vocabulary needs to be identified for this attribute
      property :description_military_rank, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionMilitaryRank") do |index|
        index.type :text
        index.as :stored_searchable
      end

      # Another controlled vocabulary needs to be identified for this attribute
      property :description_military_unit, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionMilitaryUnit") do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :date_death_display, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      # This should be reconciled with an ontology for place names
      # e. g. GeoNames or the Getty Thesaurus for Names
      property :coverage_place_death, predicate: ::RDF::Vocab::DC11.coverage do |index|
        index.as :stored_searchable, :facetable
      end

      property :description_cause_death, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionCauseDeath") do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :description_honors, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionHonors") do |index|
        index.type :text
        index.as :stored_searchable
      end
    end
  end
end
