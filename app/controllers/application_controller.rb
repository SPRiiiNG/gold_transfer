class ApplicationController < ActionController::Base
  # skip_before_action :authenticate_staff!, unless: :devise_controller?, raise: false
  # before_action :authenticate_staff!
  protect_from_forgery with: :exception

  protected
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || welcome_path
  end

  def after_sign_out_path_for(resource)
    new_staff_session_path
  end

  # def authenticate_staff!
  #   if staff_signed_in?
  #     super
  #   else
  #     redirect_to new_staff_session_path, :notice => 'please sign in'
  #   end
  # end
end
