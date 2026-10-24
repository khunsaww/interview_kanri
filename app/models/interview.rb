class Interview < ApplicationRecord
  include SampleRecord

  FORMATS = %w[online onsite phone].freeze
  REMIND_OPTIONS = [15, 30, 60, 180, 1440].freeze

  belongs_to :job_application
  has_many :preparation_tasks, dependent: :destroy

  before_validation :normalize_text
  before_validation :inherit_sample, on: :create

  validates :starts_at, presence: true
  validates :round_name, presence: true, length: { maximum: 40 }
  validates :format, inclusion: { in: FORMATS }
  validates :interviewer, length: { maximum: 80 }, allow_blank: true
  validates :place, length: { maximum: 120 }, allow_blank: true
  validates :place, presence: true, if: -> { format == "onsite" }
  validates :meeting_url, length: { maximum: 500 }, allow_blank: true, http_url: true
  validates :meeting_url, presence: true, if: -> { format == "online" }
  validates :memo, length: { maximum: 2000 }, allow_blank: true
  validates :remind_minutes_before, inclusion: { in: REMIND_OPTIONS }, allow_nil: true
  validate :ends_after_start

  def self.format_label(format)
    I18n.t("interviews.formats.#{format}")
  end

  def self.remind_label(minutes)
    I18n.t("interviews.reminders.#{minutes}")
  end

  def self.remind_options
    REMIND_OPTIONS.map { |minutes| [remind_label(minutes), minutes] }
  end

  def format_label
    self.class.format_label(format)
  end

  def reminder_label
    return "通知しない" if remind_minutes_before.blank?

    self.class.remind_label(remind_minutes_before)
  end

  def choice_label
    "#{I18n.l(starts_at, format: :long)} #{round_name}"
  end

  def reminder_due?(now = Time.current)
    return false if remind_minutes_before.blank? || starts_at.blank?

    starts_at >= now && starts_at <= now + remind_minutes_before.minutes
  end

  private

  def normalize_text
    self.round_name = round_name.to_s.strip
    self.interviewer = interviewer.to_s.strip.presence
    self.place = place.to_s.strip.presence
    self.meeting_url = meeting_url.to_s.strip.presence
    self.memo = memo.to_s.strip.presence
    self.remind_minutes_before = nil if remind_minutes_before.blank?
  end

  def inherit_sample
    self.sample = true if job_application&.sample?
  end

  def ends_after_start
    return if ends_at.blank? || starts_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, :after_start)
  end
end
