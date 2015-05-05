class Event < ActiveRecord::Base
  enum status: [:draft, :published, :finished]

  belongs_to :responsible,
             class_name: 'UserProfile',
             foreign_key: 'user_profile_id'

  belongs_to :place

  has_many :event_organizers
  has_many :sections
  has_many :competitors
  has_many :rounds
  has_many :event_tracks, through: :rounds

  validates_presence_of :responsible, :name, :range_from, :range_to

  before_validation :check_name_and_range, on: :create

  scope :visible, -> { where('status IN (1, 2)') }
  scope :officials, -> { where(is_official: true) }
  scope :warm_ups, -> { where(is_official: false) }

  private

  def check_name_and_range
    self.name ||= Time.now.strftime('%d.%m.%Y') + ': Competition'
    self.range_from ||= 3000
    self.range_to ||= 2000
  end  
end
