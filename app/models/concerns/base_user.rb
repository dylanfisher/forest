module BaseUser
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    store :settings, accessors: [:page_settings], coder: JSON

    before_create :assign_default_user_groups

    has_and_belongs_to_many :user_groups

    scope :by_email, -> (orderer = :asc) { order(email: orderer) }
    scope :by_first_name, -> (orderer = :asc) { order(first_name: orderer) }
    scope :by_last_name, -> (orderer = :asc) { order(last_name: orderer) }
    scope :for_user_group_name, -> (group_name) { joins(:user_groups).where('user_groups.name = ?', group_name) }
  end

  class_methods do
    def resource_description
      "Users are the website editors, administrators and content managers who have access to the CMS. Users are organized by user groups."
    end
  end

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

  def to_select2_response
    if respond_to?(:media_item) && media_item.try(:attachment_url, :thumb).present?
      img_tag = "<img src='#{media_item.attachment_url(:thumb)}' style='height: 21px; margin-right: 5px;'> "
    end
    user_group_badges = user_groups.collect { |ug| "<span class='badge badge-secondary h-100 ml-auto'>#{ug.name}</span>" }.reject(&:blank?)
    "<div class='d-flex align-items-baseline w-100'>#{img_tag}<span class='select2-response__id mr-2' data-id='#{id}' style='margin-right: 5px;'>#{id}</span> <span class='mx-1'>#{to_label}</span> #{user_group_badges.join()}</div>"
  end

  private

  def assign_default_user_groups
    if self.class.count == 0
      self.user_groups << UserGroup.find_by_name('admin')
    end
  end
end
