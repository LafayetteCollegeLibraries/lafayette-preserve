require_relative 'vocabularies/metadb'
module Vocabularies
  
  def self.property_name(predicate)
    predicate.to_base.split('/').last.chomp('>').underscore
  end
end
