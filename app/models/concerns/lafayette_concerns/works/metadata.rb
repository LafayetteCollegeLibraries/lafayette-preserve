module LafayetteConcerns::Works
  module Metadata
    extend ActiveSupport::Concern

    included do
#      property :arkivo_checksum, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#arkivoChecksum'), multiple: false

#      property :, predicate: ::RDF::URI.new('http://authority.lafayette.edu/ocm#testValue'), multiple: false
      property :subject_ocm, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#subjectOcm')
      property :description_critical, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionCritical')
      property :description_indicia, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionIndicia')
      property :description_text, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionText')
      property :description_inscription, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionInscription')
      property :description_ethnicity, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionEthnicity')
      property :description_citation, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#descriptionCitation')
      property :coverage_location_country, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#coverageLocationCountry')
      property :coverage_location, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#coverageLocation')
      property :format_medium, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#formatMedium')
      property :creator_maker, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#creatorMaker')
      property :creator_company, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#creatorCompany')

      property :relation_seealso, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#relationSeealso')

      property :date_original, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateOriginal')
      property :date_artifact_upper, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateArtifactUpper')
      property :date_artifact_lower, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateArtifactLower')

      property :date_image_upper, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateImageUpper')
      property :date_image_lower, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateImageLower')
    end
  end
end
