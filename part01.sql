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
 * No SSMS é possível executar as procedure sem a instrução EXECUTE, porém,
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

/*
 * SELECT/PRINT/Raiserror(): para emitir uma mensagem no meio da execução 
 * de um script para apresentar informações para quem executou a instruções.
 *
 * - Debugar; Gerar um erro ou exceção; Emitir avisos ou informações.
 */

 /*
  * SELECT
  */
	 USE eBook
	 GO

	 SELECT 'Commands completed successfully 1.' AS Test

	 SELECT TOP 1 * FROM tCADCliente
	 SELECT 'Commands completed successfully 2.'

 /*
  * PRINT
  */
	PRINT'Commands completed successfully 3.'

	SELECT TOP 1 * FROM tCADCliente
	PRINT 'Commands completed successfully 4.'


	SET NOCOUNT ON
	SELECT TOP(CAST(RAND()*100 AS INT)) * FROM tCADCliente
	PRINT 'O comando executou '+ CAST(@@ROWCOUNT AS VARCHAR(10))+ ' linhas.'

/*
 * PROBLEMA: valores nulos não são apresentados; há delay para o envio dos dados
 * na tela, pois ele envia os dados para um buffer e posteriormente para o console.
 */

/*
 * NULL
 */
	PRINT 'Teste 01'
	PRINT 'Teste 02 com nulo ' + NULL

/*
 * DELAY
 */
	PRINT 'Command' WAITFOR DELAY '00:00:05' 
	GO 2
	
/*
 * RAISERROR(): Função interna - utilizada para gerar uma exceção no fluxo de 
 * execução de um script ou objeto de programação.
 */

 /*
 * Parâmetro 10 indica que a tratativa da mensagem será apenas como uma
 * informação, e o 1, é devido não poder ser nulo.
 */

	RAISERROR('Successfully', 10, 1)
	
/*
 * COMPARAÇÕES: PRINT x RAISERROR()
 */
	PRINT 'Command' WAITFOR DELAY '00:00:05' 
	GO 2

/*
 * BOAS PRÁTICAS: utilizar com WITH NOWAIT para apresentar mensagens de aviso 
 * ou uma informação diretamente para quem está executando, sem passar pelo buffer.
 */
	RAISERROR('Successfully', 10, 1) WITH NOWAIT
	WAITFOR DELAY '00:00:10'
	GO 2

/*
 * @@ROWCOUNT: função de sistema que armazena o montante total de linhas que
 * foram processadas pela última instrução (utilização para teste de verificação
 * se a tabela foi afetada conforme as condições do WHERE).
 */
	SELECT * FROM tCADCliente WHERE iIDCliente >= 134
	SELECT @@ROWCOUNT

/*
 * SELECT 'Texto' ou SET, o valor de @@rowcount é sempre 1
 */
	SELECT 'Teste de instrução @@rowcount'
	SELECT @@ROWCOUNT

/*
 * Resultado de UPDATE's 
 */
	UPDATE tCADLivro SET nPaginas += 1 WHERE iIDDestaque = 1
	SELECT @@ROWCOUNT

/*
 * ROWCOUNT_BIG() - retorna BIGINT, seu range é maior do que o ROWCOUNT e 
 * pode armazenar quantidade de linhas processada até o valor de 9,2 quintilhões. 
 * Utilizada quando já processou mais de 2 bilhões de linhas e precisa saber
 * se ele realmente processou tudo.
 */
	UPDATE tCADLivro SET nPaginas = nPaginas + 1 WHERE iIDDestaque = 1
	SELECT @@ROWCOUNT AS row_count, ROWCOUNT_BIG() AS row_count_big

/*
 * SEQUENCE: gerador de números sequenciais (número independente de qualquer 
 * tabela, coluna) como um IDENTITY. A definição do sequenciador é feita para 
 * a instrução CREATE SEQUENCE e o retorno de um valor numérico com a próxima 
 * sequência da numeração é feita pelo comando NEXT VALUE.
 */

 /*
  * Criando o SEQUENCE
  */
	DROP SEQUENCE IF EXISTS NotaFiscal
	CREATE SEQUENCE NotaFiscal 
		AS INT 
		START WITH 1
		INCREMENT BY 1

/*
 * Obtém o próximo valor da sequência
 */
	SELECT NEXT VALUE FOR NotaFiscal

