
import 'package:flutter_test/flutter_test.dart';
import 'package:reportes_ciudadanos/utils/report_validators.dart';

void main() {
  group('Pruebas de validación de reportes', () {
    const categorias = [
      'Bache',
      'Basura',
      'Alumbrado público',
      'Otro',
    ];

    test('Rechaza un título vacío', () {
      // Arrange
      const titulo = '';

      // Act
      final resultado = ReportValidators.validarTitulo(titulo);

      // Assert
      expect(resultado, 'Ingresa el título del reporte.');
    });

    test('Rechaza un título con espacios', () {
      // Arrange
      const titulo = '     ';

      // Act
      final resultado = ReportValidators.validarTitulo(titulo);

      // Assert
      expect(resultado, 'Ingresa el título del reporte.');
    });

    test('Acepta un título válido', () {
      // Arrange
      const titulo = 'Bache en la calle principal';

      // Act
      final resultado = ReportValidators.validarTitulo(titulo);

      // Assert
      expect(resultado, 'Este resultado debe fallar');
    });

    test('Rechaza una descripción vacía', () {
      // Arrange
      const descripcion = '';

      // Act
      final resultado =
          ReportValidators.validarDescripcion(descripcion);

      // Assert
      expect(resultado, 'Describe el problema.');
    });

    test('Acepta una descripción válida', () {
      // Arrange
      const descripcion = 'Existe un bache frente a la plaza.';

      // Act
      final resultado =
          ReportValidators.validarDescripcion(descripcion);

      // Assert
      expect(resultado, isNull);
    });

    test('Rechaza una categoría que no existe', () {
      // Arrange
      const categoria = 'Electricidad';

      // Act
      final resultado =
          ReportValidators.validarCategoria(categoria, categorias);

      // Assert
      expect(resultado, 'Selecciona una categoría.');
    });

    test('Acepta una categoría válida', () {
      // Arrange
      const categoria = 'Basura';

      // Act
      final resultado =
          ReportValidators.validarCategoria(categoria, categorias);

      // Assert
      expect(resultado, isNull);
    });
  });
}
