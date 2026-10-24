require "rails_helper"

RSpec.describe Interview, type: :model do
  it "はオンラインなら会議URLが必要" do
    interview = build(:interview, format: "online", meeting_url: nil)
    expect(interview).not_to be_valid
    expect(interview.errors[:meeting_url]).to be_present
  end

  it "は対面なら場所が必要" do
    interview = build(:interview, format: "onsite", meeting_url: nil, place: nil)
    expect(interview).not_to be_valid
    expect(interview.errors[:place]).to be_present
  end

  it "は電話ならURLと場所がなくても登録できる" do
    interview = build(:interview, format: "phone", meeting_url: nil, place: nil)
    expect(interview).to be_valid
  end

  it "は終了日時が開始より前だと登録できない" do
    start_at = Time.zone.parse("2026-10-24 10:00")
    interview = build(:interview, starts_at: start_at, ends_at: start_at)
    expect(interview).not_to be_valid
  end

  it "はサンプル応募の面接をサンプルにする" do
    application = create(:job_application, :sample_record)
    interview = create(:interview, job_application: application, sample: false)
    expect(interview.reload.sample).to be(true)
  end
end
