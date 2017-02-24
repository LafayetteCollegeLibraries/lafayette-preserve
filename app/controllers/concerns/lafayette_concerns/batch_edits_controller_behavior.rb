module LafayetteConcerns
  module BatchEditsControllerBehavior
    extend ActiveSupport::Concern

    included do
#    include CurationConcerns::Collections::AcceptsBatches

#    before_filter :filter_docs_with_access!, :only=>[:edit, :update, :destroy_collection]
      before_filter :check_for_empty!, :only=>[:edit, :destroy_collection]
#    skip_authorize_resource :only => :update
    end

    def update

      case params["update_type"]
      when "update"
        respond_to do |format|
          format.html { super }
          format.json do

            # Raise an exception for empty search queries
            raise NotImplementedError if !params.include?(:search)

            query = '*:*'
            search_params = params[:search]
            query_params = {"qt"=>"search", "facet.field"=>[], "facet.query"=>[], "facet.pivot"=>[], "fq"=>["({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "{!terms f=has_model_ssim}GenericWork,Collection", "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)"], "hl.fl"=>[], "rows"=>100000, "qf"=>"title_tesim description_tesim keyword_tesim subject_tesim creator_tesim contributor_tesim publisher_tesim based_near_tesim language_tesim date_uploaded_tesim date_modified_tesim date_created_tesim rights_tesim resource_type_tesim format_tesim identifier_tesim file_format_tesim all_text_timv", "q"=>"{!lucene}_query_:\"{!dismax v=$user_query}\" _query_:\"{!join from=id to=file_set_ids_ssim}{!dismax v=$user_query}\"", "facet"=>true, "sort"=>"score desc, system_create_dtsi desc", "pf"=>"title_tesim", "defType"=>"dismax", "fl" => "id"}
            if params.include?(:query)
              user_query = search_params[:query]
              query_params["user_query"] = user_query
            end

            # @todo Refactor
#            fqs = []
            logger.warn params[:facets]
            facet_params = search_params.fetch(:facets, {})
            fqs = facet_params.reject {|k,v| k == :range}.map do |field, facets|
              facets.map { |facet| "{!term f=#{field.to_s}}#{facet}" }
            end.flatten

            fqs = fqs + facet_params.fetch(:range, []).map do |field, range|
              range = range.first if range.is_a? Array

              range_begin = range.fetch(:begin, 'NOW')
              range_end = range.fetch(:end, 'NOW')
              # range_begin = range_begin.first if range_begin.is_a? Array
              # range_end = range_end.first if range_end.is_a? Array
              
              "#{field.to_s}:[#{range[:begin]} TO #{range[:end]}]"
            end

            query_params['fq'] = query_params['fq'] + fqs

            # An example of faceting by range

            # {"qt"=>"search", "facet.field"=>["human_readable_type_sim", "resource_type_sim", "creator_sim", "keyword_sim", "subject_sim", "language_sim", "based_near_sim", "publisher_sim", "file_format_sim", "subject_ocm_sim", "date_original_dtsi", "date_artifact_upper_dtsi", "date_artifact_lower_dtsi", "date_image_upper_dtsi", "date_image_lower_dtsi", "subject_loc_sim", "subject_lcsh_sim", "creator_photographer_sim", "creator_maker_sim", "publisher_original_sim"], "facet.query"=>[], "facet.pivot"=>[], "fq"=>["({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "{!terms f=has_model_ssim}GenericWork,Collection", "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "date_artifact_upper_dtsi:[1933-02-14T00:00:00Z TO 1945-08-15T00:00:00Z]"], "hl.fl"=>[], "rows"=>10, "qf"=>"title_tesim name_tesim", "q"=>"", "facet"=>true, "f.human_readable_type_sim.facet.limit"=>6, "f.resource_type_sim.facet.limit"=>6, "f.creator_sim.facet.limit"=>6, "f.keyword_sim.facet.limit"=>6, "f.subject_sim.facet.limit"=>6, "f.language_sim.facet.limit"=>6, "f.based_near_sim.facet.limit"=>6, "f.publisher_sim.facet.limit"=>6, "f.file_format_sim.facet.limit"=>6, "sort"=>"score desc, system_create_dtsi desc"}

            # An example of faceting
            # {"qt"=>"search", "facet.field"=>["human_readable_type_sim", "resource_type_sim", "creator_sim", "keyword_sim", "subject_sim", "language_sim", "based_near_sim", "publisher_sim", "file_format_sim", "subject_ocm_sim", "date_original_dtsi", "date_artifact_upper_dtsi", "date_artifact_lower_dtsi", "date_image_upper_dtsi", "date_image_lower_dtsi", "subject_loc_sim", "subject_lcsh_sim", "creator_photographer_sim", "creator_maker_sim", "publisher_original_sim"], "facet.query"=>[], "facet.pivot"=>[], "fq"=>["{!term f=creator_sim}Barre, L. -- artist", "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)", "{!terms f=has_model_ssim}GenericWork,Collection", "({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)"], "hl.fl"=>[], "rows"=>10, "qf"=>"title_tesim name_tesim", "q"=>"", "facet"=>true, "f.human_readable_type_sim.facet.limit"=>6, "f.resource_type_sim.facet.limit"=>6, "f.creator_sim.facet.limit"=>6, "f.keyword_sim.facet.limit"=>6, "f.subject_sim.facet.limit"=>6, "f.language_sim.facet.limit"=>6, "f.based_near_sim.facet.limit"=>6, "f.publisher_sim.facet.limit"=>6, "f.file_format_sim.facet.limit"=>6, "sort"=>"score desc, system_create_dtsi desc"}

            logger.warn query
            logger.warn query_params

            ActiveFedora::SolrService.query(query, query_params).each do |row|

              id = row.fetch(:id)
              logger.warn "Updating #{id}"

              generic_work_params = params[:updates]
              obj = ActiveFedora::Base.find(id)
              logger.warn "Updating #{id}"
              # obj.attributes = obj.attributes.merge(generic_work_params)
              logger.warn generic_work_params
              obj.attributes = generic_work_params.symbolize_keys
              # obj.visibility = generic_work_params[:visibility] if generic_work_params.include? :visibility
              obj.date_modified = Time.current.ctime
              obj.save!
            end
            render json: params[:batch_edit]
          end
        end
      when "delete_all"
        super
      end
    end

  end
end
