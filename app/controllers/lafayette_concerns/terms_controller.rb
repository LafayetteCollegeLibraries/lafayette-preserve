
module LafayetteConcerns
  class TermsController < ApplicationController
    delegate :term_form_repository, :term_repository, :vocabulary_repository, :to => :injector
    delegate :deprecate_term_form_repository, :to => :deprecate_injector

    def show
      respond_to do |format|

        uri = "http://#{ENV['VOCAB_DOMAIN'] || 'authority.localhost.localdomain'}/ns/#{params[:vocabulary_id]}/#{params[:id]}"

        begin
          @term = Term.find(uri)
        rescue ActiveTriples::NotFound
          render status: 404, layout:'404'
        end

        format.json do
          render 'lafayette_concerns/terms/show', status: :ok
        end
        format.nt { render body: @term.full_graph.dump(:ntriples), :content_type => Mime::NT }
        format.jsonld { render body: @term.full_graph.dump(:jsonld, standard_prefixes: true), :content_type => Mime::JSONLD }
      end
    end
  
    private

    def render_404
      respond_to do |format|
        format.all { render nothing: true, status: 404 }
      end
    end
  end
end
