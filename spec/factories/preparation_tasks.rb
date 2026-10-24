FactoryBot.define do
  factory :preparation_task do
    job_application
    user { job_application.user }
    category { "research" }
    sequence(:title) { |n| "企業研究#{n}" }
    due_on { Date.current + 3 }
    completed { false }
  end
end
