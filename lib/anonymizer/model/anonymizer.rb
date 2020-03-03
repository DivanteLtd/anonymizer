# frozen_string_literal: true

# Anonymizer to anonymize world
class Anonymizer
  attr_accessor :config

  def initialize(project_name, config = nil, scenerio = 'default', params = [])
    @project_name = project_name
    @config = config
    @validator = Validator.new project_name, config, scenerio, params
    @validator.validate_project_name
    if config.nil?
      project_file_path = project_file_path project_file_name project_name
      @validator.validate_project_file project_file_path
      config = read_config project_file_path
    end
    @config = prepare_config(config, scenerio, params)
  end

  def work(database)
    database.anonymize
  end

  private

  # rubocop:disable Style/IfUnlessModifier
  def prepare_config(config, scenerio, params)
    if config['type'] == 'extended'
      config = prepare_config_extended(config, scenerio, params)
    end

    @validator.validate_config config
    config['database'] = { 'name' => @project_name }
    @validator.config_overwrite config

    config
  end
  # rubocop:enable Style/IfUnlessModifier

  def prepare_config_extended(config, scenerio, params)
    project_file_path = project_file_path project_file_name config['basic_type']
    @validator.validate_type(project_file_path)
    basic_config = read_config project_file_path
    config = basic_config.deep_merge config if config['merge_protect'].nil?
    config['scenerio'] = scenerio
    config['params'] = params

    config
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
