class DuckTerminalsController < ApplicationController
  def new
    @ducky = DuckTerminal.new(new_duck_params)
    respond_with(@ducky)
  end

  def show
    @ducky = DuckTerminal.new(duck_terminal_params)
    rmi = CardTerminals::RMI.new(card_terminal: @ducky)
    rmi.get_info do |result|
      result.on_failure do |message|
        @message = message
        errormsg = "Abfrage des Kartenterminals fehlgeschlagen!"
        Rails.logger.debug("DEBUG:: get_info: #{errormsg}")
        flash[:alert] = errormsg
      end

      result.on_success do |message, value|
        @value = value
        @decorated = CardTerminals::RMI::InfoDecorator.new(@value)
        @message = message
        @card_terminal = CardTerminal.find_or_initialize_by(mac: value.macaddr) do |c|
                           c.ip = value.current_ip
                           # c.current_ip = value.current_ip
                           c.name = value.terminalname
                           c.identification = @ducky.identification
                           c.firmware_version = value.firmware_version
                           c.serial = value.serial
                         end
        if @card_terminal.persisted?
          @card_terminal.ip = value.current_ip
          @card_terminal.name = value.terminalname
          @card_terminal.identification = @ducky.identification
          @card_terminal.firmware_version = value.firmware_version
          @card_terminal.serial = value.serial
          action = "Aktualisierung"
        else
          action = "Neuanlage"
        end
        if @card_terminal.save
          flash[:success] = "#{action} des Kartenterminals erfolgreich"
        else
          flash[:warning] = "#{action} des Kartenterminals fehlgeschlagen"
        end
      end

      result.on_unsupported do
        @message = 'unsupported'
        flash[:alert] = "Kartenterminal wird nicht unterstützt"
      end
    end
    respond_with(@ducky)
  end

  private
    # Only allow a trusted parameter "white list" through.
    def duck_terminal_params
      params.require(:duck_terminal)
            .permit(:identification, :firmware_version, :ip)
    end

    def new_duck_params
      params.permit(:identification, :firmware_version, :ip)
    end
end
