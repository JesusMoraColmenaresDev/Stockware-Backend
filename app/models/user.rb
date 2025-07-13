class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

         
  #enum role: { user: 'user', admin: 'admin' }
  validates :name, presence: true
  #validates :is_enabled, inclusion: { in: [true, false] }

    def active_for_authentication?
      # `super` llama a la lógica original de Devise.
      # `&& is_enabled?` añade tu condición: el usuario debe estar habilitado.
      super && is_enabled?
    end

    def inactive_message
      is_enabled? ? super : "Tu cuenta ha sido deshabilitada. Por favor, contacta a un administrador."
    end
end
