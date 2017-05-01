# -*- coding: utf-8 -*-
module Vocabularies
  module MetaDB
  class MarquisDeLafayette < RDF::Vocabulary("http://authority.lafayette.edu/ns/metadb/")
    term :dateOriginal # Common
    term :descriptionCondition

    term :descriptionProvenance
    term :descriptionSeries
    term :formatDigital # Common
    term :formatExtent # Common
    term :formatMedium # Common
    term :identifierItemnumber
    term :identifierUrlDownload # Common
    term :publisherDigital # Common
    term :publisherOriginal
    term :relationIsPartOf
    term :rightsDigital # Common
    term :subjectLcsh
  end
  end
end
