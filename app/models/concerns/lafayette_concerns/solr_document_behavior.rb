module LafayetteConcerns
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    def date_original
      date_field('date_original')
    end

    def date_artifact_upper
      date_field('date_artifact_upper')
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
  end
end
