require 'spec_helper'

require './lib/anonymizer/model/database.rb'
require './lib/anonymizer/model/fake.rb'
require './lib/anonymizer/model/fake/pesel.rb'
require './lib/anonymizer/model/database/column.rb'
require './lib/anonymizer/model/database/eav.rb'
require './lib/anonymizer/model/database/json.rb'
require './lib/anonymizer/model/database/static.rb'
require './lib/anonymizer/model/database/truncate.rb'
require './lib/anonymizer/model/notifier.rb'
require './lib/anonymizer/model/notifier/mail.rb'

RSpec.describe Database, '#database' do
  context 'handle error from sql' do
    before do
      stub_const(
        'CONFIG',
        'database' => {
          'host' => 'zupa',
          'user' => 'zupa',
          'pass' => 'zupa'
        },
        'notifier' => {
          'mail' => {
            'enabled' => true,
            'address' => 'postfix',
            'port' => 25,
            'user_name' => 'anonymizer@example.com',
            'password' => 'password',
            'enable_starttls_auto' => false,
            'to' => 'somebody@example.com',
            'from' => 'anonymizer@example.com'
          }
        }
      )

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

    it 'should be a sql returned by anonymize_column_query' do
      db = Database.new @config

      expect_any_instance_of(Notifier).to receive(:send)

      db.anonymize
    end
  end
end