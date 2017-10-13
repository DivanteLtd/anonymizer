require 'faker'

require 'spec_helper'
require './lib/anonymizer/model/fake/pesel.rb'

RSpec.describe Fake::Pesel, '#pesel' do
  context 'pesel' do
    it 'should generate fake and valid pesel number' do
      expect(Fake::Pesel.generate.length).to be 11

      pesel_weights = [9, 7, 3, 1, 9, 7, 3, 1, 9, 7]

      pesel = Fake::Pesel.generate

      sum = 0
      pesel[0, 9].split('').each_with_index do |number, index|
        sum += number.to_i * pesel_weights[index]
      end

      validation_mumber = sum % 10

      expect(validation_mumber).to be pesel[10].to_i
    end
  end
end
