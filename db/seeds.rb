# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Credential.create(
  company_name: 'Test company',
  country: '44',
  phone: '1234567890',
  username: 'wauser',
  password: 'test123',
  deployment_type: 'kubernetes'
)

Lookup.create(
  number: '441234567890',
  country: '44',
  phone: '1234567890'
)
