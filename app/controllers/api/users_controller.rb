module Api 
  class UsersController < ApiController
    skip_before_action :authenticate_user!, only: [:create], raise: false
    skip_before_action :verify_authenticity_token, only: [:create]
    # Generic API stuff here
    def create
      user = User.new(user_params)
      if user.save
        render json: {message: "#{user.email} create success."}, status: 201
      else
        render json: {message: user.errors.full_messages.join(", ")}
      end     
    end

    private
    def user_params
      params.permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end
  end
end