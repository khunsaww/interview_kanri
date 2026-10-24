class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :job_applications, dependent: :destroy
  has_many :interviews, through: :job_applications
  has_many :preparation_tasks, dependent: :destroy

  validates :name, presence: true, length: { maximum: 40 }

  before_validation :strip_name

  private

  def strip_name
    self.name = name.to_s.strip
  end
end
