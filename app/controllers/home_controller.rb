class HomeController < ApplicationController
  before_action :authenticate_staff!

  def welcome

  end
end
