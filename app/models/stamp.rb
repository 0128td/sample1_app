class Stamp < ApplicationRecord
  validates :name, presence: true
  validates :date, presence: true

  require "date"

  def Stamp.search(date, name, date_from, date_to)
    if date
      Stamp.where(date: date)
    elsif name.present? && date_from.present? && date_to.present?
      Stamp.where(name: name).where(date: date_from..date_to).limit(31)
    elsif name.present? && date_from.present?
      Stamp.where(name: name).where("date >=?", date_from).limit(31)
    elsif name.present? && date_to.present?
      Stamp.where(name: name).where("date <=?", date_to).limit(31)
    elsif name
      Stamp.where(name: name).limit(31)
    else
      Stamp.none
    end
  end
end
