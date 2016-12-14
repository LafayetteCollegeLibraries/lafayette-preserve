class ChildQuery < Struct.new(:sparql_client, :parent_uri)
  def run
    graph
  end

  private

  def graph
    @graph ||= SolutionsToGraph.new(solutions).graph
  end

  def solutions
    query.each_solution.to_a
  end

  def query
    sparql_client.query("SELECT * WHERE { ?s ?p ?o . FILTER(STRSTARTS(STR(?s), \"#{parent_uri}\")) }")
  end
end
