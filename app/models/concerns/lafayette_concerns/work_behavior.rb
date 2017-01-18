module LafayetteConcerns
  module WorkBehavior
    extend ActiveSupport::Concern
    include LafayetteConcerns::Works::Metadata

    class_methods do
      def iiif_config_file
        "#{::Rails.root}/config/iiif.yml"
      end
      
      def iiif_yml
        require 'erb'
        require 'yaml'
        
        return @iiif_yml if @iiif_yml
        unless File.exist?(iiif_config_file)
          raise "You are missing a configuration file: #{iiif_config_file}."
        end
        
        begin
          iiif_erb = ERB.new(IO.read(iiif_config_file)).result(binding)
        rescue StandardError, SyntaxError => e
          raise("#{iiif_config_file} was found, but could not be parsed with ERB. \n#{e.inspect}")
        end
        
        begin
          @iiif_yml = YAML.load(iiif_erb)
        rescue => e
          raise("#{iiif_config_file} was found, but could not be parsed.\n#{e.inspect}")
        end
        
        if @iiif_yml.nil? || !@iiif_yml.is_a?(Hash)
          raise("#{iiif_config_file} was found, but was blank or malformed.\n")
        end
        
        @iiif_yml
      end
      
      def iiif_connection_config
        raise "The #{::Rails.env} environment settings were not found in the iiif.yml config" unless iiif_yml[::Rails.env]
        iiif_yml[::Rails.env].symbolize_keys
      end
    end

    def to_solr(solr_doc = {})
      super.tap do |doc|
        [
         'date_original',
         'date_artifact_upper',
         'date_artifact_lower',
         'date_image_upper',
         'date_image_lower'
        ].each do |attr_name|
          field_name = Solrizer.solr_name(attr_name, :stored_sortable, type: :date)
          fields = attributes[attr_name]
          doc[field_name] = fields.map { |field| Date.parse(field).xmlschema }
        end
      end
    end

    def remote_files=(*args)
      # super(*args)
      nil
    end

    def thumbnail_path
      path = Rails.application.routes.url_helpers.download_path(thumbnail.id,
                                                                file: 'thumbnail')
      Rails.configuration.absolute_url + path
    end

    def download_path
      path = Rails.application.routes.url_helpers.download_path(thumbnail.id)
      Rails.configuration.absolute_url + path
    end

    def jp2_path
      path = Rails.application.routes.url_helpers.download_path(representative.id,
                                                                file: 'jp2')
      Rails.configuration.absolute_url + path
    end

    def iiif_images
      #file_sets.map do |representative|
      member_ids.map do |representative_id|
#        response = Faraday.get("#{ENV['IMAGE_SERVER_URI']}/#{representative_id}/info.json")
#        image = JSON.parse(response.body)
#        image = {"profile": ["http://iiif.io/api/image/2/level2.json", {"supports": ["canonicalLinkHeader", "profileLinkHeader", "mirroring", "rotationArbitrary", "sizeAboveFull", "regionSquare"], "qualities": ["default", "bitonal", "gray", "color"], "formats": ["jpg", "png", "gif", "webp"]}], "tiles": [{"width": 1024, "scaleFactors": [1, 2, 4, 8, 16, 32]}], "protocol": "http://iiif.io/api/image", "sizes": [{"width": 104, "height": 148}, {"width": 207, "height": 295}, {"width": 413, "height": 590}, {"width": 825, "height": 1179}, {"width": 1650, "height": 2357}, {"width": 3299, "height": 4713}], "height": 4713, "width": 3299, "@context": "http://iiif.io/api/image/2/context.json"}

        "http://metadb.stage.lafayette.edu/#{representative_id}"
#        image['@id'] = "http://metadb.stage.lafayette.edu/#{representative_id}"
#        image['@id'] = "#{ENV['IMAGE_SERVER_URI']}/#{representative_id}/info.json"
#        image
      end
    end
  end
end
