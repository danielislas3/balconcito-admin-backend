Rswag::Ui.configure do |c|
  # Lista de endpoints de documentación Swagger
  # La ruta es relativa al path donde está montado Rswag::Api::Engine
  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'API V1'
end
