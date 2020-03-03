# frozen_string_literal: true

# Model class for database
class Model
  attr_accessor :config, :name

  def initialize(action)
    @action = action
  end

  # rubocop:disable Style/RedundantSelf
  def action_class
    class_name = self.send('class_name_' + @action) if self.respond_to?('class_name_' + @action)
    class_name ||= 'Column'
    class_name
  end
  # rubocop:enable Style/RedundantSelf

  def class_name_truncate
    'Truncate'
  end

  def class_name_delete
    'Delete'
  end

  def class_name_empty
    'Static'
  end

  def class_name_set_static
    'Static'
  end

  def class_name_eav_update
    'Eav'
  end

  def class_name_json_update
    'Json'
  end

  def class_name_multiple_update
    'Multiple'
  end
end
