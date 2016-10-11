class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += [:add_volume_id]

  def add_volume_id solr_params
    if blacklight_params[:search_field] == '' && blacklight_params[:workid].present?
      solr_params[:fq] ||= []
      workid = blacklight_params[:workid]
      workid = "#{workid}*" unless workid.include? '*'
      solr_params[:fq] << "part_of_ssim:#{workid}"
    end
  end

  def restrict_to_works solr_params
    solr_params[:fq] ||= []
    solr_params[:fq] << "cat_ssi:work"
  end

  def build_all_authors_search solr_params = {}
    solr_params[:fq] = []
    solr_params[:fq] << 'cat_ssi:author'
    solr_params[:fq] << 'type_ssi:work'
    solr_params[:sort] = []
    solr_params[:sort] << 'id asc'
    solr_params[:rows] = 10000
  end

  def add_timestamp_interval solr_params
    timeinterval_string = '['+ (blacklight_params[:from].present? ? blacklight_params[:from] : '*')
    timeinterval_string += ' TO '
    timeinterval_string += (blacklight_params[:until].present? ? blacklight_params[:until] : '*') +']'
    solr_params[:fq] ||= []
    solr_params[:fq] << "timestamp:#{timeinterval_string}"
  end
end
