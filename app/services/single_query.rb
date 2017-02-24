class SingleQuery < Struct.new(:sparql_client, :uri)
  def run
    graph
  end

  private

  def graph
    g = RDF::Graph.new
    solutions.each do |solution|
      statement = solution
      g.insert(RDF::Statement.new(subject: uri, predicate: solution.p, object: solution.o))
    end
    g
  end

  def solutions
    query.each_solution.to_a
  end

  def query
    sparql_client.select.where([uri, :p, :o])
#    sparql_client.select.where([:s, :p, :o]).limit(10)
#    sparql_client.query("SELECT * WHERE { ?s ?p ?o . FILTER(STRENDS(STR(?s), \"#{uri}\")) }")
#    sparql_client.query("SELECT * WHERE { ?s ?p ?o . FILTER(STRSTARTS(STR(?s), \"#{uri}\")) }")
  end

  def query_filter
    "STRSTARTS(STR(?s), \"#{uri}\")"
  end

end
