class HomeController < ApplicationController
  def index
    @connectors = Connector.failed.order(:name).where(manual_update: false)
  end
end
