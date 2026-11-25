
class ReportValidators {
  static String? validarTitulo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el título del reporte.';
    }

    return null;
  }

  static String? validarDescripcion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Describe el problema.';
    }

    return null;
  }

  static String? validarCategoria(
    String? value,
    List<String> categorias,
  ) {
    if (value == null || !categorias.contains(value)) {
      return 'Selecciona una categoría.';
    }

    return null;
  }
}
