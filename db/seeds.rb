# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(
  display_name: 'Admin',
  email: 'admin@futurelithics.com',
  password: 'password',
  role: 'admin'
)

User.create!(
  display_name: 'Ivan the Terrible',
  email: 'ivan@futurelithics.com',
  password: 'password',
  role: 'cpu'
)

User.create!(
  display_name: 'Vlad the Impaler',
  email: 'vlad@futurelithics.com',
  password: 'password',
  role: 'cpu'
)
