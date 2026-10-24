class InterviewsController < ApplicationController
  before_action :set_interview, only: [:show, :edit, :update, :destroy]

  def index
    @view = params[:view] == "list" ? "list" : "calendar"
    @show_all = @view == "list" && params[:month] == "all"
    @month = parse_month
    @direction = params[:direction] == "desc" ? "desc" : "asc"
    scope = filtered_interviews
    @list_interviews = if @show_all
      scope.order(starts_at: @direction)
    else
      scope.where(starts_at: month_time_range(@month)).order(starts_at: @direction)
    end
    grid_start = @month.beginning_of_week(:sunday)
    grid_end = @month.end_of_month.end_of_week(:sunday)
    @calendar = InterviewCalendar.new(
      scope.where(starts_at: grid_start.in_time_zone.beginning_of_day..grid_end.in_time_zone.end_of_day).order(:starts_at),
      @month
    )
    @applications = current_user.job_applications.order(:company_name, :job_title)
  end

  def show
    @tasks = @interview.preparation_tasks.order(Arel.sql("completed ASC, due_on IS NULL, due_on ASC"))
  end

  def new
    load_applications
    @job_application = @applications.find_by(id: params[:job_application_id]) if params[:job_application_id].present?
    @interview = build_interview(@job_application)
  end

  def create
    load_applications
    @job_application = @applications.find_by(id: application_id_param)
    @interview = build_interview(@job_application)
    @interview.assign_attributes(interview_params)
    if @job_application.nil?
      @interview.errors.add(:job_application, :blank)
      render :new, status: 422
      return
    end

    if @interview.save
      redirect_to @interview, notice: "面接を登録しました。"
    else
      render :new, status: 422
    end
  end

  def edit
    @job_application = @interview.job_application
    @applications = current_user.job_applications.order(:company_name, :job_title)
  end

  def update
    if @interview.update(interview_params)
      redirect_to @interview, notice: "面接を更新しました。"
    else
      @job_application = @interview.job_application
      @applications = current_user.job_applications.order(:company_name, :job_title)
      render :edit, status: 422
    end
  end

  def destroy
    application = @interview.job_application
    @interview.destroy!
    redirect_to application, notice: "面接を削除しました。"
  end

  private

  def set_interview
    @interview = current_user.interviews.find(params[:id])
  end

  def load_applications
    @applications = current_user.job_applications.order(:company_name, :job_title)
  end

  def build_interview(application)
    attributes = default_interview_attributes
    if application
      application.interviews.new(attributes)
    else
      Interview.new(attributes)
    end
  end

  def default_interview_attributes
    start_at = (Time.zone.now + 1.day).change(hour: 10, min: 0)
    {
      format: "online",
      round_name: "一次面接",
      starts_at: start_at,
      ends_at: start_at + 1.hour
    }
  end

  def application_id_param
    params[:job_application_id].presence || params.dig(:interview, :job_application_id)
  end

  def interview_params
    params.require(:interview).permit(
      :starts_at, :ends_at, :format, :round_name, :interviewer,
      :meeting_url, :place, :remind_minutes_before, :memo
    )
  end

  def filtered_interviews
    scope = current_user.interviews.includes(:job_application)
    term = params[:q].to_s.strip
    return scope if term.blank?

    like = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"
    scope.references(:job_application).where(
      <<~SQL.squish,
        job_applications.company_name LIKE :q OR job_applications.job_title LIKE :q
        OR interviews.round_name LIKE :q OR interviews.interviewer LIKE :q
        OR interviews.place LIKE :q
      SQL
      q: like
    )
  end

  def parse_month
    return Date.current.beginning_of_month if params[:month].blank? || params[:month] == "all"

    Date.strptime(params[:month], "%Y-%m").beginning_of_month
  rescue ArgumentError
    Date.current.beginning_of_month
  end

  def month_time_range(month)
    month.beginning_of_month.in_time_zone.beginning_of_day..month.end_of_month.in_time_zone.end_of_day
  end
end
