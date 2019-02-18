class Currency < ApplicationRecord
  has_many :users

  def add_user(user)
    self.users << user
  end
end
