# -*- coding: utf-8 -*-
module LafayetteConcerns::EastAsiaWorks
  module Metadata
    extend ActiveSupport::Concern

    included do
      property :coverage_location, predicate: Vocabularies::EastAsia.coverageLocation
      property :coverage_location_country, predicate: Vocabularies::EastAsia.coverageLocationCountry
      property :creator_company, predicate: Vocabularies::EastAsia.creatorCompany
      property :creator_digital, predicate: Vocabularies::EastAsia.creatorDigital
      property :creator_maker, predicate: Vocabularies::EastAsia.creatorMaker
      property :date_artifact_upper, predicate: Vocabularies::EastAsia.dateArtifactUpper do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
      property :date_artifact_lower, predicate: Vocabularies::EastAsia.dateArtifactLower do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
      property :date_image_upper, predicate: Vocabularies::EastAsia.dateImageUpper do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
      property :date_image_lower, predicate: Vocabularies::EastAsia.dateImageLower do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
      property :date_original, predicate: Vocabularies::EastAsia.dateOriginal do |index|
        index.type :date
        index.as :stored_sortable, :facetable
      end
      property :description_citation, predicate: Vocabularies::EastAsia.descriptionCitation
      property :description_critical, predicate: Vocabularies::EastAsia.descriptionCritical
      property :description_ethnicity, predicate: Vocabularies::EastAsia.descriptionEthnicity
      property :description_indicia, predicate: Vocabularies::EastAsia.descriptionIndicia
      property :description_inscription_english, predicate: Vocabularies::EastAsia.descriptionInscriptionEnglish
      property :description_inscription_japanese, predicate: Vocabularies::EastAsia.descriptionInscriptionJapanese
      property :description_text_english, predicate: Vocabularies::EastAsia.descriptionTextEnglish
      property :description_text_japanese, predicate: Vocabularies::EastAsia.descriptionTextJapanese
      property :format_digital, predicate: Vocabularies::EastAsia.formatDigital
      property :format_extent, predicate: Vocabularies::EastAsia.formatExtent
      property :format_medium, predicate: Vocabularies::EastAsia.formatMedium
      property :identifier_url_download, predicate: Vocabularies::EastAsia.identifierUrlDownload
      property :publisher_digital, predicate: Vocabularies::EastAsia.publisherDigital
      property :relation_ispartof, predicate: Vocabularies::EastAsia.relationIspartof
      property :relation_seealso, predicate: Vocabularies::EastAsia.relationSeealso
      property :rights_digital, predicate: Vocabularies::EastAsia.rightsDigital
      property :subject_ocm, predicate: Vocabularies::EastAsia.subjectOcm do |index|
        index.as :stored_sortable, :facetable
      end
      property :title_chinese, predicate: Vocabularies::EastAsia.titleChinese
      property :title_english, predicate: Vocabularies::EastAsia.titleEnglish
      property :title_japanese, predicate: Vocabularies::EastAsia.titleJapanese
      property :title_korean, predicate: Vocabularies::EastAsia.titleKorean
    end
  end
end
