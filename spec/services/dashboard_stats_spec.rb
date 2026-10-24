require "rails_helper"

RSpec.describe DashboardStats do
  let(:user) { create(:user) }

  before do
    create(:job_application, user: user, status: "applied", applied_on: Date.current)
    create(:job_application, user: user, status: "offered", applied_on: Date.current)
    create(:job_application, user: user, status: "interested", applied_on: Date.current)
    create(:job_application, user: user, status: "withdrawn", applied_on: Date.current)
    create(:job_application, :sample_record, user: user, status: "offered", applied_on: Date.current)
    create(:job_application, user: user, status: "applied", applied_on: Date.current - 100, company_name: "古い応募")
    application = user.job_applications.find_by!(company_name: "古い応募")
    create(:preparation_task, job_application: user.job_applications.find_by!(status: "offered", sample: false), user: user, completed: true, due_on: Date.current)
    create(:preparation_task, job_application: application, user: user, completed: false, due_on: Date.current)
  end

  it "はサンプルを除き、返信率をステータスから計算する" do
    stats = described_class.new(user: user, period_key: "all", include_sample: false)

    expect(stats.total_count).to eq(5)
    expect(stats.offer_count).to eq(1)
    expect(stats.reply_numerator).to eq(1)
    expect(stats.reply_denominator).to eq(4)
    expect(stats.reply_rate).to eq(25)
    expect(stats.task_completed).to eq(1)
    expect(stats.task_total).to eq(2)
    expect(stats.task_completion_rate).to eq(50)
  end

  it "は期間外の応募を除く" do
    stats = described_class.new(user: user, period_key: "this_month", include_sample: false)
    expect(stats.total_count).to eq(4)
  end

  it "は指定したときだけサンプルを含める" do
    stats = described_class.new(user: user, period_key: "all", include_sample: true)
    expect(stats.offer_count).to eq(2)
  end
end
