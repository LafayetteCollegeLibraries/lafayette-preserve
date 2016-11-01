module LafayetteConcerns::Works
  module Metadata
    extend ActiveSupport::Concern

    included do
      # Historical Photograph Collection

      # Takes URI's from http://id.loc.gov/authorities/subjects
      # Support for Linked Data Fragments?
      # Support for Questioning Authority?
      property :subject_loc, predicate: ::RDF::Vocab::DC11.subject do |index|
        index.as :stored_searchable, :facetable
      end

      # Takes URI's from a local resources (an LDF server? a data dump? authority.lafayette.edu?)
      property :creator_photographer, predicate: ::RDF::Vocab::DC11.creator do |index|
        index.as :stored_searchable, :facetable
      end

      property :format_medium, predicate: ::RDF::Vocab::DC11.format do |index|
        index.as :stored_searchable
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
      # Takes URI's from a local resources (an LDF server? a data dump? authority.lafayette.edu?)
      property :creator_maker, predicate: ::RDF::Vocab::DC11.creator do |index|
        index.as :stored_searchable, :facetable
      end

      # Request to deprecate and integrate with "date.original"
      property :date_original_display, predicate: ::RDF::Vocab::DC.created do |index|
        index.as :stored_searchable
      end
      
      # What distinguishes this from "format.extent"?
      property :description_size, predicate: ::RDF::Vocab::DC11.description do |index|
        index.type :text
        index.as :stored_searchable
      end

      # Marquis de Lafayette Prints Collection
      property :description_note, predicate: ::RDF::Vocab::DC11.description do |index|
        index.type :text
        index.as :stored_searchable
      end

      # Same case as "subject.loc"; Request to deprecate and integrate with "subject_loc"
      property :subject_lcsh, predicate: ::RDF::Vocab::DC11.subject do |index|
        index.as :stored_searchable, :facetable
      end
      
      property :publisher_original, predicate: ::RDF::Vocab::DC11.publisher do |index|
        index.as :stored_searchable, :facetable
      end


      property :format_extent, predicate: ::RDF::Vocab::DC11.format do |index|
        index.as :stored_searchable
      end

      property :description_condition, predicate: ::RDF::Vocab::DC11.description do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :description_provenance, predicate: ::RDF::Vocab::DC11.description do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :description_series, predicate: ::RDF::Vocab::DC11.description do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :identifier_itemnumber, predicate: ::RDF::Vocab::DC.identifier do |index|
        index.as :stored_searchable
      end

      property :publisher_digital, predicate: ::RDF::Vocab::DC11.publisher do |index|
        index.as :stored_searchable, :facetable
      end

      property :format_digital, predicate: ::RDF::Vocab::DC11.format do |index|
        index.as :stored_searchable, :facetable
      end

      property :rights_digital, predicate: ::RDF::Vocab::DC.rights do |index|
        index.as :stored_searchable
      end

      
    end
  end
end
