Rswag::Ui.configure do |c|
  # Lista de endpoints de documentación Swagger
  # La ruta debe ser relativa a donde Rswag::Api::Engine está montado
  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'Balconcito Admin API V1'

  # Configuración de UI
  c.config_object = {
    # Habilitar "Try it out" para probar endpoints
    tryItOutEnabled: true,
    # Mostrar modelos
    defaultModelsExpandDepth: 2,
    # Mostrar ejemplos
    defaultModelExpandDepth: 2,
    # Profundidad de expand
    docExpansion: 'list',
    # Filtro de búsqueda
    filter: true,
    # Mostrar extensiones de vendor
    showExtensions: true,
    # Mostrar headers comunes
    showCommonExtensions: true,
    # Validación de specs
    validatorUrl: nil
  }
end
