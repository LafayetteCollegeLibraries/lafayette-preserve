# -*- coding: utf-8 -*-
module Vocabularies
  module MetaDB
    class Common < RDF::Vocabulary("http://authority.lafayette.edu/ns/metadb/")
      term :coverageLocation
      term :coverageLocationCountry
      term :dateOriginal
      term :dateSearch
      term :descriptionCritical
      term :descriptionLocation
      term :descriptionNote
      term :formatAnalog
      term :formatDigital
      term :formatExtent
      term :formatMedium
      term :identifierUrlDownload
      term :publisherDigital
      term :relationIsPartOf
      term :rightsDigital
      term :subjectOcm
    end
  end
end
