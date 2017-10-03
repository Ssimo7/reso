# frozen_string_literal: true

class Territory < ApplicationRecord
  has_many :territory_cities
  has_many :expert_territories
  has_many :experts, through: :expert_territories

  def to_s
    "#{id} : #{name}"
  end
end