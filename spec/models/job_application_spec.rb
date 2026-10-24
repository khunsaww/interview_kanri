require "rails_helper"

RSpec.describe JobApplication, type: :model do
  it "は気になるなら応募日がなくても登録できる" do
    application = build(:job_application, :interested)
    expect(application).to be_valid
  end

  it "は応募済みなら応募日が必要" do
    application = build(:job_application, status: "applied", applied_on: nil)
    expect(application).not_to be_valid
    expect(application.errors[:applied_on]).to be_present
  end

  it "は求人URLの形式を確認する" do
    application = build(:job_application, job_url: "javascript:alert(1)")
    expect(application).not_to be_valid
  end

  it "は登録時とステータス変更時に履歴を残す" do
    application = create(:job_application, status: "applied", applied_on: Date.current - 3)
    expect(application.status_changes.count).to eq(1)
    expect(application.status_changes.last.from_status).to be_nil
    expect(application.status_changes.last.to_status).to eq("applied")

    application.update!(status: "screening", status_changed_on: Date.current - 1)
    change = application.status_changes.order(:created_at).last
    expect(change.from_status).to eq("applied")
    expect(change.to_status).to eq("screening")
    expect(change.changed_on).to eq(Date.current - 1)

    expect { application.update!(memo: "メモだけ更新") }.not_to change { application.status_changes.count }
  end

  it "は不正な変更日を受け付けない" do
    application = create(:job_application)
    application.status_changed_on = "2026-13-40"
    expect(application).not_to be_valid
  end

  it "は許可していないファイルを添付できない" do
    application = build(:job_application)
    application.documents.attach(io: StringIO.new("hello"), filename: "note.txt", content_type: "text/plain")
    expect(application).not_to be_valid
  end

  it "はPDFを添付できる" do
    application = build(:job_application)
    application.documents.attach(
      io: StringIO.new("%PDF-1.1\n"),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )
    expect(application).to be_valid
  end

  it "は大きすぎるファイルを判定できる" do
    file = instance_double(ActionDispatch::Http::UploadedFile, content_type: "application/pdf", size: 11.megabytes)
    expect(JobApplication.upload_error(file)).to eq(:too_large)
  end
end
