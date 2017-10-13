require './init.rb'

LoggerHelper.file('rake')

task :default do
  puts ''
end

namespace 'project' do
  task :anonymize, [:project_name] do |_t, args|
    project_name = args[:project_name]

    LoggerHelper.file(project_name)

    Rake.application.invoke_task("project:copy_dump_from_remote[#{project_name}]")
    Rake.application.invoke_task("project:remove_database[#{project_name}]")
    Rake.application.invoke_task("project:restore_database[#{project_name}]")
    Rake.application.invoke_task("project:anonymize_database[#{project_name}]")
    Rake.application.invoke_task("project:dump_database[#{project_name}]")
    Rake.application.invoke_task("project:remove_database[#{project_name}]")
    Rake.application.invoke_task("project:remove_dump_from_tmp[#{project_name}]")
  end

  task :restore_database, [:project_name] do |_t, args|
    project_name = args[:project_name]
    database = {
      host: CONFIG['database']['host'],
      user: CONFIG['database']['user'],
      pass: CONFIG['database']['pass']
    }

    system(
      ShellHelper.create_database(
        project_name,
        database
      )
    )
    system(
      ShellHelper.restore_database(
        project_name,
        database,
        CONFIG['tmp_path']
      )
    )
  end

  task :anonymize_database, [:project_name] do |_t, args|
    project_name = args[:project_name]
    anonymizer = Anonymizer.new project_name

    db = Database.new anonymizer.config
    db.anonymize
  end

  task :dump_database, [:project_name] do |_t, args|
    project_name = args[:project_name]
    anonymizer = Anonymizer.new project_name
    database = {
      host: CONFIG['database']['host'],
      user: CONFIG['database']['user'],
      pass: CONFIG['database']['pass'],
      random_string: anonymizer.config['random_string']
    }

    system(
      ShellHelper.dump_database(
        project_name,
        database,
        ROOT_DIR + '/' + CONFIG['web_data_path']
      )
    )
  end

  task :remove_database, [:project_name] do |_t, args|
    project_name = args[:project_name]
    database = {
      host: CONFIG['database']['host'],
      user: CONFIG['database']['user'],
      pass: CONFIG['database']['pass']
    }

    system(
      ShellHelper.drop_database(
        project_name,
        database
      )
    )
  end

  task :copy_dump_from_remote, [:project_name] do |_t, args|
    project_name = args[:project_name]
    anonymizer = Anonymizer.new project_name

    system(
      ShellHelper.download_dump(
        project_name,
        {
          host: anonymizer.config['dump_server']['host'],
          port: anonymizer.config['dump_server']['port'],
          user: anonymizer.config['dump_server']['user'],
          dump_dir: anonymizer.config['dump_server']['path']
        },
        CONFIG['tmp_path'],
        anonymizer.config['dump_server']['rsync_options']
      )
    )
  end

  task :remove_dump_from_tmp, [:project_name] do |_t, args|
    project_name = args[:project_name]

    system(
      ShellHelper.remove_dump(
        project_name,
        CONFIG['tmp_path']
      )
    )
  end
end

namespace 'config' do
  task :validate_all_projects do |_t|
    projects = Dir[ROOT_DIR + '/config/project/*']

    projects.each do |file|
      filename = File.basename file
      project_name = filename.gsub('.json', '')

      task_validate_project = Rake::Task['config:validate_project']
      task_validate_project.invoke(project_name)
      task_validate_project.reenable
    end
  end

  task :validate_project, [:project_name] do |_t, args|
    project_name = args[:project_name]

    Anonymizer.new project_name
  end
end
