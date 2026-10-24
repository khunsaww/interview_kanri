class SampleData
  def self.load!(user)
    return false if user.job_applications.samples.exists?

    new(user).load!
    true
  end

  def self.clear!(user)
    user.job_applications.samples.destroy_all
  end

  def initialize(user)
    @user = user
  end

  def load!
    ActiveRecord::Base.transaction do
      create_aoba
      create_kitamachi
      create_mirai
    end
  end

  private

  def create_aoba
    application = create_application(
      company_name: "【サンプル】青葉ソフトウェア",
      job_title: "Webエンジニア",
      location: "東京都港区（ハイブリッド）",
      contact_name: "採用担当 佐藤",
      contact_info: "sato.sample@example.com",
      job_url: "https://example.com/jobs/sample-aoba",
      history: [
        { status: "interested", on: Date.current - 18 },
        { status: "applied", on: Date.current - 12, applied_on: Date.current - 12 },
        { status: "screening", on: Date.current - 8 },
        { status: "interviewing", on: Date.current - 2 }
      ],
      next_action: "面接後のお礼メールを送る",
      next_action_on: Date.current
    )

    application.interviews.create!(
      starts_at: (Date.current - 6).in_time_zone.change(hour: 11),
      ends_at: (Date.current - 6).in_time_zone.change(hour: 12),
      format: "onsite",
      round_name: "一次面接",
      interviewer: "鈴木 面接官",
      place: "東京都港区サンプルビル 3階",
      memo: "サンプルの対面面接です。"
    )
    upcoming = application.interviews.create!(
      starts_at: Time.zone.now + 45.minutes,
      ends_at: Time.zone.now + 105.minutes,
      format: "online",
      round_name: "二次面接",
      interviewer: "山田 面接官",
      meeting_url: "https://example.com/meet/sample-aoba",
      remind_minutes_before: 60,
      memo: "サンプルのオンライン面接です。"
    )
    application.preparation_tasks.create!(
      category: "research",
      title: "事業内容と競合を整理する",
      due_on: Date.current - 10,
      completed: true,
      memo: "サンプルの完了タスクです。"
    )
    application.preparation_tasks.create!(
      category: "practice",
      title: "想定質問を声に出して練習する",
      due_on: Date.current + 1,
      memo: "サンプルの未完了タスクです。"
    )
    application.preparation_tasks.create!(
      category: "follow_up",
      title: "二次面接のお礼メールを下書きする",
      due_on: Date.current,
      interview: upcoming,
      memo: "サンプルです。面接に紐づくタスクです。"
    )
  end

  def create_kitamachi
    application = create_application(
      company_name: "【サンプル】北町製作所",
      job_title: "法人営業",
      location: "大阪府大阪市",
      contact_name: "人事 高橋",
      contact_info: "06-0000-0000",
      job_url: "https://example.com/jobs/sample-kitamachi",
      history: [
        { status: "interested", on: Date.current - 9 },
        { status: "applied", on: Date.current - 5, applied_on: Date.current - 5 },
        { status: "screening", on: Date.current - 1 }
      ],
      next_action: "書類選考の結果を待つ",
      next_action_on: Date.current + 4
    )
    application.preparation_tasks.create!(
      category: "role",
      title: "募集要項と営業職の一日を確認する",
      due_on: Date.current + 2,
      memo: "サンプルの職種確認です。"
    )
  end

  def create_mirai
    application = create_application(
      company_name: "【サンプル】みらい食品",
      job_title: "データアナリスト",
      location: "福岡県福岡市（リモート可）",
      contact_name: "採用 伊藤",
      contact_info: "ito.sample@example.com",
      job_url: "https://example.com/jobs/sample-mirai",
      history: [
        { status: "applied", on: Date.current - 40, applied_on: Date.current - 40 },
        { status: "screening", on: Date.current - 30 },
        { status: "interviewing", on: Date.current - 18 },
        { status: "offered", on: Date.current - 3 }
      ],
      next_action: "オファー条件を確認して返答する",
      next_action_on: Date.current + 3
    )
    application.interviews.create!(
      starts_at: (Date.current - 10).in_time_zone.change(hour: 15),
      ends_at: (Date.current - 10).in_time_zone.change(hour: 16),
      format: "online",
      round_name: "最終面接",
      interviewer: "中村 役員",
      meeting_url: "https://example.com/meet/sample-mirai",
      memo: "サンプルの最終面接です。"
    )
    application.preparation_tasks.create!(
      category: "documents",
      title: "履歴書とポートフォリオを更新する",
      due_on: Date.current - 20,
      completed: true,
      memo: "サンプルの書類更新です。"
    )
  end

  def create_application(history:, **attributes)
    first, *rest = history
    application = @user.job_applications.create!(
      company_name: attributes.fetch(:company_name),
      job_title: attributes.fetch(:job_title),
      location: attributes[:location],
      contact_name: attributes[:contact_name],
      contact_info: attributes[:contact_info],
      job_url: attributes[:job_url],
      memo: "これはサンプルデータです。実際の応募ではありません。",
      sample: true,
      status: first.fetch(:status),
      status_changed_on: first.fetch(:on),
      applied_on: first[:applied_on]
    )
    rest.each do |change|
      application.update!(
        status: change.fetch(:status),
        status_changed_on: change.fetch(:on),
        applied_on: change[:applied_on] || application.applied_on
      )
    end
    application.update!(
      next_action: attributes[:next_action],
      next_action_on: attributes[:next_action_on]
    )
    application
  end
end
