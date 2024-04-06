# frozen_string_literal: true

module ControllerMacros
  def login_admin
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      @admin      = FactoryBot.create(:user)
      @admin_role = FactoryBot.create(:role, name: 'Admin')
      @admin_auth ||= Wobauth::Authority.create(authorizable: @admin, role: @admin_role)
      sign_in @admin
    end
  end

  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @user = FactoryBot.create(:user)
      sign_in @user
    end
  end
end
