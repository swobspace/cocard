class CardCertificatesController < ApplicationController
  before_action :set_card_certificate, only: [ :show ]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /card_certificates
  def index
    @card_certificates = @certable.card_certificates
    respond_with(@card_certificates)
  end

  # GET /card_certificates/1
  def show
    respond_with(@card_certificate)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_certificate
      @card_certificate = CardCertificate.find(params[:id])
    end

end
