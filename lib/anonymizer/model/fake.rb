# frozen_string_literal: true

# Generator to fake data
class Fake
  def self.user
    firstname = Faker::Name.first_name
    lastname = Faker::Name.last_name

    prepare_user_hash firstname, lastname
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.create_fake_user_table(database)
    database.create_table :fake_user do
      primary_key :id
      String :firstname
      String :lastname
      String :login
      String :email
      String :telephone
      String :company
      String :street
      String :postcode
      String :city
      String :full_address
      String :full_name
      String :vat_id
      String :ip
      String :quote
      String :website
      String :iban
      String :regon
      String :pesel
      String :json
    end
  end

  def self.prepare_user_hash(firstname, lastname)
    {
      firstname: firstname,
      lastname: lastname,
      email: Faker::Internet.email(name:"#{firstname} #{lastname}"),
      login: Faker::Internet.user_name(specifier:"#{firstname} #{lastname}",separators: %w[. _ -]),
      telephone: Faker::PhoneNumber.cell_phone,
      full_name: Faker::Name.name,
      company: Faker::Company.name,
      street: Faker::Address.street_name,
      postcode: Faker::Address.postcode,
      city: Faker::Address.city,
      full_address: Faker::Address.full_address,
      vat_id: Faker::Company.swedish_organisation_number,
      ip: Faker::Internet.private_ip_v4_address,
      quote: Faker::Movies::StarWars.quote,
      website: Faker::Internet.domain_name,
      iban: Faker::Bank.iban,
      regon: generate_regon,
      pesel: Fake::Pesel.generate,
      json: '{}'
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def self.generate_regon
    regon = district_number

    6.times do
      regon += Random.rand(0..9).to_s
    end

    sum = sum_for_wigths(regon, regon_weight)
    validation_mumber = (sum % 11 if sum % 11 != 10) || 0

    regon + validation_mumber.to_s
  end

  def self.regon_weight
    [8, 9, 2, 3, 4, 5, 6, 7]
  end

  def self.sum_for_wigths(numbers, weight_array)
    sum = 0
    numbers[0, numbers.length - 1].split('').each_with_index do |number, index|
      sum += number.to_i * weight_array[index]
    end

    sum
  end

  def self.district_number
    %w[01 03 47 49 91 93 95 97].sample
  end
end
