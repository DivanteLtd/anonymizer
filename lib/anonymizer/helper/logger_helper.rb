# frozen_string_literal: true

# Helper for json
module LoggerHelper
  def self.file(file_name)
    return true if CONFIG['logger']['enabled'] != true

    $stdout.reopen(LOG_DIR + "/#{file_name}.log", 'w')
    $stderr.reopen(LOG_DIR + "/#{file_name}.log", 'w')
  end
end
