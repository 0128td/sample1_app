class Stamp < ApplicationRecord
  validates :name, presence: true
  validates :date, presence: true

  before_create :generate_token

  require "date"
  require "securerandom"

  def Stamp.search(date, name, date_from, date_to)
    if date
      Stamp.where(date: date)
    elsif name.present? && date_from.present? && date_to.present?
      Stamp.where("name like?", "%#{name}%").where(date: date_from..date_to).limit(31)
    elsif name.present? && date_from.present?
      Stamp.where("name like?", "%#{name}%").where("date >=?", date_from).limit(31)
    elsif name.present? && date_to.present?
      Stamp.where("name like?", "%#{name}%").where("date <=?", date_to).limit(31)
    elsif name
      Stamp.where("name like?", "%#{name}%").limit(31)
    else
      Stamp.none
    end
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end
