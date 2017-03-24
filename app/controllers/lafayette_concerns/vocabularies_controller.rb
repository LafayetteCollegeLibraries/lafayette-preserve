module LafayetteConcerns
class VocabulariesController < ApplicationController
  delegate :vocabulary_form_repository,  :all_vocabs_query, :to => :injector
  delegate :deprecate_vocabulary_form_repository, :to => :deprecate_injector

  def index
    # Filter for the "root" vocabulary namespace
    @vocabularies = LafayetteConcerns::Vocabulary.all.reject { |vocab| vocab.rdf_subject == namespace_uri }
  end

  def new
    @vocabulary = vocabulary_form_repository.new
  end

  def create
    respond_to do |format|

      format.json do

        attributes = params[:vocabulary]

        if attributes.include? :uri
          @vocabulary = LafayetteConcerns::Vocabulary.new(attributes.delete(:uri))
        else
          @vocabulary = LafayetteConcerns::Vocabulary.new(RDF::Node.new)
        end

        terms_attributes = attributes.delete(:terms)
        terms_attributes = [] if terms_attributes.nil?

        attributes.each_pair do |attr_name, value|
          @vocabulary.write_attribute(attr_name, attributes.fetch(attr_name, @vocabulary.read_attribute(attr_name)))
        end

        terms_attributes.each do |term_attributes|

          # Create the Term if it does not exist
          if term_attributes.include? :uri
            @term = Term.new(term_attributes.delete(:uri))
          else
            @term = Term.new(RDF::Node.new)
          end

          # Update the Term attributes
          term_attributes.each_pair do |attr_name, value|
            @term.write_attribute(attr_name, term_attributes.fetch(attr_name, @term.read_attribute(attr_name)))
          end

          @term.persist!
        end

        @vocabulary.persist!
      end

    end
  end

  def deprecate
    @term = vocabulary_form_repository.find(params[:id])
  end

  def edit
    @term = vocabulary_form_repository.find(params[:id])
  end



  def destroy

    # Special handling for blank nodes
    id = params[:id]
    uri = "http://#{ENV['VOCAB_DOMAIN'] || 'authority.localhost.localdomain'}/ns/#{id}"
    # uri = "#{namespace_uri}#{id}"

    begin
      @vocabulary = LafayetteConcerns::Vocabulary.find(uri)
      @vocabulary.destroy
    rescue ActiveTriples::NotFound
      render status: 404, layout:'404'
    end
  end

  def update
    respond_to do |format|

      format.json do

        attributes = params.fetch(:vocabulary, {})
        id = params[:id]
        vocab_uri = "http://#{ENV['VOCAB_DOMAIN'] || 'authority.localhost.localdomain'}/ns/#{id}"
        # vocab_uri = "#{namespace_uri}#{id}"

        @vocabulary = LafayetteConcerns::Vocabulary.find_or_initialize_by(uri: vocab_uri)

        terms_attributes = attributes.delete(:terms)
        terms_attributes = [] if terms_attributes.nil?

        # If this is a PUT request, remove all attributes
        if request.put?
          @vocabulary.class.properties.keys.each do |attr_name|
            @vocabulary.write_attribute(attr_name, attributes.fetch(attr_name, []))
          end
        end

        puts 'TRACE'
        puts attributes

        attributes.each_pair do |attr_name, value|
          puts 'TRACE2'
          puts attr_name
          puts 'Current value: '
          puts @vocabulary.read_attribute(attr_name)
          puts 'New value: '
          puts attributes.fetch(attr_name)
          
          @vocabulary.write_attribute(attr_name, attributes.fetch(attr_name, @vocabulary.read_attribute(attr_name)))
          puts 'Updated value: '
          puts @vocabulary.read_attribute(attr_name)
        end
        
        # If this is a PUT request, remove all Terms
        if request.put?
          @vocabulary.children.each do |term|
            term.destroy
          end
        end
        
        terms_attributes.each do |term_attributes|
          # Create the Term if it does not exist
          begin

            term = Term.find_or_initialize_by(uri: term_attributes[:uri])

            # Validate the namespace for the vocabulary
            if term.namespace != @vocabulary.namespace
              raise ActiveTriples::NotInNamespace.new(term)
            end

            # Validate the membership for the vocabulary
            if not @vocabulary.include? term
              raise ActiveTriples::NotInVocabulary.new(term)
            end

          rescue ActiveTriples::NotInNamespace => e
            @message = 'Namespace conflict between Term and Vocabulary'
            @term = e.term
            render status: 400, layout:'400_term'

          rescue ActiveTriples::NotInVocabulary => e
            @message = 'Term not a member of the Vocabulary'
            @term = e.term
            render status: 400, layout:'400_term'

          rescue ActiveTriples::NotFound => e
            # Handling for cases where there is a malformed URI for the new Term
            @message = 'Term could not be found or minted (is the URI for the term valid?)'
            @term = e.term
            render status: 400, layout:'400_term'
          end
        
          term_attributes.delete(:uri)
        
          # If the Term exists, ensure that those attributes which are not overwritten are preserved (if this is a PATCH request)
          if request.patch?
            term_attributes = term.to_h.merge(term_attributes) { |key, old_attr, new_attr| new_attr.empty? ? old_attr : new_attr }
          end
        
          # To be determined: Is this proper to the understanding of PATCH vs. PUT?  If "terms" captures the entire set of entities, is not a PATCH request for a Vocabulary essentially a PUT request for each Term?
          # Probably best not to undertake this approach; otherwise, updating only select attributes for Term resources will require a series of PUT requests to the Term service endpoints
        
          # Update the Term attributes
          term_attributes.each_pair do |attr_name, value|
            term.write_attribute(attr_name, term_attributes.fetch(attr_name, term.read_attribute(attr_name)))
          end
        
          term.persist!
        end
      
        @vocabulary.persist!
      end
    end
  end

  def deprecate_only
    edit_vocabulary_form = deprecate_vocabulary_form_repository.find(params[:id])
    edit_vocabulary_form.is_replaced_by = vocabulary_params[:is_replaced_by]

    if edit_vocabulary_form.save
      triples = edit_vocabulary_form.sort_stringify(edit_vocabulary_form.single_graph)
      rugged_create(params[:id], triples, "creating")
      rugged_merge(params[:id])

      redirect_to term_path(:id => params[:id])
    else
      @term = edit_vocabulary_form
      render "deprecate"
    end
  end

  def show
    respond_to do |format|
      format.json do
        uri = "#{namespace_uri}#{params[:id]}"
        @vocabulary = LafayetteConcerns::Vocabulary.find(uri)
        render 'show', status: :ok
      end
    end
  end

  private

  def vocabulary_params
    ParamCleaner.call(params[:vocabulary])
  end

  def injector
    @injector ||= VocabularyInjector.new(params)
  end

  def deprecate_injector
    @injector ||= DeprecateVocabularyInjector.new(params)
  end

  def base_uri(protocol = 'http:')
    "#{protocol}//#{ENV['VOCAB_DOMAIN'] || 'authority.localhost.localdomain'}"
  end

  def namespace_uri(protocol = 'http:')
    "#{base_uri}/ns/"
  end
end
end
