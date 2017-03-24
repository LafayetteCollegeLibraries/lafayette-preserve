class ControlledQuery < Struct.new(:sparql_client, :uri)
  def run
    graph
  end

  private

  def graph
    g = RDF::Graph.new
    solutions.each do |solution|
      statement = solution
      g.insert(RDF::Statement.new(subject: solution.s, predicate: RDF::URI.new("http://purl.org/dc/terms/isReferencedBy") , object: uri))
    end
    g
  end

  def solutions
    query.each_solution.to_a
  end

  def query
    sparql_client.query(<<-EOSPARQL
 SELECT ?s ?p ?o
 WHERE
   { ?s <http://purl.org/dc/terms/isReferencedBy> <#{uri.to_s}> }
EOSPARQL
)
  end

  def query_filter
    "CONTAINS(STR(?o), \"#{uri.to_s}\")"
  end
end