/*
 * Reinicia a sequência
 */
	ALTER SEQUENCE NotaFiscal RESTART

	SELECT NEXT VALUE FOR NotaFiscal

/*
 * SEQUENCE na criação de tabelas
 */
	DROP SEQUENCE IF EXISTS seqIDPessoa
	GO

	CREATE SEQUENCE seqIDPessoa 
		   AS INT
		   START WITH 1 
		   INCREMENT BY 1
	GO

	ALTER SEQUENCE seqIDPessoa RESTART

	DROP TABLE tTMPPessoas 
	GO

	CREATE TABLE tTMPPessoas (
		iIDPessoa INT NOT NULL DEFAULT(NEXT VALUE FOR seqIDPessoa) PRIMARY KEY,
		cNome VARCHAR(100) NOT NULL
	)
	GO

	INSERT INTO tTMPPessoas (cNome) VALUES ('Jose da Silva')
	GO

	SELECT * FROM tTMPPessoas

/*
 * SEQUENCE direto no comando INSERT
 */

	INSERT INTO tTMPPessoas (iIDPessoa, cNome) 
	VALUES (NEXT VALUE FOR seqIDPessoa, 'Maria da Silva')
	GO

	SELECT * FROM tTMPPessoas

/*
 * SEQUENCE ante de executar o INSERT 
 */

	DECLARE @iidPessoa INT
	SET @iidPessoa = NEXT VALUE FOR seqIDPessoa 

	INSERT INTO tTMPPessoas (iIDPessoa, cNome) 
	VALUES (@iidPessoa, 'Joaquim Gomes')
	GO

	SELECT * FROM tTMPPessoas 

/*
 * Consultar as informações do SEQUENCE (SQL) numa view no sistema
 */
	SELECT * FROM sys.sequences
	WHERE NAME = 'seqIDPessoa'

/* @@ERROR: Função de sistema que retorna o número do erro que foi gerado 
 * na última instrução T-SQL que apresentou erro. O retorno será de um número INT.
 * Todo o erro deve ser capturado, tratado e, preferencialmente armazenamento para 
 * posterior análise.
 */
	PRINT @@ERROR

	SELECT 2/2
	PRINT @@ERROR

	SELECT 2/0
	PRINT @@ERROR

	SELECT 1/2.0
	PRINT @@ERROR

/* O valor de @@ERROR é zero automaticamente antes de executar a próxima 
 * instrução T-SQL.
 */

	DECLARE @nNumeroError_A INT 
	DECLARE @nNumeroError_B INT 

	SELECT 2/0
	SET @nNumeroError_A = @@ERROR  -- Captura o erro na variável e zera o valor de @@ERROR
	SET @nNumeroError_B = @@ERROR

	PRINT 'Erros....'
	PRINT @nNumeroError_A 
	PRINT @nNumeroError_B 

/*
 * SET NOCOUNT ON: utilizado na fase de programação para evitar esse trânsito de 
 * dados na rede e, de alguma forma, reduzir o tempo de processamento das instruções. 
 */

/*
 * SET NOCOUNT OFF
 */
	SET NOCOUNT OFF

	UPDATE tCADCliente SET mCredito = mCredito + 10 
	WHERE dAniversario <= '1950-01-01'
	
	UPDATE tCADCliente SET mCredito = mCredito - 10 
	WHERE dAniversario <= '1950-01-01'
	
	UPDATE tMOVPedido SET mDesconto = mDesconto +10 
	WHERE dPedido >= '2018-09-01'
	
	UPDATE tMOVPedido SET mDesconto = mDesconto -10 
	WHERE dPedido >= '2018-09-01'
	
	GO 100

/*
 * SET NOCOUNT ON
 */
	SET NOCOUNT ON

	UPDATE tCADCliente SET mCredito = mCredito + 10 
	WHERE dAniversario <= '1950-01-01'
	
	UPDATE tCADCliente SET mCredito = mCredito - 10 
	WHERE dAniversario <= '1950-01-01'
	
	UPDATE tMOVPedido SET mDesconto = mDesconto +10 
	WHERE dPedido >= '2018-09-01'
	
	UPDATE tMOVPedido SET mDesconto = mDesconto -10 
	WHERE dPedido >= '2018-09-01'

	GO 100
	
