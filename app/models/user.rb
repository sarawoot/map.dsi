# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # validates :fname, :lname, presence: true

  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(self.username,"userPrincipalName").first
  end
  
end
