class ClientCertificatesController < ApplicationController
  before_action :set_client_certificate, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /client_certificates
  def index
    @client_certificates = ClientCertificate.all
    respond_with(@client_certificates)
  end

  # GET /client_certificates/1
  def show
    respond_with(@client_certificate)
  end

  # GET /client_certificates/new
  def new
    @client_certificate = ClientCertificate.new
    respond_with(@client_certificate)
  end

  # GET /client_certificates/1/edit
  def edit
  end

  # POST /client_certificates
  def create
    if p12_params['p12'].present?
      p12 = p12_params['p12']
      pass = p12_params['passphrase']
      result = Cocard::ReadP12.new(p12: p12, exportpw: pass).call
      create_params = import_params.merge(result.params)
    else
      create_params = client_certificate_params
    end

    if result.success?
      @client_certificate = ClientCertificate.new(create_params)
      @client_certificate.save
    else
      @client_certificate.errors.add(:base, result.error_messages.join("; "))
    end
    respond_with(@client_certificate)
  end

  # PATCH/PUT /client_certificates/1
  def update
    @client_certificate.update(client_certificate_params)
    respond_with(@client_certificate)
  end

  # DELETE /client_certificates/1
  def destroy
    @client_certificate.destroy!
    respond_with(@client_certificate)
  end

  def import_p12
    @client_certificate = ClientCertificate.new
    respond_with(@client_certificate)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client_certificate
      @client_certificate = ClientCertificate.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def client_certificate_params
      params.require(:client_certificate)
            .permit(:name, :description, :cert, :pkey, :passphrase)
            .reject { |k, v| k == 'passphrase' && v.blank? }
    end

    def import_params
      params.require(:client_certificate)
            .permit(:name, :description)
    end

    def p12_params
      params.require(:client_certificate)
            .permit(:p12, :passphrase)
    end
end
