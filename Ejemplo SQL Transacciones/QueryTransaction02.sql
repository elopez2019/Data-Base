--Select * from [dbo].[Cliente]
--Select * from [dbo].[Cuenta]
--select * from Movimientos
/*
  Ejemplo con transacciones, error inesperado regresando a un estado original
*/


DECLARE @monto DECIMAL(18,2),
     	@CuentaOrigen VARCHAR(12),
		@CuentaDestino VARCHAR(12)

	
/* Asignamos el importe de la transferencia
* y las cuentas de origen y destino
*/

SET @monto = 290 
SET @CuentaOrigen  = '11-0001-1'
SET @CuentaDestino = '44-0004-4'

BEGIN TRANSACTION -- O solo BEGIN TRAN
BEGIN TRY
			/* Descontamos el importe de la cuenta origen */
			UPDATE Cuenta SET Saldo = Saldo - @monto
			WHERE Id_Cuenta = @CuentaOrigen

			/* Registramos el movimiento */
			INSERT INTO [dbo].[Movimientos]
					   ([Id_Cuenta]
					   ,[Saldo_Inicial]
					   ,[Saldo_Final]
					   ,[Monto]
					   ,[Fecha_Mov]
					   ,[Id_TipoMov])
			SELECT Id_Cuenta, (SALDO + @monto), SALDO, @monto, getdate(), 1
			FROM Cuenta 
			WHERE Id_Cuenta = @CuentaOrigen


			/* Incrementamos el importe de la cuenta destino */
			UPDATE Cuenta 
			SET Saldo = Saldo + @monto
			WHERE Id_Cuenta = @CuentaDestino


			/* Registramos el movimiento */
			INSERT INTO [dbo].[Movimientos]
					   ([Id_Cuenta]
					   ,[Saldo_Inicial]
					   ,[Saldo_Final]
					   ,[Monto]
					   ,[Fecha_Mov]
					   ,[Id_TipoMov])
			SELECT Id_Cuenta, (Saldo - @monto), Saldo, @monto, getdate(), 2
			FROM Cuenta 
			WHERE Id_Cuenta = @CuentaDestino
		/* Confirmamos la transaccion*/ 
COMMIT TRANSACTION -- O solo COMMIT
END TRY

BEGIN CATCH
	/* Hay un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION -- O solo ROLLBACK
	PRINT 'Se ha producido un error! ' + CONVERT(VARCHAR,ERROR_NUMBER()) + ' MSG: ' + ERROR_MESSAGE()
END CATCH
