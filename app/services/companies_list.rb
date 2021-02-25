# frozen_string_literal: true

class CompaniesList
  ValidationError = Class.new(StandardError)

  def initialize(params)
    @params = params
    @errors = []

    @companies = nil
    @filters = {}
  end

  def call
    validate_params!
    extract_companies
    supply_data
  rescue ValidationError
    { errors: @errors }
  end

  def validate_params!
    extract_filter

    if !@params.empty?
      @errors << 'wrong_country_code' if @filters[:country_code].try(:length).to_i > 2
    end

    raise ValidationError unless @errors.empty?
  end

  private

  def extract_companies
    @companies = Company.all
  end

  def extract_filter
    filters = @params[:filter]

    return if filters.blank?
      @filters[:country_code] = filters[:country_code]
      @filters[:with_employees] = filters[:with_employees]
      @filters[:number_of_employees_greater_than] = filters[:number_of_employees_greater_than]
  end

  def supply_data
    response = Hash.new.with_indifferent_access
    response["meta"] = {}
    response["data"] = []

    country_code = @filters[:country_code]
    sanctioned = @filters[:with_employees]
    number_greater_than = @filters[:number_of_employees_greater_than]

    if country_code.present?
      companies = @companies.by_country_code(country_code)
    else
      companies = @companies
    end

    if sanctioned.eql?('sanctioned')
      companies = companies.with_sanctioned_employees
    elsif sanctioned.eql?('any')
      companies = companies.with_at_least_one_employee
    end


    if number_greater_than.present?
      companies = companies.with_employees_count(number_greater_than)
    end


    companies.each do |company|

      if sanctioned.eql?('sanctioned')
        employees_count = company.employees.sanctioned.count
      else
        employees_count = company.employees.count
      end

      response["data"] << { id: company.id, name: company.name, employees_count: employees_count }
    end

    response
  end
end
