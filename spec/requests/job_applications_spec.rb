require "rails_helper"

RSpec.describe "応募", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it "はログインしないと一覧を見せない" do
    sign_out user
    get job_applications_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it "は応募を登録し、他人の応募は見せない" do
    post job_applications_path, params: {
      job_application: {
        company_name: "青葉ソフトウェア",
        job_title: "Webエンジニア",
        status: "applied",
        applied_on: Date.current.to_s,
        sample: true
      }
    }
    application = JobApplication.last
    expect(response).to redirect_to(job_application_path(application))
    expect(application.sample).to be(false)
    expect(application.user).to eq(user)

    other = create(:job_application)
    get job_application_path(other)
    expect(response).to have_http_status(:not_found)
  end

  it "は入力不足を422で戻す" do
    post job_applications_path, params: {
      job_application: { company_name: "", job_title: "営業", status: "interested" }
    }
    expect(response).to have_http_status(422)
    expect(response.body).to include("会社名")
  end

  it "はテキストファイルを受け取らない" do
    file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/note.txt"), "text/plain")
    post job_applications_path, params: {
      job_application: {
        company_name: "青葉ソフトウェア",
        job_title: "Webエンジニア",
        status: "interested",
        documents: [file]
      }
    }
    expect(response).to have_http_status(422)
    expect(JobApplication.count).to eq(0)
  end

  it "はキーワードで絞り込める" do
    create(:job_application, user: user, company_name: "青葉ソフトウェア")
    create(:job_application, user: user, company_name: "北町製作所")

    get job_applications_path, params: { q: "青葉" }
    expect(response.body).to include("青葉ソフトウェア")
    expect(response.body).not_to include("北町製作所")
  end
end
