module LafayetteConcerns::Works
  module Metadata
    extend ActiveSupport::Concern

    included do

      # Common MetaDB predicates
      Vocabularies::MetaDB::Common.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # Alsace Predicates
      Vocabularies::MetaDB::Alsace.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # BeyondSteel Predicates
      Vocabularies::MetaDB::BeyondSteel.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # Biology Predicates
      Vocabularies::MetaDB::Biology.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # East Asia Image Collection
      Vocabularies::MetaDB::EastAsia.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # Geology Predicates
      Vocabularies::MetaDB::GeologySlides.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # Historical Predicates
      Vocabularies::MetaDB::Historical.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # MarquisDeLafayette Predicates
      Vocabularies::MetaDB::MarquisDeLafayette.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end

      # McKelvyHouse
      Vocabularies::MetaDB::McKelvyHouse.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym
        
        case property_name
        when *Vocabularies::MetaDB::DATES
          property property_name, predicate: metadb_predicate do |index|
            index.type :date
            index.as :stored_sortable, :facetable
          end
        when *Vocabularies::MetaDB::FACETS
          property property_name, predicate: metadb_predicate do |index|
            index.as :stored_searchable, :facetable
          end
        else
          property property_name, predicate: metadb_predicate do |index|
            index.type :text
            index.as :stored_searchable
          end
        end
      end    

      # Silk Road
      Vocabularies::MetaDB::SilkRoad.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym

        # No alternative indexing strategy for any fields
        property property_name, predicate: metadb_predicate do |index|
          index.type :text
          index.as :stored_searchable
        end
      end

      # War Casualties
      Vocabularies::MetaDB::WarCasualties.properties.each do |metadb_predicate|
        property_name = Vocabularies.property_name(metadb_predicate).to_sym

        # No alternative indexing strategy for any fields
        property property_name, predicate: metadb_predicate do |index|
          index.type :text
          index.as :stored_searchable
        end
      end
    end
  end
end
