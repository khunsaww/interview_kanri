class JobApplicationsController < ApplicationController
  before_action :set_job_application, only: [:show, :edit, :update, :destroy]

  def index
    @query = JobApplicationQuery.new(current_user.job_applications, params)
    @job_applications = @query.call.to_a
    return if @job_applications.empty?

    ActiveRecord::Associations::Preloader.new(
      records: @job_applications,
      associations: [:interviews, :preparation_tasks]
    ).call
  end

  def show
    @status_changes = @job_application.status_changes.order(changed_on: :asc, created_at: :asc)
    @interviews = @job_application.interviews.order(:starts_at)
    @tasks = @job_application.preparation_tasks.includes(:interview).order(Arel.sql("completed ASC, due_on IS NULL, due_on ASC"))
  end

  def new
    @job_application = current_user.job_applications.new(status: "interested")
  end

  def create
    @job_application = current_user.job_applications.new(job_application_params)
    files = uploaded_files
    codes = upload_error_codes(files)
    if codes.any?
      codes.each { |code| @job_application.errors.add(:documents, code) }
      render :new, status: 422
      return
    end

    @job_application.documents.attach(files) if files.any?
    if @job_application.save
      redirect_to @job_application, notice: "応募を登録しました。"
    else
      render :new, status: 422
    end
  end

  def edit
  end

  def update
    files = uploaded_files
    remove_ids = document_ids_to_remove
    @job_application.assign_attributes(job_application_params)
    codes = upload_error_codes(files)
    if codes.any?
      codes.each { |code| @job_application.errors.add(:documents, code) }
      render :edit, status: 422
      return
    end

    if @job_application.save
      @job_application.documents.attach(files) if files.any?
      purge_documents(remove_ids)
      redirect_to @job_application, notice: "応募を更新しました。"
    else
      render :edit, status: 422
    end
  end

  def destroy
    @job_application.destroy!
    redirect_to job_applications_path, notice: "応募を削除しました。"
  end

  private

  def set_job_application
    @job_application = current_user.job_applications.find(params[:id])
  end

  def job_application_params
    params.require(:job_application).permit(
      :company_name, :job_title, :applied_on, :job_url, :location,
      :contact_name, :contact_info, :memo, :status, :status_changed_on,
      :next_action, :next_action_on
    )
  end

  def uploaded_files
    Array(params.dig(:job_application, :documents)).reject(&:blank?)
  end

  def upload_error_codes(files)
    files.filter_map { |file| JobApplication.upload_error(file) }.uniq
  end

  def document_ids_to_remove
    Array(params.dig(:job_application, :remove_document_ids)).reject(&:blank?)
  end

  def purge_documents(ids)
    return if ids.empty?

    @job_application.documents.where(id: ids).find_each(&:purge)
  end
end
