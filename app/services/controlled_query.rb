class ControlledQuery < Struct.new(:sparql_client, :uri)
  def run
    graph
  end

  private

  def graph
    # @graph ||= SolutionsToGraph.new(solutions).graph

    g = RDF::Graph.new
    solutions.each do |solution|
      statement = solution
      g.insert(RDF::Statement.new(subject: solution.s, predicate: RDF::URI.new("http://purl.org/dc/terms/isReferencedBy") , object: uri))
    end
    g
  end

  def solutions
    # puts 'trace solutions'
    # puts query.each_solution.each { |solution| puts solution.inspect }

    query.each_solution.to_a
  end

  def query
    # puts 'trace2'
    # puts RDF::URI.new("http://purl.org/dc/terms/isReferencedBy")
    # puts uri

    # sparql_client.select.where([:s, RDF::URI.new("http://purl.org/dc/terms/isReferencedBy"), :o]).limit(1) # Need to abstract and refactor this BADLY.
    # sparql_client.select.where([RDF::URI.new("http://authority.lafayette.edu/ns/testVocab"), :p, :o]).limit(10) # Need to abstract and refactor this BADLY.

    # sparql_client.select.where([:s, :p, :o]).filter(query_filter).filter("STRENDS(STR(?p), \"isReferencedBy\")")
    # sparql_client.select.where([:s, :p, :o]).filter("CONTAINS(STR(?p), \"isReferencedBy\")")
    # sparql_client.select.where([:s, :p, :o]).filter(query_filter)

    # puts <<-EOSPARQL
 # SELECT ?s ?p ?o
 # WHERE
 #   { ?s <http://purl.org/dc/terms/isReferencedBy> <#{uri.to_s}> }
 # EOSPARQL

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
