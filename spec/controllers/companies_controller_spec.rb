# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompaniesController, type: :request do
  describe 'GET /companies' do
    subject(:companies_list) do
      get '/companies', params: params
      response
    end

    let(:data) { companies_list.parsed_body.deep_symbolize_keys[:data] }
    let(:companies_ids) { (data || []).pluck(:id) }

    let(:params) { {} }
    let!(:riskmethods) { create :company, name: 'Riskmethods', country_code: 'de' }
    let!(:devskiller) { create :company, name: 'Devskiller', country_code: 'pl' }

    it 'has correct schema' do
      expect(companies_list.parsed_body.keys).to match_array %w[data meta]
    end

    describe 'data' do
      it "contains companies' infos" do
        expect(data).to match_array [
          { id: riskmethods.id, name: 'Riskmethods', employees_count: 0 },
          { id: devskiller.id, name: 'Devskiller', employees_count: 0 }
        ]
      end

      context 'when there are some employees' do
        before do
          create :employee, company: devskiller, sanctioned: false
          create :employee, company: devskiller, sanctioned: false
          create :employee, company: devskiller, sanctioned: false

          create :employee, company: riskmethods, sanctioned: true
          create :employee, company: riskmethods, sanctioned: false
        end

        it "contains companies' infos" do
          expect(data).to match_array [
            { id: riskmethods.id, name: 'Riskmethods', employees_count: 2 },
            { id: devskiller.id, name: 'Devskiller', employees_count: 3 }
          ]
        end
      end
    end

    context 'without any params' do
      it 'returns all companies' do
        expect(companies_ids).to match_array [riskmethods.id, devskiller.id]
      end
    end

    context 'with filter[country_code]' do
      let(:params) { { filter: { country_code: 'pl' } } }

      context 'when country_code is longer or shorter than 2' do
        let(:params) { { filter: { country_code: 'dee' } } }

        it 'returns correct status code' do
          expect(companies_list.status).to eq 400
        end

        it 'returns correct error' do
          expect(companies_list.parsed_body).to eq('errors' => ['wrong_country_code'])
        end
      end

      it 'returns companies with matching code' do
        expect(companies_ids).to eq [devskiller.id]
      end
    end

    context 'with filter[with_employees]' do
      context 'when with_employees is "sanctioned"' do
        let(:params) { { filter: { with_employees: 'sanctioned' } } }

        before do
          create :employee, company: riskmethods, sanctioned: true
          create :employee, company: riskmethods, sanctioned: false
          create :employee, company: devskiller, sanctioned: false
        end

        it 'returns companies that have at least one sanctioned employee' do
          expect(companies_ids).to eq [riskmethods.id]
        end

        it 'returns correct employees_count' do
          expect(data).to match_array [
            { id: riskmethods.id, name: 'Riskmethods', employees_count: 1 }
          ]
        end
      end

      context 'when with_employees is "any"' do
        let(:params) { { filter: { with_employees: 'any' } } }

        before do
          create :employee, company: devskiller, sanctioned: false
          create :employee, company: devskiller, sanctioned: false
        end

        it 'returns companies that have at least one employee' do
          expect(companies_ids).to eq [devskiller.id]
        end

        it 'returns correct employees_count' do
          expect(data).to match_array [
            { id: devskiller.id, name: 'Devskiller', employees_count: 2 }
          ]
        end
      end

      context 'when with_employees is different' do
        let(:params) { { filter: { with_employees: 'my-wrong-value' } } }

        it 'returns correct status code' do
          expect(companies_list.status).to eq 400
        end

        it 'returns correct error' do
          expect(companies_list.parsed_body).to eq('errors' => ['wrong_employee_state'])
        end
      end
    end

    context 'with filter[number_of_employees_greater_than]' do
      let(:params) { { filter: { number_of_employees_greater_than: 2 } } }

      before do
        create :employee, company: devskiller, sanctioned: false
        create :employee, company: devskiller, sanctioned: false
        create :employee, company: devskiller, sanctioned: false

        create :employee, company: riskmethods, sanctioned: true
        create :employee, company: riskmethods, sanctioned: false
      end

      it 'returns companies with number of employees greater than passed value' do
        expect(companies_ids).to eq [devskiller.id]
      end

      context 'when filter[with_employees] is also passed' do
        let(:params) { { filter: { number_of_employees_greater_than: 0, with_employees: 'sanctioned' } } }

        it 'returns companies with number of employees, with corresponding state, greater than passed value' do
          expect(companies_ids).to eq [riskmethods.id]
        end
      end
    end
  end
end
