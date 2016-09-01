class VocabulariesController < ApplicationController
  delegate :vocabulary_form_repository,  :all_vocabs_query, :to => :injector
  delegate :deprecate_vocabulary_form_repository, :to => :deprecate_injector

  def index
    @vocabularies = Vocabulary.all
  end

  def new
    @vocabulary = vocabulary_form_repository.new
  end

  def create

    respond_to do |format|

      format.json do

        attributes = params[:vocabulary]

        if attributes.include? :uri
          @vocabulary = Vocabulary.new(attributes.delete(:uri))
        else
          @vocabulary = Vocabulary.new(RDF::Node.new)
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

      format.html do
        super
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
    uri = "http://#{Rails.application.routes.default_url_options[:vocab_domain]}/ns/#{id}"

    begin
      @vocabulary = Vocabulary.find(uri)
      @vocabulary.destroy
    rescue ActiveTriples::NotFound
      render status: 404, layout:'404'
    end
  end

  def update
    respond_to do |format|

      format.json do

        attributes = params[:vocabulary]
        uri = "http://#{Rails.application.routes.default_url_options[:vocab_domain]}/ns/#{params[:id]}"
        @vocabulary = Vocabulary.find_or_initialize_by(uri: uri)

        terms_attributes = attributes.delete(:terms)
        terms_attributes = [] if terms_attributes.nil?

        attributes.each_pair do |attr_name, value|
          @vocabulary.write_attribute(attr_name, attributes.fetch(attr_name, @vocabulary.read_attribute(attr_name)))
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
          rescue ActiveTriples::NotFound
            # Handling for cases where there is a malformed URI for the new Term
            render status: 400, layout:'400'
          end

          term_attributes.delete(:uri)

          # If the Term exists, ensure that those attributes which are not overwritten are preserved (if this is a PATCH request)
          if request.patch?
            term_attributes = term_attributes.merge(term.to_h) { |key, old_attr, new_attr| new_attr.empty? ? old_attr : new_attr }
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

      format.html do
        super
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
        # Query Solr for the collection.
        # run the solr query to find the collection members
        uri = "http://authority.lafayette.edu/ns/#{params[:id]}"
        @vocabulary = Vocabulary.find(uri)
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

end
