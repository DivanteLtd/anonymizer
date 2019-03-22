# frozen_string_literal: true

# Basic class to communication with databese
class Database
  # Class to remove records
  class Delete
    def self.query(table_name, _column_name, info)
      where = info['attributes']['where']
      queries = []
      query = "DELETE FROM #{table_name} WHERE #{where};"
      queries.push query
      queries
    end
  end
end
