class ApplicationController < ActionController::Base
  # skip_before_action :authenticate_user!, unless: :devise_controller?, raise: false
  before_action :authenticate_user!, :do_not_set_cookie, if: -> { request.format.json? }
  protect_from_forgery prepend: true, with: :null_session, unless: -> { request.format.json? }

  def do_not_set_cookie
    request.session_options[:skip] = true
  end
end
