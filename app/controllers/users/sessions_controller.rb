class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      seller_dashboard_path
    end
  end
end
