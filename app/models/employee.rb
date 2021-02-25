# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :company

  scope :sanctioned, -> { where(sanctioned: true)}
end
