class ActiveTriples::NotInNamespace < StandardError
  attr_reader :term

  def initialize(term, msg = nil)
    super(msg)
    @term = term
  end
end
