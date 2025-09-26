module Locations
  class NetworksController < NetworksController
    before_action :set_locatable

  private
    def set_locatable
      @locatable = Location.find(params[:location_id])
    end

#    def add_breadcrumb_show
#      add_breadcrumb_for([set_locatable, @log])
#    end

  end
end
