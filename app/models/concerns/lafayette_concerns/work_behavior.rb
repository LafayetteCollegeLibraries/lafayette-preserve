module LafayetteConcerns
  module WorkBehavior
    extend ActiveSupport::Concern
    include LafayetteConcerns::Works::Metadata

=begin

    def uploaded_files=(*args)
      # super(*args)
      nil
    end
=end

    def remote_files=(*args)
      # super(*args)
      nil
    end

    def thumbnail_path
      path = Rails.application.routes.url_helpers.download_path(thumbnail.id,
                                                                file: 'thumbnail')
      Rails.configuration.absolute_url + path.split('&').first
    end
  end
end
