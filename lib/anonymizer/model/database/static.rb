# frozen_string_literal: true

# Basic class to communication with databese
class Database
  # Class to anonymize static data
  class Static
    def self.query(table_name, column_name, info)
      querys = []

      value = if info['action'] == 'empty'
                ''
              else
                info['value']
              end

      query = "UPDATE #{table_name} SET #{column_name} = '#{value}'"

      querys.push query

      querys
    end
  end
end
