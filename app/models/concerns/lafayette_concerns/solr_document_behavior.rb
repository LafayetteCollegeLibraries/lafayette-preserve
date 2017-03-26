module LafayetteConcerns
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    # Handling for specific date fields
    def date_original
      date_field('date_original')
    end

    def date_artifact_upper
      #date_field('date_artifact_upper')
      field = first(Solrizer.solr_name('date_artifact_upper', :stored_sortable, type: :date))
      Date.parse(field).to_formatted_s(:standard)
    end

    def date_artifact_lower
      date_field('date_artifact_lower')
    end

    def date_image_lower
      date_field('date_image_upper')
    end
    def date_image_lower
      date_field('date_image_lower')
    end

    def jp2_path
      Rails.application.routes.url_helpers.download_path(representative.id,
                                                         file: 'jp2')
    end
  end
end
