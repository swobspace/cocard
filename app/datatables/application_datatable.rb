class ApplicationDatatable
  include Pagy::Backend
  delegate :params, :link_to, :link_to_unless, :link_to_if,
           :show_link, :edit_link, :delete_link, :dom_id, 
           :render,
           :to => :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      recordsTotal: count,
      recordsFiltered: total_entries,
      data: data
    }
  end

  def search_params(params, columns)
    searchparms = {}

    unless params['columns'].nil?
      params['columns'].each do |idx,col|
        unless col['search']['value'].blank?
          searchparms[columns[idx.to_i]] = col['search']['value']
        end
      end
    end

    unless params['search'].nil?
      unless params['search']['value'].blank?
        searchparms['search'] = params['search']['value']
      end
    end

    searchparms
  end

private

  def page
    params['start'].to_i / per_page + 1
  end

  def per_page
    params['length'].to_i > 0 ? params['length'].to_i : 10
  end

  def sort_column
    columns[params['order']['0']['column'].to_i]
  end

  def sort_direction
    params['order']['0']['dir'] == "desc" ? "desc" : "asc"
  end
end
