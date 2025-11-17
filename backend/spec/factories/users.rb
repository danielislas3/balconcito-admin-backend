FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'admin' }

    trait :manager do
      role { 'manager' }
    end

    trait :employee do
      role { 'employee' }
    end
  end
end
