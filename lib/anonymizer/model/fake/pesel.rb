# frozen_string_literal: true

# Generator to fake data
class Fake
  # Generator to fake PESEL id
  class Pesel
    def self.generate
      year = Random.rand(1900..2299)

      pesel = year_code(year)
      pesel += month_code(year)
      pesel += day_code

      4.times do
        pesel += Random.rand(0..9).to_s
      end

      pesel += (Fake.sum_for_wigths(pesel, pesel_weight) % 10).to_s

      pesel
    end

    def self.year_code(year)
      year_code = year.to_s.chars.last(2).join

      year_code
    end

    def self.month_code(year)
      month = Random.rand(1..12)

      month_code = month + month_code_sum_ingredient(year)
      month_code = '0' + month_code.to_s if month_code < 10

      month_code.to_s
    end

    def self.month_code_sum_ingredient(year)
      sum_ingredient = {
        18 => 80,
        19 => 0,
        20 => 20,
        21 => 40,
        22 => 60
      }

      sum_ingredient[year.to_s.chars.first(2).join.to_i]
    end

    def self.day_code
      day = Random.rand(0o1..31)
      day = ('0' + day.to_s) if day < 10

      day.to_s
    end

    def self.pesel_weight
      [9, 7, 3, 1, 9, 7, 3, 1, 9, 7]
    end
  end
end
