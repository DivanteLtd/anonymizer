require 'json'

require 'spec_helper'
require './lib/anonymizer/helper/json_helper.rb'

RSpec.describe '#json_helper' do
  context 'check if valodator work fine wiht valid and invalid json' do
    before do
      @valid_json = '{"zupa": "zupa test", "zupa_array": [{"zupa1": "zupa1"}, {"zupa2": "zupa2"}]}'
      @invalid_json = 'zupa test'
    end

    it 'should be a valid json' do
      expect(JSONHelper.valid_json?(@valid_json)).to be true
    end

    it 'should be a invalid json' do
      expect(JSONHelper.valid_json?(@invalid_json)).to be false
    end
  end
end
