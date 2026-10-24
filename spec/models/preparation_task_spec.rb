require "rails_helper"

RSpec.describe PreparationTask, type: :model do
  it "は別の応募の面接に紐づけられない" do
    application = create(:job_application)
    other = create(:interview)
    task = build(:preparation_task, job_application: application, interview: other)
    expect(task).not_to be_valid
  end

  it "は完了と未完了で完了日時を更新する" do
    task = create(:preparation_task, completed: false)
    task.update!(completed: true)
    expect(task.completed_at).to be_present

    task.update!(completed: false)
    expect(task.completed_at).to be_nil
  end

  it "はサンプル応募のタスクをサンプルにする" do
    application = create(:job_application, :sample_record)
    task = create(:preparation_task, job_application: application, user: application.user, sample: false)
    expect(task.reload.sample).to be(true)
  end
end
