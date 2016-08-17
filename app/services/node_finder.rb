class NodeFinder
  attr_reader :sparql_client
  def initialize(sparql_client)
    @sparql_client = sparql_client
  end

  def find_triples(vocabulary)
    query_graph = SingleQuery.new(sparql_client, vocabulary.rdf_subject).run
    results = GraphToTerms.new(repository, query_graph).terms
    results.sort_by{|i| i.rdf_subject.to_s.downcase}
  end

end
