# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def parameterized?(value)
    return true if value&.parameterize == value

    errors.add(value.to_sym, "Must be parameterized: #{value}")
  end
end
