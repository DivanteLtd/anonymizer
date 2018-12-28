# frozen_string_literal: true

require 'spec_helper'

require './lib/anonymizer/model/database.rb'
require './lib/anonymizer/model/database/multiple.rb'

RSpec.describe Database::Multiple, '#multiple' do
  it 'should exists class Multiple' do
    expect(Object.const_defined?('Database::Multiple')).to be true
  end

  context '#Work with proper query' do
    table_name = 'object_store_2'
    join_table_name = 'object_query_5'
    join_table_column = 'oo_id'
    column_name = 'email'
    info = JSON.parse("
        {
          \"type\": \"email\",
          \"action\": \"multiple_update\",
          \"linked_tables\": {
            \"#{join_table_name}\": {
              \"column\": \"#{join_table_column}\"
            }
          }
        }
    ")

    it 'should be a sql returned by anonymize_column_query' do
      expect(Database::Multiple.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Multiple.query(table_name, column_name, info)).to eq(
        [
          "UPDATE #{table_name} SET #{column_name} = (" \
          "SELECT REPLACE(fake_user.email, '$uniq$', CONCAT('+', UUID())) FROM fake_user " \
          "ORDER BY RAND() LIMIT 1) WHERE #{table_name}.#{column_name} IS NOT NULL",
          "UPDATE #{join_table_name} as t1 INNER JOIN #{table_name} as t2 ON t1.#{join_table_column} " \
          "SET t1.#{column_name} = t2.#{column_name} WHERE t1.#{column_name} IS NOT NULL"
        ]
      )
    end
  end

  context '#Manage id type' do
    type = 'id'
    it 'should get random value' do
      expect(Database::Multiple.manage_type(type)).to eq('SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) ')
    end
  end

  context '#Manage non-id type' do
    type = 'email'
    it 'should get proper value for non-id type' do
      expect(Database::Multiple.manage_type(type)).to eq(
        "SELECT REPLACE(fake_user.email, '$uniq$', CONCAT('+', UUID())) FROM fake_user ORDER BY RAND() LIMIT 1) "
      )
    end
  end

  context '#Work with linked tables' do
    table_name = 'object_store_2'
    join_table_name = 'object_query_5'
    join_table_column = 'oo_id'
    column_name = 'email'
    linked_tables = JSON.parse("
      {
        \"#{join_table_name}\": {
          \"column\": \"#{join_table_column}\"
        }
      }
    ")
    querys = []
    it 'should get random value' do
      expect(Database::Multiple.manage_linked_tables(linked_tables, table_name, column_name, querys)).to eq(
        [
          "UPDATE #{join_table_name} as t1 INNER JOIN #{table_name} as t2 ON t1.#{join_table_column} " \
          "SET t1.#{column_name} = t2.#{column_name} WHERE t1.#{column_name} IS NOT NULL"
        ]
      )
    end
  end
end
