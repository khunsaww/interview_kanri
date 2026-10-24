class PreparationTasksController < ApplicationController
  before_action :set_task, only: [:edit, :update, :destroy]

  def new
    @job_application, @interview = parent_records
    @task = @job_application.preparation_tasks.new(interview: @interview, category: default_category)
  end

  def create
    @job_application, @interview = parent_records
    @task = @job_application.preparation_tasks.new(task_params)
    @task.user = current_user
    @task.interview ||= @interview if @interview
    if @task.save
      redirect_to return_path(@task), notice: "準備タスクを追加しました。"
    else
      render :new, status: 422
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_back fallback_location: return_path(@task), notice: "準備タスクを更新しました。"
    else
      render :edit, status: 422
    end
  end

  def destroy
    application = @task.job_application
    @task.destroy!
    redirect_back fallback_location: application, notice: "準備タスクを削除しました。"
  end

  private

  def parent_records
    if params[:interview_id].present?
      interview = current_user.interviews.find(params[:interview_id])
      [interview.job_application, interview]
    else
      [current_user.job_applications.find(params[:job_application_id]), nil]
    end
  end

  def set_task
    @task = current_user.preparation_tasks.find(params[:id])
    @job_application = @task.job_application
    @interview = @task.interview
  end

  def task_params
    params.require(:preparation_task).permit(:category, :title, :due_on, :memo, :completed, :interview_id)
  end

  def default_category
    params[:interview_id].present? ? "practice" : "research"
  end

  def return_path(task)
    if task.interview_id.present?
      interview_path(task.interview_id)
    else
      job_application_path(task.job_application)
    end
  end
end
