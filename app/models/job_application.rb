class JobApplication < ApplicationRecord
  include SampleRecord

  STATUSES = %w[interested applied screening interviewing offered rejected withdrawn].freeze
  SUBMITTED_STATUSES = %w[applied screening interviewing offered rejected withdrawn].freeze
  REPLIED_STATUSES = %w[screening interviewing offered rejected].freeze
  ALLOWED_DOCUMENT_TYPES = %w[application/pdf image/png image/jpeg image/webp].freeze
  MAX_DOCUMENT_SIZE = 10.megabytes

  belongs_to :user
  has_many :status_changes, dependent: :destroy
  has_many :interviews, dependent: :destroy
  has_many :preparation_tasks, dependent: :destroy
  has_many_attached :documents

  attr_accessor :status_changed_on

  before_validation :normalize_text
  validates :company_name, presence: true, length: { maximum: 80 }
  validates :job_title, presence: true, length: { maximum: 80 }
  validates :location, length: { maximum: 80 }, allow_blank: true
  validates :contact_name, length: { maximum: 80 }, allow_blank: true
  validates :contact_info, length: { maximum: 120 }, allow_blank: true
  validates :job_url, length: { maximum: 500 }, allow_blank: true, http_url: true
  validates :memo, length: { maximum: 5000 }, allow_blank: true
  validates :next_action, length: { maximum: 200 }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }
  validates :applied_on, presence: true, unless: -> { status == "interested" }
  validate :status_changed_on_is_date
  validate :acceptable_documents

  after_create :record_initial_status
  after_update :record_status_change, if: :saved_change_to_status?

  scope :in_period, ->(range) {
    if range.nil?
      all
    else
      start_time = range.begin.in_time_zone.beginning_of_day
      end_time = range.end.in_time_zone.end_of_day
      where(
        "(applied_on BETWEEN :from_date AND :to_date) OR (applied_on IS NULL AND created_at BETWEEN :from_time AND :to_time)",
        from_date: range.begin.to_date,
        to_date: range.end.to_date,
        from_time: start_time,
        to_time: end_time
      )
    end
  }

  def self.status_label(status)
    I18n.t("job_applications.statuses.#{status}")
  end

  def self.status_options
    STATUSES.map { |status| [status_label(status), status] }
  end

  def self.upload_error(file)
    return :invalid_type unless ALLOWED_DOCUMENT_TYPES.include?(file.content_type.to_s)
    return :too_large if file.size.to_i > MAX_DOCUMENT_SIZE

    nil
  end

  def status_label
    self.class.status_label(status)
  end

  def choice_label
    "#{company_name} / #{job_title}"
  end

  def next_interview(now = Time.current)
    upcoming = interviews.select { |item| item.starts_at && item.starts_at >= now }.min_by(&:starts_at)
    upcoming || interviews.max_by(&:starts_at)
  end

  private

  def normalize_text
    self.company_name = company_name.to_s.strip
    self.job_title = job_title.to_s.strip
    self.job_url = job_url.to_s.strip.presence
    self.location = location.to_s.strip.presence
    self.contact_name = contact_name.to_s.strip.presence
    self.contact_info = contact_info.to_s.strip.presence
    self.next_action = next_action.to_s.strip.presence
    self.memo = memo.to_s.strip.presence
  end

  def status_changed_on_is_date
    return if status_changed_on.blank? || status_changed_on.is_a?(Date)

    self.status_changed_on = Date.iso8601(status_changed_on.to_s)
  rescue ArgumentError
    errors.add(:status_changed_on, :invalid)
  end

  def parsed_status_changed_on
    status_changed_on if status_changed_on.is_a?(Date)
  end

  def record_initial_status
    status_changes.create!(
      from_status: nil,
      to_status: status,
      changed_on: parsed_status_changed_on || applied_on || Date.current
    )
  end

  def record_status_change
    status_changes.create!(
      from_status: status_before_last_save,
      to_status: status,
      changed_on: parsed_status_changed_on || Date.current
    )
  end

  def acceptable_documents
    return unless documents.attached?

    codes = documents.filter_map { |document| document_error(document.blob) }.uniq
    codes.each { |code| errors.add(:documents, code) }
  end

  def document_error(blob)
    return if blob.nil?
    return :invalid_type unless ALLOWED_DOCUMENT_TYPES.include?(blob.content_type.to_s)
    return :too_large if blob.byte_size.to_i > MAX_DOCUMENT_SIZE

    nil
  end
end
