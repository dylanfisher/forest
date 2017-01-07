class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :user_groups

  scope :by_id, -> (orderer = :desc) { order(id: orderer) }
  scope :by_email, -> (orderer = :asc) { order(email: orderer) }
  scope :by_first_name, -> (orderer = :asc) { order(first_name: orderer) }
  scope :by_last_name, -> (orderer = :asc) { order(last_name: orderer) }
  scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }
  scope :search, -> (query) {
    where(self.column_names.reject{ |x|
      %w(id created_at updated_at).include? x
    }.collect{ |x|
      x + ' LIKE :query'
    }.join(' OR '), query: "%#{query}%")
  }

  def display_name
    [first_name, email].reject(&:blank?).first
  end

  def name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def admin?
    in_group? 'admin'
  end

  def in_group?(name)
    user_groups.any? { |ug| ug.name == name }
  end
end
