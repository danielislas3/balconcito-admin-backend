Rswag::Api.configure do |c|
  # Especificar la ubicación de los archivos de documentación Swagger
  c.openapi_root = Rails.root.join("swagger").to_s
end
