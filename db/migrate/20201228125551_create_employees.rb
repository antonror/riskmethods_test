# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[6.0]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.boolean :sanctioned
      t.belongs_to :company, index: true
      t.timestamps
    end
  end
end
