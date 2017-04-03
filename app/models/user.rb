class User < ApplicationRecord
  include Searchable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  store :settings, accessors: [ :page_settings ], coder: JSON

  before_create :assign_default_user_groups

  has_and_belongs_to_many :user_groups

  scope :by_id, -> (orderer = :desc) { order(id: orderer) }
  scope :by_email, -> (orderer = :asc) { order(email: orderer) }
  scope :by_first_name, -> (orderer = :asc) { order(first_name: orderer) }
  scope :by_last_name, -> (orderer = :asc) { order(last_name: orderer) }
  scope :by_created_at, -> (orderer = :desc) { order(created_at: orderer) }
  scope :for_user_group_name, -> (group_name) { joins(:user_groups).where('user_groups.name = ?', group_name).limit(1) }

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

  private

    def assign_default_user_groups
      if self.class.count == 0
        self.user_groups << UserGroup.find_by_name('admin')
      end
    end
end
