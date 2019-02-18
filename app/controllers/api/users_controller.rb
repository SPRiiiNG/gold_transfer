module Api 
  class UsersController < ApiController
    skip_before_action :authenticate_api_user!, only: [:create], raise: false
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :get_region, only: [:create]

    def create
      user = User.new(user_params)
      user.region = @region
      if user.save
        render json: {message: "#{user.email} create success."}, status: 201
      else
        render json: {message: user.errors.full_messages.join(", ")}
      end     
    end

    private
    def get_region
      @region = Currency.where(code: region_params[:region]).first
    end

    def user_params
      params.permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end

    def region_params
      params.permit(:region)
    end
  end
end