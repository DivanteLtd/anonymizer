# frozen_string_literal: true

require 'spec_helper'

require './lib/anonymizer/model/database.rb'
require './lib/anonymizer/model/database/json.rb'

RSpec.describe Database::Json, '#eav' do
  it 'should exists class Json' do
    expect(Object.const_defined?('Database::Json')).to be true
  end

  context 'work with firstname type' do
    info = {}
    table_name = 'sales_flat_order_address'
    column_name = 'json_data'
    info['field'] = {
      'path' => '$.user.first_name',
      'type' => 'firstname'
    }

    it 'should be a sql returned by anonymize_column_query' do
      expect(Database::Json.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Json.query(table_name, column_name, info)).to eq(
        ["UPDATE #{table_name} " \
        "SET #{column_name} = JSON_REPLACE( #{column_name}, \"#{info['field']['path']}\", (" \
        "SELECT fake_user.#{info['field']['type']} " \
        'FROM fake_user ORDER BY RAND() LIMIT 1) )']
      )
    end
  end

  context 'work with id type' do
    info = {}
    table_name = 'sales_flat_order_address'
    column_name = 'json_data'
    info['field'] = {
      'path' => '$.user.id',
      'type' => 'id'
    }

    it 'should be a sql returned by anonymize_column_query' do
      expect(Database::Json.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Json.query(table_name, column_name, info)).to eq(
        ["UPDATE #{table_name} " \
        "SET #{column_name} = JSON_REPLACE( #{column_name}, \"#{info['field']['path']}\", (" \
        'SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) )']
      )
    end
  end
end
