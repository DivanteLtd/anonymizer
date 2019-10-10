# frozen_string_literal: true

# Basic class to communication with databese
class Database
  attr_accessor :config, :name

  def initialize(config)
    @config = config
    @fake_len=CONFIG['fake_datas']
    @db = Sequel.connect(
      adapter: :mysql2,
      database: @config['database']['name'],
      user: CONFIG['database']['user'],
      host: CONFIG['database']['host'],
      port: CONFIG['database']['port'],
      max_connections: CONFIG['database']['max_connections'],
      password: CONFIG['database']['pass']
    )
  end

  def anonymize
    insert_fake_data

    before_queries

    @config['tables'].each do |table_name, columns|
      queries = column_query(table_name, columns)

      queries.each do |query|
        @db.run query
      end
    end

    after_queries

    remove_fake_data
  end

  def column_query(table_name, columns)
    queries = []

    columns.each do |column_name, info|
      Object.const_get(
        "Database::#{translate_acton_to_class_name(info['action'])}"
      ).query(table_name, column_name, info).each do |query|
        queries.push query
      end

      break if info['action'] == 'truncate'
    end

    queries
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
    Parallel.map(1..@fake_len,in_processes: (Concurrent.processor_count*2),progress: "Making fake data table") { 
	fake_user.insert(Fake.user) 
    }
    
  end
#  def insert_fake_data
#    Fake.create_fake_user_table @db
#    pool_size=30
#    jobs = Queue.new
#    fake_user = @db[:fake_user]
#    5000.times {|i| jobs.push i}
#    workers = (pool_size).times.map do
#      Thread.new do 
#	begin
#	  while x = jobs.pop(true)
#            fake_user.insert(Fake.user)
#            fake_user.insert(Fake.user)
#            fake_user.insert(Fake.user)
#            fake_user.insert(Fake.user)
#	  end
#        end
#      rescue ThreadError
#      end
#    end
#    workers.map(&:join)
#  end

  def remove_fake_data
    @db.drop_table :fake_user
  end

  # rubocop:disable Metrics/MethodLength
  def translate_acton_to_class_name(action)
    case action
    when 'truncate'
      class_name = 'Truncate'
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
