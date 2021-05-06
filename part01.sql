/*
 * Comandos SQL/T-SQL
 */

/*
 * (SQL) USE: Utilizado quando você está trabalhando com scripts e precisar rodá-lo 
 * em vários databases.
 */
	USE master;

	USE eBook;

/*
 * db_name(): Retorna o nome do database que está sendo utilizado
 */
	SELECT db_name();

/*
 * (SSMS) GO: indica o fim de execução de um bloco de comando.
 * Se houver erro de execução, ele retorna a mensagem de erro, e segue para o 
 * próximo comando.
 */

 /*
  * Exemplo 1:
  */
	USE eBook;
	GO;

 /*
  * Exemplo 2:
  */
	SELECT COUNT(1) FROM tCADCliente;
	SELECT MAX(iidPedido) FROM tMOVPedido;
	GO

/*
 * Erro de execução:
 */
	SELECT * FROM tTabelaNaoExiste;
	GO
	
	SELECT SUM(mValor) FROM tMOVNotaFiscal;
	SELECT TOP 1 * FROM tCADLivro;
	GO

/*
 * Utilizando GO com o parâmetro de quantidade de execuções 
 */
	SELECT getdate()
	GO 2

/*
 * Inserção em batch
 */
	DROP TABLE IF EXISTS people
	CREATE TABLE people (id int, name varchar(50))
	GO

	INSERT INTO people (id, name) VALUES (RAND()*1000, NEWID())
	GO 200

	SELECT * FROM people;

/*
 * Script para monitorar o uso da memória 
 */
	DROP TABLE IF EXISTS memory_monitoring
	CREATE TABLE memory_monitoring (
	   dData DATETIME DEFAULT GETDATE(),
	   size DECIMAL(10,6)
	)
	GO

	INSERT INTO memory_monitoring (size)
	SELECT COUNT(1)*8096/1024.0/1024.0 FROM sys.dm_os_buffer_descriptors
	WAITFOR DELAY '00:00:10'
	GO 10

	SELECT * FROM memory_monitoring;

/*
 * EXECUTE: utilizada para a execução de Stored Procedures e 
 * Instruções Dinâmicas.
 */


/*
 * Stored Procedure 
 */ 
	USE eBook
	GO

	EXECUTE sp_helpdb

	EXECUTE stp_UltimoPedido

/* 
 * No SSMS é possível executar as procedure ssem a instrução EXECUTE, porém,
 * apenas separadamente.
 */

/*
 * FORMA ERRADA:
 */
	sp_helpdb
	stp_UltimoPedido

/*
 * FORMAS CORRETAS:
 */

/*
 * 1ª Procedure:
 */
	sp_helpdb
	
/*
 * 2ª Procedure:
 */
	stp_UltimoPedido

/* 
 * Ou, utilizando o comando GO. Mas por questões de boas práticas, sempre 
 * utilizar o EXECUTE para executar Stored Procedures.
 */
	sp_helpdb
	GO
	stp_UltimoPedido
	GO

/*
 * Instrução Dinâmica: quando crio um comando DML de forma que no decorrer 
 * da criação é colocado claúsulas dentro da montagem do comando.
 */
	DECLARE @cTabela char(20) = 'tCADCliente'
	EXECUTE ('SELECT * FROM ' + @cTabela )
	GO

	DECLARE @cTabela char(20) = 'tCADLivro'
	EXECUTE ('SELECT * FROM ' + @cTabela )
	GO

/*
 * Alterando os nomes das colunas de um resultado
 */
	DECLARE @cTabela char(20) = 'tCADCliente'
	EXECUTE ('SELECT iidCliente, cNome  FROM ' + @cTabela + 
			 ' ORDER BY iidCliente ASC')
	WITH result SETS
	(
	  (ID INT NOT NULL,  
	   Cliente VARCHAR(150) NOT NULL  
	  )
	);  
