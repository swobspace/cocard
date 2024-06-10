require_dependency 'wobauth/concerns/models/user_concerns'
class Wobauth::User < ActiveRecord::Base
  # dependencies within wobauth models
  include UserConcerns

  # devise *cocard.devise_modules
  # or ... basic usage:
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable

  validates :password, confirmation: true
end

