# frozen_string_literal: true

# Basic class to communication with databese
class Database
  # Class to anonymize EAV data type
  class Eav
    def self.query(table_name, column_name, info) # rubocop:disable Metrics/MethodLength
      attributes = info['attributes']

      querys = []

      attributes.each do |attribute|
        querys.push "UPDATE #{table_name} " \
        'SET ' \
          "#{column_name} = (SELECT fake_user.#{attribute['type']} FROM fake_user ORDER BY RAND() LIMIT 1) " \
        'WHERE ' \
          'attribute_id = (SELECT ' \
            'attribute_id ' \
              'FROM eav_attribute ' \
              'WHERE ' \
                "attribute_code = '#{attribute['code']}' " \
                'AND entity_type_id = (SELECT ' \
                  'entity_type_id ' \
                    'FROM eav_entity_type ' \
                    "WHERE entity_type_code = '#{attribute['entity_type']}'));"
      end

      querys
    end
  end
end
