class DashboardController < ApplicationController
  def show
    @stats = DashboardStats.new(
      user: current_user,
      period_key: params[:period],
      include_sample: params[:include_sample] == "1"
    )
    @has_samples = current_user.job_applications.samples.exists?
    @has_real = current_user.job_applications.real.exists?
  end
end
