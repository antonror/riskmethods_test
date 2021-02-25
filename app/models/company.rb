# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :employees, dependent: :destroy

  scope :by_country_code, ->(country_code) {where(country_code: country_code)}
  scope :with_sanctioned_employees, -> {joins(:employees).where("employees.sanctioned = true")}
  scope :with_at_least_one_employee, -> {joins(:employees).group('companies.id').having('count(employees.id) > 1')}
  scope :with_employees_count, ->(employees_count) {joins(:employees).group('companies.id').having('count(employees.id) > ?', employees_count)}
end
