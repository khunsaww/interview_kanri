FactoryBot.define do
  factory :interview do
    job_application
    starts_at { 1.day.from_now.change(min: 0) }
    ends_at { starts_at + 1.hour }
    format { "online" }
    round_name { "一次面接" }
    interviewer { "面接 花子" }
    meeting_url { "https://example.com/meet/room" }
    remind_minutes_before { 60 }
  end
end
