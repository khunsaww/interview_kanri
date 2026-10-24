FactoryBot.define do
  factory :job_application do
    user
    sequence(:company_name) { |n| "#{Faker::Company.name} #{n}" }
    job_title { "ソフトウェアエンジニア" }
    applied_on { Date.current - 7 }
    status { "applied" }
    location { "東京都" }
    sample { false }

    trait :interested do
      status { "interested" }
      applied_on { nil }
    end

    trait :sample_record do
      sample { true }
      company_name { "【サンプル】テスト株式会社" }
    end
  end
end
