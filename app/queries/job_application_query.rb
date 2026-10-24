class JobApplicationQuery
  SORT_KEYS = %w[company_name status applied_on interview next_action].freeze

  attr_reader :errors

  def initialize(relation, params)
    @relation = relation
    @params = params
    @errors = []
  end

  def call
    scope = @relation
    scope = filter_status(scope)
    scope = filter_sample(scope)
    scope = filter_search(scope)
    scope = filter_applied_on(scope)
    scope = filter_interview_on(scope)
    sort(scope)
  end

  def filtering?
    @params[:q].present? || @params[:status].present? || @params[:sample].present? ||
      @params[:applied_from].present? || @params[:applied_to].present? ||
      @params[:interview_from].present? || @params[:interview_to].present?
  end

  def sort_key
    key = @params[:sort].to_s
    SORT_KEYS.include?(key) ? key : "applied_on"
  end

  def direction
    requested = @params[:direction].to_s
    return requested if %w[asc desc].include?(requested)

    %w[company_name status next_action interview].include?(sort_key) ? "asc" : "desc"
  end

  private

  def filter_status(scope)
    status = @params[:status].to_s
    return scope if status.blank?
    return scope unless JobApplication::STATUSES.include?(status)

    scope.where(status: status)
  end

  def filter_sample(scope)
    case @params[:sample].to_s
    when "real" then scope.real
    when "sample" then scope.samples
    else scope
    end
  end

  def filter_search(scope)
    term = @params[:q].to_s.strip
    return scope if term.blank?

    like = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"
    scope.where(
      <<~SQL.squish,
        job_applications.company_name LIKE :q OR job_applications.job_title LIKE :q
        OR job_applications.location LIKE :q OR job_applications.memo LIKE :q
        OR job_applications.contact_name LIKE :q OR job_applications.contact_info LIKE :q
        OR job_applications.next_action LIKE :q
      SQL
      q: like
    )
  end

  def filter_applied_on(scope)
    range = date_range(:applied_from, :applied_to)
    return scope if range.nil?

    scope.where(applied_on: range)
  end

  def filter_interview_on(scope)
    range = date_range(:interview_from, :interview_to)
    return scope if range.nil?

    start_time = range.begin.in_time_zone.beginning_of_day
    end_time = range.end.in_time_zone.end_of_day
    scope.where(id: Interview.where(starts_at: start_time..end_time).select(:job_application_id))
  end

  def date_range(from_key, to_key)
    from = parse_date(@params[from_key])
    to = parse_date(@params[to_key])
    return if from.nil? && to.nil?
    return if from == :invalid || to == :invalid

    from ||= Date.new(2000, 1, 1)
    to ||= Date.new(2100, 1, 1)
    if from > to
      add_error(I18n.t("filters.date_order"))
      return
    end

    from..to
  end

  def parse_date(value)
    text = value.to_s.strip
    return if text.blank?

    Date.iso8601(text)
  rescue ArgumentError
    add_error(I18n.t("filters.invalid_date"))
    :invalid
  end

  def add_error(message)
    @errors << message unless @errors.include?(message)
  end

  def sort(scope)
    dir = direction == "asc" ? "ASC" : "DESC"
    case sort_key
    when "company_name"
      scope.order(Arel.sql("job_applications.company_name #{dir}, job_applications.id ASC"))
    when "status"
      quoted = JobApplication::STATUSES.map { |status| ActiveRecord::Base.connection.quote(status) }.join(", ")
      scope.order(Arel.sql("FIELD(job_applications.status, #{quoted}) #{dir}, job_applications.id ASC"))
    when "next_action"
      scope.order(Arel.sql("job_applications.next_action_on IS NULL, job_applications.next_action_on #{dir}, job_applications.next_action #{dir}, job_applications.id ASC"))
    when "interview"
      next_at = "MIN(CASE WHEN interviews.starts_at >= UTC_TIMESTAMP() THEN interviews.starts_at END)"
      scope.left_joins(:interviews)
           .select("job_applications.*, #{next_at} AS next_interview_at")
           .group("job_applications.id")
           .order(Arel.sql("next_interview_at IS NULL, next_interview_at #{dir}, job_applications.id ASC"))
    else
      scope.order(Arel.sql("job_applications.applied_on IS NULL, job_applications.applied_on #{dir}, job_applications.id DESC"))
    end
  end
end
