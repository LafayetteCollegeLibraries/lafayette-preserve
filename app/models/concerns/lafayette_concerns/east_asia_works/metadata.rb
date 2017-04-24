module LafayetteConcerns::EastAsiaWorks
  module Metadata
    extend ActiveSupport::Concern

    included do
      property :subject_ocm, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#subjectOcm') do |index|
        index.as :stored_sortable, :facetable
      end

      property :description_critical, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionCritical')
      property :description_indicia, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionIndicia')
      property :description_text, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionText')
      property :description_inscription, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionInscription')
      property :description_ethnicity, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionEthnicity')
      property :description_citation, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionCitation')
      property :coverage_location_country, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#coverageLocationCountry')
      property :coverage_location, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#coverageLocation')

      property :creator_maker, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#creatorMaker')
      property :creator_company, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#creatorCompany')
      property :creator_digital, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#creatorDigital')

      property :title_japanese, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#titleJapanese')
      property :title_chinese, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#titleChinese')
      property :title_korean, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#titleKorean')

      property :relation_seealso, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#relationSeealso')

      property :date_artifact_upper, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateArtifactUpper') do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
      property :date_artifact_lower, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateArtifactLower') do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end

      property :date_image_upper, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateImageUpper') do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
      property :date_image_lower, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateImageLower') do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
    end
  end
end
