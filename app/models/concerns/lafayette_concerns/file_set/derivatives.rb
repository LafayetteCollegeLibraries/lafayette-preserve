module LafayetteConcerns
  module FileSet
    module Derivatives
      extend ActiveSupport::Concern
      extend CurationConcerns::FileSet::Derivatives

      # This must be overridden with additional directives in order to support:
      # * Custom sizes specified by users
      # * Branding specified by users
      def create_derivatives(filename)
        case mime_type
        when *self.class.pdf_mime_types
          Hydra::Derivatives::PdfDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail, format: 'jpg', size: '338x493', url: derivative_url('thumbnail') }])
          Hydra::Derivatives::FullTextExtract.create(filename,
                                                     outputs: [{ url: uri, container: "extracted_text" }])
        when *self.class.office_document_mime_types
          Hydra::Derivatives::DocumentDerivatives.create(filename,
                                                         outputs: [{ label: :thumbnail, format: 'jpg',
                                                                     size: '200x150>',
                                                                     url: derivative_url('thumbnail') }])
          Hydra::Derivatives::FullTextExtract.create(filename,
                                                     outputs: [{ url: uri, container: "extracted_text" }])
        when *self.class.audio_mime_types
          Hydra::Derivatives::AudioDerivatives.create(filename,
                                                      outputs: [{ label: 'mp3', format: 'mp3', url: derivative_url('mp3') },
                                                                { label: 'ogg', format: 'ogg', url: derivative_url('ogg') }])
        when *self.class.video_mime_types
          Hydra::Derivatives::VideoDerivatives.create(filename,
                                                      outputs: [{ label: :thumbnail, format: 'jpg', url: derivative_url('thumbnail') },
                                                                { label: 'webm', format: 'webm', url: derivative_url('webm') },
                                                                { label: 'mp4', format: 'mp4', url: derivative_url('mp4') }])
        when *self.class.image_mime_types
          Hydra::Derivatives::ImageDerivatives.create(filename,
                                                      outputs: [{ label: :thumbnail, format: 'png', size: '200x150>', url: derivative_url('thumbnail') },
                                                                { label: :jp2, format: 'jp2', url: derivative_url('jp2') }])
        end
      end
    end
  end
end
