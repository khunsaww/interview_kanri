class DashboardStats
  attr_reader :period_key, :include_sample

  def initialize(user:, period_key:, include_sample:)
    @user = user
    @period_key = Period.key(period_key)
    @include_sample = include_sample
    @range = Period.parse(@period_key)
  end

  def total_count
    status_counts.values.sum
  end

  def status_counts
    @status_counts ||= JobApplication::STATUSES.index_with { |status| grouped_counts[status] || 0 }
  end

  def offer_count
    status_counts["offered"]
  end

  def reply_numerator
    JobApplication::REPLIED_STATUSES.sum { |status| status_counts[status] }
  end

  def reply_denominator
    JobApplication::SUBMITTED_STATUSES.sum { |status| status_counts[status] }
  end

  def reply_rate
    return if reply_denominator.zero?

    (reply_numerator * 100.0 / reply_denominator).round
  end

  def task_total
    @task_total ||= tasks.count
  end

  def task_completed
    @task_completed ||= tasks.completed.count
  end

  def task_completion_rate
    return if task_total.zero?

    (task_completed * 100.0 / task_total).round
  end

  def upcoming_interviews(now = Time.current)
    interview_scope
      .where(
        "interviews.starts_at >= :now OR (interviews.ends_at IS NOT NULL AND interviews.ends_at >= :now)",
        now: now
      )
      .includes(:job_application)
      .order(:starts_at)
      .limit(5)
  end

  def due_reminders(now = Time.current)
    interview_scope
      .where(starts_at: now..(now + 1.day))
      .where.not(remind_minutes_before: nil)
      .includes(:job_application)
      .order(:starts_at)
      .select { |interview| interview.reminder_due?(now) }
  end

  def open_tasks
    scope = @user.preparation_tasks.open.includes(:job_application, :interview)
    scope = scope.real unless include_sample
    scope.order(Arel.sql("due_on IS NULL, due_on ASC")).limit(5)
  end

  private

  def applications
    @applications ||= begin
      scope = @user.job_applications
      scope = scope.real unless include_sample
      scope.in_period(@range)
    end
  end

  def grouped_counts
    @grouped_counts ||= applications.group(:status).count
  end

  def tasks
    @tasks ||= begin
      scope = @user.preparation_tasks
      scope = scope.real unless include_sample
      scope.in_period(@range)
    end
  end

  def interview_scope
    scope = @user.interviews
    include_sample ? scope : scope.real
  end
end
