module ActiveTriplesAdapter
  extend ActiveSupport::Concern
  included do
    alias_method :orig_reload, :reload
    def reload
      # ?
    end

    def read_attribute(attr_name)
      getter = attr_name.to_sym
      send(getter)
    end

    def write_attribute(attr_name, value)
      setter = "#{attr_name}=".to_sym
      send(setter, value)
    end

    def destroy
      erase_old_resource
    end

    def update_attributes(attributes)
      attributes.each_pair do |attr_name, value|
        write_attribute(attr_name, attributes.fetch(attr_name, read_attribute(attr_name)))
      end
    end
  end

  module ClassMethods
    def sparql_client
      sparql_client ||= SPARQL::Client.new(ENV['TRIPLESTORE_URL'])
    end

    def repository
      repository = RDF::Blazegraph::Repository.new(ENV['TRIPLESTORE_URL'])
    end

    def all(*args)
      query_graph = TypedQuery.new(sparql_client, RDF::URI.new("http://purl.org/dc/dcam/VocabularyEncodingScheme")).run

      results = []
      query_graph.subjects.each do |uri|
        begin
          results << find(uri.to_s)
        rescue
          nil
        end
      end

      results.sort_by { |i| i.rdf_subject.to_s.downcase }
    end

    def find(uri)
      # Not certain why, but this invokes RestClient#send_delete_request when Vocabulary or Term is instantiated?
      query_graph = SingleQuery.new(sparql_client, RDF::URI.new(uri)).run

      results = GraphToTerms.new(repository, query_graph).terms(klass: self)
      raise ActiveTriples::NotFound.new(uri) if results.length == 0
      results.sort_by{|i| i.rdf_subject.to_s.downcase}.first
    end

    def find_by(attributes)
      find(attributes[:uri])
    end

    def find_or_initialize_by(attributes, &block)
      begin
        find_by(attributes)
      rescue ActiveTriples::NotFound
        new(attributes.fetch(:uri), attributes, &block)
      end
    end

    def exists?(uri)
      begin
        find(uri)
      rescue ActiveTriples::NotFound
        return false
      end
      true
    end
  end

end
