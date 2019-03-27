# frozen_string_literal: true

# Basic class to communication with databese
class Database
  attr_accessor :config, :name

  def initialize(config)
    @config = config
    @db = Sequel.mysql2(
      @config['database']['name'],
      user: CONFIG['database']['user'],
      host: CONFIG['database']['host'],
      password: CONFIG['database']['pass']
    )
  end

  def anonymize
    insert_fake_data

    before_queries

    @config['tables'].each do |table_name, columns|
      queries = column_query(table_name, columns)

      queries.each do |query|
        query = merge_query_with_params(query) if !@config['params'].nil? && !@config['params'].empty?
        @db.run query
      end
    end

    after_queries

    remove_fake_data
  end

  def get_scenerio(info)
    scenerio = if @config['scenerio'].nil? || info[@config['scenerio']].nil?
                 'default'
               elsif @config['scenerio'] &&
                     !info[@config['scenerio']]['extended'].nil? &&
                     info[info[@config['scenerio']]['extended']].nil?
                 'default'
               elsif @config['scenerio'] &&
                     !info[@config['scenerio']]['extended'].nil? &&
                     !info[info[@config['scenerio']]['extended']].nil?
                 info[@config['scenerio']]['extended']
               else
                 @config['scenerio']
               end

    scenerio
  end

  def column_query(table_name, columns)
    queries = []

    columns.each do |column_name, info|
      if config['version'].nil? || config['version'] < 2
        column = info
        action = info['action']
      else
        scenerio = get_scenerio(info)
        column = info[scenerio]
        action = info[scenerio]['action']
      end

      Object.const_get(
        "Database::#{translate_acton_to_class_name(action)}"
      ).query(table_name, column_name, column).each do |query|
        queries.push query
      end

      break if action == 'truncate'
    end

    queries
  end

  def merge_query_with_params(query)
    params = @config['params'].split(';')
    params.each do |param, _value|
      param = param.split(':')
      query = query.gsub('%' + param[0] + '%', param[1].tr('|', ','))
    end
    query
  end

  def before_queries
    if @config['custom_queries'] &&
       @config['custom_queries']['before'] &&
       @config['custom_queries']['before'].is_a?(Array)

      @config['custom_queries']['before'].each do |query|
        @db.run query
      end
    end
  end

  def after_queries
    if @config['custom_queries'] &&
       @config['custom_queries']['after'] &&
       @config['custom_queries']['after'].is_a?(Array)

      @config['custom_queries']['after'].each do |query|
        @db.run query
      end
    end
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

  # rubocop:disable Metrics/MethodLength
  def translate_acton_to_class_name(action)
    case action
    when 'truncate'
      class_name = 'Truncate'
    when 'delete'
      class_name = 'Delete'
    when 'empty', 'set_static'
      class_name = 'Static'
    when 'eav_update'
      class_name = 'Eav'
    when 'json_update'
      class_name = 'Json'
    when 'multiple_update'
      class_name = 'Multiple'
    else
      class_name = 'Column'
    end

    class_name
  end
  # rubocop:enable Metrics/MethodLength

  def self.prepare_select_for_query(type)
    query = if type == 'fullname'
              "SELECT CONCAT_WS(' ', fake_user.firstname, fake_user.lastname) "
            else
              "SELECT fake_user.#{type} "
            end

    query
  end
end
