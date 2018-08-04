# frozen_string_literal: true

module DateHash
  def self.months(date, current_hash = {})
    next_date = date.strftime('%b, %Y')
    current_hash[next_date] = 0

    return current_hash if next_date == Time.zone.now.strftime('%b, %Y')

    months(date + 1.month, current_hash)
  end

  def self.days(date, current_hash = {})
    next_date = date.strftime('%A %d')
    current_hash[next_date] = []

    return current_hash if next_date == Time.zone.now.strftime('%A %d')

    days(date + 1.day, current_hash)
  end
end
