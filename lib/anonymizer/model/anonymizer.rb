# frozen_string_literal: true

# Anonymizer to anonymize world
class Anonymizer
  attr_accessor :config

  def initialize(project_name, config = nil, scenerio = 'default', params = [])
    raise 'Invalid project name' unless project_name && project_name.is_a?(String)
    @project_name = project_name

    if config.nil?
      project_file_path = project_file_path project_file_name project_name
      raise 'Project not exists' unless project_file_path
      config = read_config project_file_path
    end

    config['scenerio'] = scenerio
    config['params'] = params

    @config = prepare_config config
  end

  def work(database)
    database.anonymize
  end

  private

  def prepare_config(config)
    if config['type'] == 'extended'
      project_file_path = project_file_path project_file_name config['basic_type']
      raise 'Basic type not exists' unless project_file_path
      basic_config = read_config project_file_path
      config = basic_config.deep_merge config
    end

    validate_config config

    config['database'] = { 'name' => @project_name }

    config
  end

  def validate_config(config)
    if !config.key?('dump_server') || config['dump_server'].empty?
      raise 'In project config file dump_server is not valid'
    end

    validate_dump_server config['dump_server']

    config['tables'].each do |_table_name, columns|
      columns.each do |column_name, info|
        if (config['version'].nil? || config['version'].nil < 2)
            validate_column(column_name, info)
        else
            info.each do |scenerio, scenerio_body|
                validate_column(column_name, scenerio_body, scenerio)
            end
        end
      end
    end
  end

  def validate_dump_server(dump_server)
    %w[host user port path].each do |variable|
      raise "In project config file dump_server #{variable} is not valid" unless dump_server.key?(variable)
    end
  end

  def validate_column(_column_name, info, scenerio='')
    raise 'In project config file founded column (' + _column_name + ', ' + scenerio + ') without defined action' unless info['action']
  end

  def read_config(project_file_path)
    JSON.parse File.read project_file_path
  end

  def project_file_name(project_name)
    project_name + '.json'
  end

  def project_file_path(project_file_name)
    project_file = nil

    if File.exist?(projects_dir + '/' + project_file_name)
      project_file = projects_dir + '/' + project_file_name
    elsif File.exist?(basic_projects_dir + '/' + project_file_name)
      project_file = basic_projects_dir + '/' + project_file_name
    end

    project_file
  end

  def root_dir
    @root_dir ||= File.dirname File.expand_path __dir__
  end

  def projects_dir
    @projects_dir ||= File.dirname(File.expand_path('..', root_dir)) + '/config/project'
  end

  def basic_projects_dir
    @basic_projects_dir ||= root_dir + '/project/basic'
  end
end
