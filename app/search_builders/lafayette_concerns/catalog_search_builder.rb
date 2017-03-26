class LafayetteConcerns::CatalogSearchBuilder < Sufia::CatalogSearchBuilder
  self.default_processor_chain += [
    :show_range_faceted_results
  ]
  
  def show_range_faceted_results(solr_parameters)
    if blacklight_params.has_key? 'range'
      blacklight_params['range'].each_pair do |field, range|
        # Extract the field
        solr_date_field = Solrizer.solr_name(field, :stored_sortable, type: :date)
        date_field = (field == solr_date_field ? field : field)

#        raise NotImplementedError.new [field,solr_date_field]

        # Parse the date values
        range_begin = range.fetch('begin', 'NOW')
        range_end = range.fetch('end', 'NOW')

        iso_range_begin, iso_range_end = [range_begin,range_end].map do |range_value|
          if /^\d{4}$/.match range_value
            range_value = "#{range_value}-01-01"
          elsif /^\d{4}\-\d{2}$/.match range_value
            range_value = "#{range_value}-01"
          end
          
          begin
            iso_range_value = Date.parse(range_value).xmlschema
          rescue
            raise NotImplementedError
          end

          iso_range_value
        end

        solr_parameters[:fq] = solr_parameters[:fq] << "#{date_field}:[#{iso_range_begin} TO #{iso_range_end}]"
      end
    end
  end
end
