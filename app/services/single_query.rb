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
  end

  def query_filter
    "STRSTARTS(STR(?s), \"#{uri}\")"
  end

end
