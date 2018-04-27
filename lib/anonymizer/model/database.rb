# Basic class to communication with databese
class Database
  attr_accessor :config, :name

  def initialize(config)
    @config = config
    @db = Sequel.mysql(
      @config['database']['name'],
      user: CONFIG['database']['user'],
      host: CONFIG['database']['host'],
      password: CONFIG['database']['pass']
    )
  end

  def anonymize
    insert_fake_data

    @config['tables'].each do |table_name, columns|
      querys = column_query(table_name, columns)

      querys.each do |query|
        @db.run query
      end
    end

    remove_fake_data
  end

  def column_query(table_name, columns) # rubocop:disable Metrics/MethodLength
    querys = []

    columns.each do |column_name, info|
      if info['action'] == 'truncate'
        querys = truncate_column_query(table_name)
        break
      elsif info['action'] == 'eav_update'
        info['attributes'].each do |attribute|
          querys.push anonymize_eav_query(table_name, column_name, attribute)
        end
      elsif info['action'] == 'json_update'
        info['fields'].each do |field|
          querys.push anonymize_json_query(table_name, column_name, field)
        end
      else
        querys.push anonymize_column_query(table_name, column_name, info['type'])
      end
    end

    querys
  end

  def anonymize_column_query(table_name, column_name, column_type)
    query = "UPDATE #{table_name} SET #{column_name} = ("

    if column_type == 'id'
      query << 'SELECT FLOOR((NOW() + RAND()) * (RAND() * 119))) '
    else
      query << prepare_select_for_query(column_type)

      query << 'FROM fake_user ORDER BY RAND() LIMIT 1) '
    end

    query << "WHERE #{table_name}.#{column_name} IS NOT NULL"

    query
  end

  def anonymize_eav_query(table_name, column_name, attribute) # rubocop:disable Metrics/MethodLength
    query = "UPDATE #{table_name} " \
      'SET ' \
        "#{column_name} = (SELECT fake_user.#{attribute['type']} FROM fake_user ORDER BY RAND() LIMIT 1) " \
      'WHERE ' \
        'attribute_id = (SELECT ' \
          'attribute_id ' \
            'FROM eav_attribute ' \
            'WHERE ' \
              "attribute_code = '#{attribute['code']}' " \
              'AND entity_type_id = (SELECT ' \
                'entity_type_id ' \
                  'FROM eav_entity_type ' \
                  "WHERE entity_type_code = '#{attribute['entity_type']}'))"

    query
  end

  def anonymize_json_query(table_name, column_name, field)
    query = "UPDATE #{table_name} " \
     'SET ' \
      "#{column_name} = JSON_REPLACE( #{column_name}, " \
        "\"#{field['path']}\"" \
        ", (SELECT fake_user.#{field['type']} FROM fake_user ORDER BY RAND() LIMIT 1) )"

    query
  end

  def truncate_column_query(table_name)
    querys = []

    querys.push 'SET FOREIGN_KEY_CHECKS = 0;'
    querys.push "TRUNCATE #{table_name}"
    querys.push 'SET FOREIGN_KEY_CHECKS = 1;'

    querys
  end

  def insert_fake_data
    Fake.create_fake_user_table @db

    fake_user = @db[:fake_user]

    100.times do
      fake_user.insert(Fake.user)
    end
  end

  def remove_fake_data
    @db.drop_table :fake_user
  end

  private

  def prepare_select_for_query(type)
    query = if type == 'email'
              "SELECT REPLACE(fake_user.email, '$uniq$', CONCAT('+', UUID_SHORT())) "
            elsif type == 'login'
              "SELECT REPLACE(fake_user.login, '$uniq$', CONCAT('+', UUID_SHORT())) "
            elsif type == 'fullname'
              "SELECT CONCAT_WS(' ', fake_user.firstname, fake_user.lastname) "
            else
              "SELECT fake_user.#{type} "
            end

    query
  end
end
