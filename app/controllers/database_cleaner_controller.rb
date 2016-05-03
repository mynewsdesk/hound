class DatabaseCleanerController < ApplicationController
  skip_before_filter :authenticate

  def index
    deleted = Build.where("created_at <= ?", 1.week.ago).destroy_all

    render json: { message: "#{deleted.length} builds removed" }
  end
end
