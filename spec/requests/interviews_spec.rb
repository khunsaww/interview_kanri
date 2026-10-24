require "rails_helper"

RSpec.describe "面接と準備", type: :request do
  let(:user) { create(:user) }
  let(:application) { create(:job_application, user: user, company_name: "青葉ソフトウェア") }

  before { sign_in user }

  it "は面接を登録し、オンラインでURLがないと受け付けない" do
    post job_application_interviews_path(application), params: {
      interview: {
        starts_at: 1.day.from_now.change(hour: 10, min: 0),
        format: "online",
        round_name: "一次面接",
        meeting_url: "https://example.com/meet/aoba"
      }
    }
    expect(response).to redirect_to(interview_path(Interview.last))

    post job_application_interviews_path(application), params: {
      interview: {
        starts_at: 2.days.from_now.change(hour: 10, min: 0),
        format: "online",
        round_name: "二次面接",
        meeting_url: ""
      }
    }
    expect(response).to have_http_status(422)
  end

  it "はカレンダーに面接を表示する" do
    create(:interview, job_application: application, round_name: "カジュアル面談", starts_at: Time.zone.now.change(hour: 12, min: 0), ends_at: Time.zone.now.change(hour: 13, min: 0))
    get interviews_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("青葉ソフトウェア")
    expect(response.body).to include("カジュアル面談")
  end

  it "は準備タスクを完了にできる" do
    task = create(:preparation_task, job_application: application, user: user, title: "企業研究")
    patch preparation_task_path(task), params: { preparation_task: { completed: "1" } }
    expect(response).to redirect_to(job_application_path(application))
    expect(task.reload).to be_completed
  end

  it "は他人の面接を見せない" do
    interview = create(:interview)
    get interview_path(interview)
    expect(response).to have_http_status(:not_found)
  end
end
