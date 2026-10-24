class PreparationTask < ApplicationRecord
  include SampleRecord

  CATEGORIES = %w[research role practice documents follow_up other].freeze

  belongs_to :user
  belongs_to :job_application
  belongs_to :interview, optional: true

  before_validation :assign_user
  before_validation :inherit_sample, on: :create
  before_validation :normalize_text
  before_save :sync_completed_at

  validates :title, presence: true, length: { maximum: 120 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :memo, length: { maximum: 2000 }, allow_blank: true
  validate :user_matches_application
  validate :interview_matches_application

  scope :completed, -> { where(completed: true) }
  scope :open, -> { where(completed: false) }
  scope :in_period, ->(range) {
    if range.nil?
      all
    else
      start_time = range.begin.in_time_zone.beginning_of_day
      end_time = range.end.in_time_zone.end_of_day
      where(
        "(due_on BETWEEN :from_date AND :to_date) OR (due_on IS NULL AND created_at BETWEEN :from_time AND :to_time)",
        from_date: range.begin.to_date,
        to_date: range.end.to_date,
        from_time: start_time,
        to_time: end_time
      )
    end
  }

  def self.category_label(category)
    I18n.t("preparation_tasks.categories.#{category}")
  end

  def self.category_options
    CATEGORIES.map { |category| [category_label(category), category] }
  end

  def category_label
    self.class.category_label(category)
  end

  def overdue?(today = Date.current)
    due_on.present? && !completed? && due_on < today
  end

  private

  def normalize_text
    self.title = title.to_s.strip
    self.memo = memo.to_s.strip.presence
  end

  def assign_user
    self.user ||= job_application&.user
  end

  def inherit_sample
    self.sample = true if job_application&.sample?
  end

  def user_matches_application
    return if job_application.nil? || user.nil?
    return if user_id == job_application.user_id

    errors.add(:user, :mismatched)
  end

  def interview_matches_application
    return if interview_id.blank?
    return if interview && interview.job_application_id == job_application_id

    errors.add(:interview_id, :mismatched)
  end

  def sync_completed_at
    if completed?
      self.completed_at ||= Time.current
    else
      self.completed_at = nil
    end
  end
end
