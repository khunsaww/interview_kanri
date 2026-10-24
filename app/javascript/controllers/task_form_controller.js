import { Controller } from "@hotwired/stimulus"

const TITLES = {
  research: "企業研究",
  role: "職種の確認",
  practice: "想定質問の練習",
  documents: "履歴書・ポートフォリオの更新",
  follow_up: "お礼・フォローアップ",
  other: ""
}

export default class extends Controller {
  static targets = ["category", "title"]

  fill() {
    if (!this.hasTitleTarget || this.titleTarget.value.trim() !== "") return

    const suggestion = TITLES[this.categoryTarget.value]
    if (suggestion) this.titleTarget.value = suggestion
  }
}
