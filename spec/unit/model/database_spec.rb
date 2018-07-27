require 'spec_helper'

require './lib/anonymizer/model/database.rb'

RSpec.describe Database, '#database' do
  it 'should exists class Database' do
    expect(Object.const_defined?('Database')).to be true
  end

  context 'work with config' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'customer_entity'
      @column_name = 'email'
      @column_type = 'email'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should has setable class variables config' do
      db = Database.new @config

      expect(db.config['tables'][@table_name][@column_name]['type']).to eq(@column_type)
    end
  end

  context 'work with firstname type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'firstname'
      @column_type = 'firstname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::MySQL, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:run)

      db.anonymize
    end
  end

  context 'work with fullname type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_grid'
      @column_name = 'billing_name'
      @column_type = 'fullname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::MySQL, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:run)

      db.anonymize
    end
  end

  context 'work with postcode type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'postcode'
      @column_type = 'postcode'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::MySQL, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:run)

      db.anonymize
    end
  end

  context 'work with uniq login type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'name'
      @column_type = 'login'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::MySQL, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:run)

      db.anonymize
    end
  end

  context 'work with id type' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'name'
      @column_type = 'id'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::MySQL, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:run)

      db.anonymize
    end
  end

  context 'work with column to truncate' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'log_url'
      @column_name = 'postcode'
      @action = 'truncate'
      @eav_table_name = 'customer_address_entity_varchar'
      @eav_column_name = 'value'
      @eav_action = 'eav_update'
      @eav_attr_code = 'firstname'
      @eav_entity_type = 'customer_address'
      @eav_column_type = 'firstname'

      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "action": "' + @action + '"
              },
              "other_column": {
                "type": "postcode",
                "action": "update"
              },
              "' + @eav_table_name + '": {
                "' + @eav_column_name + '": {
                  "action": "' + @eav_action + '",
                  "attributes": [
                    {
                      "code": "' + @eav_attr_code + '",
                      "type": "' + @eav_column_type + '",
                      "entity_type": "' + @eav_entity_type + '"
                    }
                  ]
                }
              }
            }
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::MySQL, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:run).exactly(3).times

      db.anonymize
    end
  end

  context 'work with magento EAV model' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'customer_address_entity_varchar'
      @column_name = 'value'
      @action = 'eav_update'
      @attr_code = 'firstname'
      @entity_type = 'customer_address'
      @column_type = 'firstname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "action": "' + @action + '",
                "attributes": [
                  {
                    "code": "' + @attr_code + '",
                    "type": "' + @column_type + '",
                    "entity_type": "' + @entity_type + '"
                  },
                  {
                    "code": "lastname",
                    "type": "lastname",
                    "entity_type": "customer_address"
                  }
                ]
              }
            }
          }
        }'
      )
    end

    it 'anonymizer should create new istance of Sequel::MySQL, insert and remove fake data' do
      db = Database.new @config

      expect(db).to receive(:insert_fake_data)
      expect(db).to receive(:remove_fake_data)

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:run).exactly(2).times

      db.anonymize
    end
  end

  context 'insert fake data' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'firstname'
      @column_type = 'firstname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should call method create_table' do
      db = Database.new @config

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:create_table)
      expect_any_instance_of(Sequel::MySQL::Dataset).to receive(:insert).exactly(100).times

      db.insert_fake_data
    end
  end

  context 'remove fake data' do
    before do
      stub_const('CONFIG', 'database' => { 'host' => 'zupa', 'user' => 'zupa', 'pass' => 'zupa' })

      @name = 'magento_1_9'
      @table_name = 'sales_flat_order_address'
      @column_name = 'firstname'
      @column_type = 'firstname'
      @config = JSON.parse(
        '{
          "type": "basic",
          "database": {
            "name": "' + @name + '"
          },
          "tables": {
            "' + @table_name + '": {
              "' + @column_name + '": {
                "type": "' + @column_type + '",
                "action": "update"
              }
            }
          }
        }'
      )
    end

    it 'should call method drop_table' do
      db = Database.new @config

      expect_any_instance_of(Sequel::MySQL::Database).to receive(:drop_table)

      db.remove_fake_data
    end
  end
end
