class TerminalWorkplacesController < ApplicationController
  def index
    @terminal_workplaces = TerminalWorkplace.active
    respond_with(@terminal_workplaces)
  end
end
