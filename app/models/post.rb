class Post < ApplicationRecord
  validates :title, presence: true

  has_many :comments, dependent: :destroy
end
