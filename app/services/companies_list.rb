# frozen_string_literal: true

class CompaniesList
  ValidationError = Class.new(StandardError)

  def initialize(params)
    @params = params
    @errors = []
  end

  def call
    validate_params!
    # your code here
  rescue ValidationError
    { success: false, errors: @errors }
  end

  def validate_params!
    raise ValidationError unless @errors.empty?
  end
end
