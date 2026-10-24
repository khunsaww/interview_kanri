require "rails_helper"

RSpec.describe User, type: :model do
  it "は名前がないと登録できない" do
    user = build(:user, name: "  ")
    expect(user).not_to be_valid
    expect(user.errors[:name]).to be_present
  end
end
