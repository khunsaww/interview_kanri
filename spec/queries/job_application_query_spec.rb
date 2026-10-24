require "rails_helper"

RSpec.describe JobApplicationQuery do
  let(:user) { create(:user) }

  it "は会社名で検索し、会社名で並べる" do
    create(:job_application, user: user, company_name: "ZZZ商事", applied_on: Date.current)
    create(:job_application, user: user, company_name: "AAA工業", applied_on: Date.current - 1)

    searched = described_class.new(user.job_applications, { q: "AAA" }).call
    expect(searched.map(&:company_name)).to eq(["AAA工業"])

    sorted = described_class.new(user.job_applications, { sort: "company_name", direction: "asc" }).call
    expect(sorted.map(&:company_name)).to eq(["AAA工業", "ZZZ商事"])
  end

  it "は選考状況と面接日で絞り込む" do
    matched = create(:job_application, user: user, status: "screening", company_name: "書類選考社")
    other = create(:job_application, user: user, status: "applied", company_name: "応募のみ社")
    create(:interview, job_application: matched, starts_at: Time.zone.parse("2026-10-24 10:00"), ends_at: Time.zone.parse("2026-10-24 11:00"))
    create(:interview, job_application: other, starts_at: Time.zone.parse("2026-11-02 10:00"), ends_at: Time.zone.parse("2026-11-02 11:00"))

    by_status = described_class.new(user.job_applications, { status: "screening" }).call
    expect(by_status).to contain_exactly(matched)

    by_date = described_class.new(user.job_applications, { interview_from: "2026-10-24", interview_to: "2026-10-24" }).call
    expect(by_date).to contain_exactly(matched)
  end

  it "は近い面接日の順に並べ、面接がない応募を後ろにする" do
    later = create(:job_application, user: user, company_name: "遅い会社")
    sooner = create(:job_application, user: user, company_name: "早い会社")
    create(:job_application, user: user, company_name: "面接なし")
    create(:interview, job_application: later, starts_at: 5.days.from_now.change(min: 0))
    create(:interview, job_application: sooner, starts_at: 1.day.from_now.change(min: 0))

    sorted = described_class.new(user.job_applications, { sort: "interview", direction: "asc" }).call
    expect(sorted.map(&:company_name)).to eq(["早い会社", "遅い会社", "面接なし"])
  end

  it "は不正な日付でも例外にしない" do
    query = described_class.new(user.job_applications, { applied_from: "2026-99-99" })
    expect { query.call.load }.not_to raise_error
    expect(query.errors).to include("日付は年-月-日の形式で入力してください。")
  end
end
