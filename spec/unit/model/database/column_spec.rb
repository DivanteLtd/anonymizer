require 'spec_helper'

require './lib/anonymizer/model/database.rb'
require './lib/anonymizer/model/database/column.rb'

RSpec.describe Database::Column, '#eav' do
  it 'should exists class Column' do
    expect(Object.const_defined?('Database::Column')).to be true
  end

  context 'work with email type' do
    info = {}
    table_name = 'sales_flat_order_address'
    column_name = 'email'
    info['type'] = 'email'

    it 'should be a sql returned by anonymize_column_query' do
      expect(Database::Column.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Column.query(table_name, column_name, info)).to eq(
        [
          "UPDATE #{table_name} SET #{column_name} = (" \
        "SELECT REPLACE(fake_user.email, '$uniq$', CONCAT('+', UUID_SHORT())) FROM fake_user " \
        "ORDER BY RAND() LIMIT 1) WHERE #{table_name}.#{column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with firstname type' do
    info = {}
    table_name = 'sales_flat_order_address'
    column_name = 'firstname'
    info['type'] = 'firstname'

    it 'should be a sql returned by anonymize_column_query' do
      expect(Database::Column.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Column.query(table_name, column_name, info)).to eq(
        [
          "UPDATE #{table_name} " \
          "SET #{column_name} = (SELECT fake_user.#{info['type']} FROM fake_user ORDER BY RAND() LIMIT 1) " \
          "WHERE #{table_name}.#{column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with fullname type' do
    info = {}
    table_name = 'sales_flat_order_grid'
    column_name = 'billing_name'
    info['type'] = 'fullname'

    it 'should be a sql returned by anonymize_column' do
      expect(Database::Column.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Column.query(table_name, column_name, info)).to eq(
        [
          "UPDATE #{table_name} SET #{column_name} = (" \
        "SELECT CONCAT_WS(' ', fake_user.firstname, fake_user.lastname) FROM fake_user ORDER BY RAND() LIMIT 1) " \
        "WHERE #{table_name}.#{column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with postcode type' do
    info = {}
    table_name = 'sales_flat_order_address'
    column_name = 'postcode'
    info['type'] = 'postcode'

    it 'should be a sql returned by anonymize_column' do
      expect(Database::Column.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Column.query(table_name, column_name, info)).to eq(
        [
          "UPDATE #{table_name} " \
        "SET #{column_name} = (SELECT fake_user.#{info['type']} FROM fake_user ORDER BY RAND() LIMIT 1) " \
        "WHERE #{table_name}.#{column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with uniq login type' do
    info = {}
    table_name = 'sales_flat_order_address'
    column_name = 'name'
    info['type'] = 'login'

    it 'should be a sql returned by anonymize_column' do
      expect(Database::Column.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Column.query(table_name, column_name, info)).to eq(
        [
          "UPDATE #{table_name} SET #{column_name} = (" \
          "SELECT REPLACE(fake_user.#{info['type']}, '$uniq$', CONCAT('+', UUID_SHORT())) FROM fake_user " \
          "ORDER BY RAND() LIMIT 1) WHERE #{table_name}.#{column_name} IS NOT NULL"
        ]
      )
    end
  end

  context 'work with id type' do
    info = {}
    table_name = 'sales_flat_order_address'
    column_name = 'name'
    info['type'] = 'id'

    it 'should be a sql returned by anonymize_column' do
      expect(Database::Column.query(table_name, column_name, info).is_a?(Array)).to be true
      expect(Database::Column.query(table_name, column_name, info)).to eq(
        [
          "UPDATE #{table_name} " \
        "SET #{column_name} = (SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) "\
        "WHERE #{table_name}.#{column_name} IS NOT NULL"
        ]
      )
    end
  end
end
