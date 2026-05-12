class HomeController < ApplicationController
  def index
    if current_user.admin?
      redirect_to admin_dashboard_path
    else
      redirect_to seller_dashboard_path
    end
  end
end
