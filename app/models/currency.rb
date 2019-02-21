class Currency < ApplicationRecord
  has_many :users

  validates :code,
    presence: true,
    uniqueness: true
    

  def add_user(user)
    self.users << user
  end
end
