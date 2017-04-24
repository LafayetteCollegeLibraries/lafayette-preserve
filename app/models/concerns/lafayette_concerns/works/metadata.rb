module LafayetteConcerns::Works
  module Metadata
    extend ActiveSupport::Concern

    included do

      # Custom metadata elements
      property :date_original, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/dateOriginal") do |index|
        index.as :stored_searchable
      end

      property :description_condition, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionCondition") do |index|
        index.type :text
        index.as :stored_searchable
      end
      
      property :description_note, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionNote") do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :description_provenance, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionProvenance") do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :description_series, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionSeries") do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :format_digital, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/formatDigital") do |index|
        index.as :stored_searchable, :facetable
      end

      property :format_extent, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/formatExtent") do |index|
        index.as :stored_searchable
      end

      property :format_medium, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/formatMedium") do |index|
        index.as :stored_searchable
      end
      
      property :identifier_itemnumber, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/identifierItemnumber") do |index|
        index.as :stored_searchable
      end
      
      property :publisher_digital, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/publisherDigital") do |index|
        index.as :stored_searchable, :facetable
      end
      
      property :publisher_original, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/publisherOriginal") do |index|
        index.as :stored_searchable, :facetable
      end
      
      # Facet for collections
      property :bib_collections, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/relationIsPartOf") do |index|
        index.as :stored_searchable, :facetable
      end

      property :rights_digital, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/rightsDigital") do |index|
        index.as :stored_searchable
      end

      # Same case as "subject.loc"; Request to deprecate and integrate with "subject_loc"
      property :subject_lcsh, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/subjectLcsh") do |index|
        index.as :stored_searchable, :facetable
      end

      property :identifier_url_download, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/identifierUrlDownload") do |index|
        index.as :stored_searchable
      end

      ####

      # Historical Photograph Collection

      # Takes URI's from http://id.loc.gov/authorities/subjects
      # Support for Linked Data Fragments?
      # Support for Questioning Authority?
      property :subject_loc, predicate: ::RDF::Vocab::DC11.subject do |index|
        index.as :stored_searchable, :facetable
      end

      # Takes URI's from a local resources (an LDF server?)
      property :creator_photographer, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/creatorPhotographer") do |index|
        index.as :stored_searchable, :facetable
      end


      property :format_size, predicate: ::RDF::Vocab::DC11.format do |index|
        index.as :stored_searchable
      end

      # Not explicitly clear why this is a separate field from the previous "date"
      # Raise for discussion with archivist and librarians
      property :date_approximate, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      # Uncertain as to whether or not this catches a range with "date"; Uncertain of the relationship with "data.approximate"
      # Ranges are captured as separate resource instances
      # Dublin Core supports this using http://purl.org/dc/terms/PeriodOfTime [dcterms:PeriodOfTime]
      property :date_range, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end

      # McKelvy House Collection
      # Takes URI's from a local resources (an LDF server? a data dump?)
      property :creator_maker, predicate: ::RDF::Vocab::DC11.creator do |index|
        index.as :stored_searchable, :facetable
      end

      # What distinguishes this from "format.extent"?
      property :description_size, predicate: RDF::URI("http://authority.lafayette.edu/ns/metadb/descriptionSize") do |index|        
        index.type :text
        index.as :stored_searchable
      end

    end
  end
end
