require 'faker'

require 'spec_helper'
require './lib/anonymizer/model/fake.rb'

RSpec.describe Fake, '#fake' do
  it 'should exists class Fake' do
    expect(Object.const_defined?('Fake')).to be true
  end

  context 'fake user' do
    it 'should generate fake user data' do
      expect(Fake.user.is_a?(Hash)).to be true
      expect(Fake.user[:firstname].is_a?(String)).to be true
      expect(Fake.user[:lastname].is_a?(String)).to be true
      expect(Fake.user[:login].is_a?(String)).to be true
      expect(Fake.user[:email].is_a?(String)).to be true
      expect(Fake.user[:telephone].is_a?(String)).to be true
      expect(Fake.user[:company].is_a?(String)).to be true
      expect(Fake.user[:street].is_a?(String)).to be true
      expect(Fake.user[:postcode].is_a?(String)).to be true
      expect(Fake.user[:city].is_a?(String)).to be true
      expect(Fake.user[:vat_id].is_a?(String)).to be true
      expect(Fake.user[:ip].is_a?(String)).to be true
      expect(Fake.user[:quote].is_a?(String)).to be true
      expect(Fake.user[:website].is_a?(String)).to be true
      expect(Fake.user[:iban].is_a?(String)).to be true
      expect(Fake.user[:regon].is_a?(String)).to be true
      expect(Fake.user[:pesel].is_a?(String)).to be true
      expect(Fake.user[:json].is_a?(String)).to be true
    end

    it 'should exists string "$uniq$" in email address' do
      expect(Fake.user[:email].is_a?(String)).to be true
      expect(Fake.user[:email].include?('$uniq$')).to be true
    end

    it 'should exists string "$uniq$" in login' do
      expect(Fake.user[:login].is_a?(String)).to be true
      expect(Fake.user[:login].include?('$uniq$')).to be true
    end

    it 'should be a json' do
      expect(JSONHelper.valid_json?(Fake.user[:json])).to be true
    end
  end

  context 'regon' do
    it 'should generate fake and valid regon number' do
      expect(Fake.generate_regon.length).to be 9

      regon_weights = [8, 9, 2, 3, 4, 5, 6, 7]

      regon = Fake.generate_regon

      sum = 0
      regon[0, 7].split('').each_with_index do |number, index|
        sum += number.to_i * regon_weights[index]
      end

      validation_mumber = sum % 11
      validation_mumber = 0 if validation_mumber == 10

      expect(validation_mumber).to be regon[8].to_i
    end
  end
end
