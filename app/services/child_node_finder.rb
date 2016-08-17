class ChildNodeFinder
  attr_reader :sparql_client
  def initialize(sparql_client)
    @sparql_client = sparql_client
  end

  def find_children(vocabulary)
    query_graph = ChildQuery.new(sparql_client, vocabulary.rdf_subject).run

    results = GraphToTerms.new(nil, query_graph).terms
    results.sort_by{|i| i.rdf_subject.to_s.downcase}
  end

end
