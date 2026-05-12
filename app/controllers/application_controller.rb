class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :company_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :company_name, :phone])
  end

  def require_seller!
    redirect_to root_path, alert: "Access denied." unless current_user&.seller?
  end

  def require_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      seller_dashboard_path
    end
  end
end
