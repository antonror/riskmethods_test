# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    outcome = CompaniesList.new(params).call

    # your code here
    render json: {}
  end
end
