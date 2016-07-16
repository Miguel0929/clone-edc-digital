class User < ActiveRecord::Base
  enum role: [ :student, :mentor, :admin ]

  devise :database_authenticatable, :recoverable, :invitable, :validatable

  validates_presence_of :first_name, :last_name, :phone_number

  def name
    "#{first_name} #{last_name}"
  end

  def huminize_role
    roles = {student: 'Estudiante', mentor: 'Mentor', admin: 'Administrador'}
    roles[role.to_sym]
  end

  def status
    invitation_accepted_at.nil? ? 'Inactivo' : 'Activo'
  end
end
