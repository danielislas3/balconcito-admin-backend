FactoryBot.define do
  factory :lender do
    sequence(:name) { |n| "Prestamista #{n}" }
    contact_email { Faker::Internet.email }
    contact_phone { Faker::PhoneNumber.phone_number }
    relationship { "inversionista" }
    is_active { true }
    notes { "Prestamista de prueba" }

    trait :investor do
      sequence(:name) { |n| "Inversionista #{n}" }
      relationship { "inversionista" }
    end

    trait :family do
      sequence(:name) { |n| "Familiar #{n}" }
      relationship { "familiar" }
    end

    trait :friend do
      sequence(:name) { |n| "Amigo #{n}" }
      relationship { "amigo" }
    end

    trait :inactive do
      is_active { false }
    end
  end
end
