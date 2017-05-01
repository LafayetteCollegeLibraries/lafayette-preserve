# -*- coding: utf-8 -*-
module Vocabularies
  module MetaDB
    class Base < RDF::Vocabulary("http://authority.lafayette.edu/ns/metadb/")
      term :dateOriginal
      term :descriptionCritical
      term :descriptionNote
      term :formatAnalog
      term :formatDigital
      term :formatExtent # Common
      term :formatMedium # Common
      term :identifierUrlDownload # Common
      term :publisherDigital # Common
      term :relationIsPartOf
      term :relationIspartof # Integrate
      term :rightsDigital # Common
    end
  end
end
