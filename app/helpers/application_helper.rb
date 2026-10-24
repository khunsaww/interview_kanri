module ApplicationHelper
  def jp_date(value)
    return "未設定" if value.blank?

    l(value.to_date, format: :long)
  end

  def jp_time(value)
    return "未設定" if value.blank?

    l(value.in_time_zone, format: :long)
  end

  def percent_text(value)
    value.nil? ? "—" : "#{value}%"
  end

  def status_tag(status)
    tag.span(JobApplication.status_label(status), class: "status status-#{status}")
  end

  def sample_badge
    tag.span("サンプル", class: "badge-sample")
  end

  def active_nav(section)
    "page" if active_section == section
  end

  def current_attr(active)
    active ? { aria: { current: "true" } } : {}
  end

  def field_error(record, attribute)
    return if record.errors[attribute].empty?

    tag.p(record.errors.full_messages_for(attribute).to_sentence, class: "field-error", id: error_id(record, attribute))
  end

  def field_aria(record, attribute, hint_id: nil)
    aria = {}
    aria[:invalid] = true if record.errors[attribute].any?
    described = [hint_id, (error_id(record, attribute) if record.errors[attribute].any?)].compact
    aria[:describedby] = described.join(" ") if described.any?
    aria
  end

  def required_label(form, attribute)
    form.label(attribute) do
      safe_join([
        form.object.class.human_attribute_name(attribute),
        " ",
        tag.abbr("（必須）", title: "必須")
      ])
    end
  end

  def interview_summary(application)
    interview = application.next_interview
    return "未設定" if interview.nil?

    prefix = interview.starts_at >= Time.current ? "予定" : "直近の実施"
    "#{prefix} #{jp_time(interview.starts_at)} #{interview.round_name}"
  end

  def task_progress(application)
    tasks = application.preparation_tasks
    return if tasks.empty?

    "#{tasks.count(&:completed)} / #{tasks.size} 完了"
  end

  def reminder_items_json(interviews)
    interviews.map { |interview|
      {
        id: interview.id,
        title: "面接が近づいています",
        body: "#{interview.job_application.company_name} #{jp_time(interview.starts_at)}"
      }
    }.to_json
  end

  private

  def active_section
    case controller_name
    when "dashboard" then "dashboard"
    when "job_applications" then "applications"
    when "interviews" then "interviews"
    end
  end

  def error_id(record, attribute)
    "#{record.model_name.param_key}_#{attribute}_error"
  end
end
