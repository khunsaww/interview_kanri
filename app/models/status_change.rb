class StatusChange < ApplicationRecord
  belongs_to :job_application

  validates :to_status, inclusion: { in: JobApplication::STATUSES }
  validates :from_status, inclusion: { in: JobApplication::STATUSES }, allow_nil: true
  validates :changed_on, presence: true
end
