FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2025-11-17 04:23:03" }
  end
end
