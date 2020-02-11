--Select * from [dbo].[Cliente]
--Select * from [dbo].[Cuenta]
--select * from Movimientos
/*
Ejemplo sin transacciones, con resultado exitoso
*/
DECLARE @monto DECIMAL(18,2),
     	@CuentaOrigen VARCHAR(12),
		@CuentaDestino VARCHAR(12)

/* Asignamos el importe de la transferencia
* y las cuentas de origen y destino
*/

SET @monto = 290 
SET @CuentaOrigen  = '44-0004-4'
SET @CuentaDestino = '11-0001-1'

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