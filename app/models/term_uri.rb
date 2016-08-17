##
# Value object representing a URI for Terms.
#
# Please see https://github.com/OregonDigital/ControlledVocabularyManager/blob/master/app/models/term_uri.rb
class TermUri
  attr_reader :uri
  def initialize(uri)
    @uri = uri
  end
end
