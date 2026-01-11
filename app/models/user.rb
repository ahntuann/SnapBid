class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { user: 0, cs: 1, admin: 2 }

  after_initialize do
    self.role ||= :user if new_record?
  end
end
