module SampleRecord
  extend ActiveSupport::Concern

  included do
    scope :samples, -> { where(sample: true) }
    scope :real, -> { where(sample: false) }
  end
end
