class HttpUrlValidator < ActiveModel::EachValidator
  FORMAT = %r{\Ahttps?://[^\s]+\z}i

  def validate_each(record, attribute, value)
    return if value.blank?
    return if value.match?(FORMAT)

    record.errors.add(attribute, :invalid_url)
  end
end
