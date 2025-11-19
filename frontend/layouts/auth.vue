<template>
  <div class="min-h-screen bg-gradient-to-br from-green-50 to-green-100 flex items-center justify-center px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-green-600 mb-2">🍺 Balconcito ERP</h1>
        <p class="text-gray-600">Sistema de Administración Centralizado</p>
      </div>
      
      <div class="bg-white py-8 px-6 shadow-lg rounded-lg">
        <slot />
      </div>
    </div>
  </div>
</template>
