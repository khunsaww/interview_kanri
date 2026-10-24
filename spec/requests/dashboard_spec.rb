require "rails_helper"

RSpec.describe "ダッシュボードとサンプル", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it "は自分の応募から返信率を表示する" do
    create(:job_application, user: user, status: "applied", applied_on: Date.current, company_name: "応募会社")
    create(:job_application, user: user, status: "offered", applied_on: Date.current, company_name: "内定会社")

    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("返信率")
    expect(response.body).to include("50%")
  end

  it "はサンプルを読み込み、自分の記録を残して削除できる" do
    real = create(:job_application, user: user, company_name: "自分の会社")

    post sample_data_path
    expect(user.job_applications.samples.count).to eq(3)
    expect(response).to redirect_to(root_path)

    post sample_data_path
    expect(user.job_applications.samples.count).to eq(3)

    delete sample_data_path
    expect(user.job_applications.samples.count).to eq(0)
    expect(JobApplication.exists?(real.id)).to be(true)
  end

  it "はヘルスチェックをログインなしで返す" do
    sign_out user
    get "/up"
    expect(response).to have_http_status(:ok)
  end
end
