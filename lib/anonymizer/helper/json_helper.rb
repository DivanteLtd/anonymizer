# frozen_string_literal: true

# Helper for json
module JSONHelper
  def self.valid_json?(json)
    JSON.parse(json)
    true
  rescue StandardError
    false
  end
end
