# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    outcome = CompaniesList.new(params).call

    if outcome[:errors].present?
      render json: outcome, status: :bad_request
    else
      render json: outcome, status: :ok
    end
  end
end
