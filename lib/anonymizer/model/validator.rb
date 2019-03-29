# frozen_string_literal: true

# Validator for anonymizer
class Validator
  attr_accessor :config

  def initialize(project_name, config = nil, _scenerio = 'default', _params = [])
    raise 'Invalid project name' unless project_name && project_name.is_a?(String)
    @project_name = project_name
    @config = config
  end

  def config_overwrite(config)
    @config = config
  end

  def validate_project_name
    raise 'Invalid project name' unless @project_name && @project_name.is_a?(String)
  end

  def validate_type(project_file_path)
    raise 'Basic type not exists' unless project_file_path
  end

  def validate_project_file(project_file)
    raise 'Project not exists' unless project_file
  end

  # rubocop:disable Metrics/AbcSize
  def validate_config(config)
    if !config.key?('dump_server') || config['dump_server'].empty?
      raise 'In project config file dump_server is not valid'
    end

    validate_dump_server config['dump_server']

    config['tables'].each do |_table_name, columns|
      columns.each do |column_name, info|
        call_validate_column(column_name, info, config)
      end
    end

    validate_dump_actions(config) if !config['version'].nil? || config['version'].to_i > 1
  end

  def call_validate_column(column_name, info, config)
    if config['version'].nil? || config['version'] < 2
      validate_column(column_name, info, 'default-v1')
    else
      info.each do |scenerio, scenerio_body|
        validate_column(column_name, scenerio_body, scenerio)
      end
    end
  end

  # rubocop:disable Style/GuardClause
  def validate_dump_actions(config)
    unless config['dump_actions'].nil?
      error_path_msg, error_sceberios_msg, error_file_msg, error_table_msg = validate_dump_action_message

      raise error_path_msg unless config['dump_actions']['path']
      raise error_sceberios_msg unless config['dump_actions']['scenerios'].any?
      config['dump_actions']['scenerios'].each do |_scenerio, scenerio_config|
        raise error_file_msg unless scenerio_config['file']
        raise error_table_msg unless scenerio_config['tables']
      end
    end
  end
  # rubocop:enable Style/GuardClause
  # rubocop:enable Metrics/AbcSize

  def validate_dump_action_message
    error_path_msg = 'In project config file dump_actions path is not valid'
    error_sceberios_msg = 'Project config in dump_actions section doesn\'t have scenerios'
    error_file_msg = 'Project config in dump_actions section doesn\'t have file path in one of scenerios'
    error_table_msg = 'Project config in dump_actions section doesn\'t have tables in one of scenerios'

    [error_path_msg, error_sceberios_msg, error_file_msg, error_table_msg]
  end

  def validate_dump_server(dump_server)
    %w[host user port path].each do |variable|
      raise "In project config file dump_server #{variable} is not valid" unless dump_server.key?(variable)
    end
  end

  def validate_column(_column_name, info, _scenerio)
    raise 'In project config file founded column without defined action' unless info['action']
  end
end
