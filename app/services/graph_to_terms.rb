class GraphToTerms < Struct.new(:resource_factory, :graph)
  attr_reader :klass

  def terms
    graph.each_statement.group_by(&:subject).map do |subject, triples|
      type_of_graph(triples)
      t = klass.new(subject)
      t.insert(*triples)
      t
    end
  end

  def type_of_graph(triples)
    # iterate through the objects of each of the triples to determine what
    # type of vocabulary, predicate, or term this graph is representing so
    # that the proper type of repository can be persisted
    @klass = nil
    triples.each do |t|      
      if @klass == Term or @klass.nil?
        case t.object
          # when Vocabulary.type
          when 'http://purl.org/dc/dcam/VocabularyEncodingScheme'
          @klass = LafayetteConcerns::Vocabulary
        else
          @klass = LafayetteConcerns::Term
        end
      end
    end
  end

  private

  def build_term(subject, triples)
    # sets the class that the PolymorphicTermRepository will use to determine
    # how to persist the data to the triplestore
    resource_factory.repository_type = klass
    t = resource_factory.new(subject)
    t.insert(*triples)
    t
  end
end
