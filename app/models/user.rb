# frozen_string_literal: true
# User model
class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:github, :google_oauth2]
  has_many :notes
  has_many :uploads

  def after_initialize
    user.total_data = 0
    send_admin_email(user)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.image = auth.info.image
    end
  end

  def send_admin_email(user)
    NewUserMailer.new_user_email(user).deliver_now
  end
end
