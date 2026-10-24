class SampleDataController < ApplicationController
  def create
    if SampleData.load!(current_user)
      redirect_to root_path, notice: "サンプルデータを読み込みました。会社名の【サンプル】とバッジで、自分の記録と区別できます。"
    else
      redirect_to root_path, alert: "サンプルデータはすでに読み込まれています。"
    end
  end

  def destroy
    SampleData.clear!(current_user)
    redirect_to root_path, notice: "サンプルデータを削除しました。自分で作成した記録は残しています。"
  end
end
