/* TRANSAÇÃO: Verdadeiro E Verdadeiro, se não, falso.
 * Unidade atomica: nã se divide, tudo deve ser realizada com sucesso ou não 
 * tudo dentro dela e colocar pra processar, tudo tem que ser concluido com sucesso.
 *
 * Uma transação pode ser definida como uma unidade lógica de trabalho.
 *
 * Se tudo que está dentro dessa unidade lógica de trabalho for feita com sucesso, 
 * os dados serão persistidos no banco de dados de forma permanente.
 *
 * Se algo ocorrer de errado e a unidade lógica de trabalho é inválida, todas 
 * as modIFicação feitas desde o início do trabalho serão desfeitas e os 
 * dados ficam persistidos igualmente antes do início do trabalho. 
 *
 * - Toda a transação deve ter as quatro propriedade conhecidas como  ACID
 *
 *	Atomicidade  - A transação é indivisível;
 *	Consistência - A transação deve manter consistência do dados;
 *	Isolamento   - O que ocorre em uma transção não INTerfere em outra transação;
 *	Durabilidade - Uma vez a transação confirmada, o dados são persistidos e o 
 *				   armazenamento é permanente.
 *
 *
 * Log de transação:
	- Um dos arquivos de banco de dados que registra tudo que ocorrer dentro de 
	  uma transação.
	- As instruções são gravadas sequencialmente para cada transação.
	- Se precisar realizar algum procedimento de recuperação como desfazer 
	  uma transação ou recuperar o banco no processo de Restore, o Log de transação 
	  é utilizado. 
 */

	SELECT 
			file_id, 
		    type_DESC, 
		    name, 
		    physical_name, 
		    size*8/1024.0 AS sizeMB 
	  FROM sys.master_files 
	  WHERE database_id = DB_ID()

/* Básico
 *	BEGIN TRANSACTION:
 *	- Marca o início da unidade lógica de trabalho. 
 *	- Tudo que é realizado na modIFicação dos dados são controlado pela transação.
 *
 *	COMMIT TRANSACTION:
 *	- Confirma que a unidade lógica de trabalho foi concluída com sucesso. 
 *	- Os dados modIFicados são persistido na base de dados. 
 *
 *	ROLLBACK TRANSACTION:
 *	- Cancela tudo que foi modIFicado na unidade lógica de trabalho, voltANDo os dados 
 *	  ao status antes de iniciar a transação. 
 *
 *	Observação:
 *	- Você como o desenvolvedor e conhecedor das regras aplicadas no código,
 *	  deve saber onde começa a sua unidade de trabalho e onde ela termina. 
 */

/* 
 * Exemplos 
 */

/*
 * UtilizANDo COMMIT 
 */
	SELECT 
			iIDLivro, 
			cTitulo, 
			nPaginas, 
			nPeso 
	FROM tCADLivro
	WHERE iIDLivro = 1 

/*
 * Marca inicio da transação 
 */
	BEGIN TRANSACTION
		UPDATE tCADLivro 
		SET nPaginas = 600 
		WHERE iIDLivro = 1 

/*
 * Confirma a transação
 */
	COMMIT 

	SELECT 
			iIDLivro, 
			cTitulo, 
			nPaginas, 
			nPeso 
	FROM tCADLivro
	WHERE iIDLivro = 1 

/*
 * UtilizANDo ROLLBACK 
 */

/* 
 * Marca inicio da transação 
 */
	BEGIN TRANSACTION
		UPDATE tCADLivro 
		SET nPaginas = 0 
		WHERE iIDLivro = 1 

/*
 * Cancela a transação
 */
	ROLLBACK 

	SELECT iIDLivro, cTitulo, nPaginas, nPeso 
	FROM tCADLivro
	WHERE iIDLivro = 1 

/*
 * Famoso UPDATE SEM WHERE 
 */

/* 
 * Marca inicio da transação 
 */
	BEGIN TRANSACTION
		UPDATE tCADLivro 
		SET nPaginas = 0,
			cTitulo = 'Cem anos de Guerra'
		
		SELECT 
				iIDLivro, 
				cTitulo, 
				nPaginas, 
				nPeso 
		FROM tCADLivro
    

/*
 * Cancela a transação
 */
	ROLLBACK 

	SELECT 
			iIDLivro, 
			cTitulo, 
			nPaginas, 
			nPeso 
	FROM tCADLivro

/*
 * Rotina que faz um pedido, atualiza o estoque e o crédito do cliente. 
 */
	DECLARE @iidCliente INT = 8834	
	DECLARE @iidLivro INT = 106		
	DECLARE @iidLoja INT = 9		
	DECLARE @nQuantidade INT = 1	
	DECLARE @iIDPedido INT			
	DECLARE @mValor SMALLMONEY		

	BEGIN 

/*
 * Recupera qual o valor do livro de uma determinada loja
 */
	   SELECT @mValor = mValor 
	   FROM tRELEstoque 
	   WHERE iIDLivro = @iidLivro 
	   AND iIDLoja = @iidLoja 
    
	   RAISERROR('Incluindo Pedido...',10,1) WITH NOWAIT; 
   
/*
 * Recupera o próximo número de pedido
 */
	   SELECT @iIDPedido = NEXT VALUE FOR seqIDPedido;

	   BEGIN TRANSACTION 

/*
 * Insere o cabeçalho do pedido
 */
	   INSERT INTO dbo.tMOVPedido           
	   (iIDPedido ,iIDCliente,iIDLoja,iIDENDereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDESConto)
	   VALUES
	   (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(), DATEADD(d,15,GETDATE()),DATEADD(d,10,GETDATE()),null,587885,5)

	   RAISERROR('Incluindo item de pedido...',10,1) WITH NOWAIT 
   
/*
 * Inseri o item do pedido
 */
	   INSERT INTO tMOVPedidoItem (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDESConto)
	   VALUES (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)

	   RAISERROR('Atualizando estoque do livro...',10,1) WITH NOWAIT 

/*
 * Atualiza o saldo do estoque do livro para a loja
 */   
	   UPDATE tRELEstoque 
	   SET nQuantidade = (nQuantidade - @nQuantidade)
	   WHERE iIDLivro = @iidLivro 
	   AND iIDLoja = @iidLoja 

	   RAISERROR('AtualizANDo Crédito de Cliente...',10,1) WITH NOWAIT 
/*
 * Atualiza o crédito do cliente
 */   
	   UPDATE tCADCliente 
	   SET mCredito = (mCredito - @mValor)
	   WHERE iIDCliente = @iidCliente

/* 
 * COMMIT 
 * ROLLBACK
 */
	END 
/*
 * Finaliza a Operacação.
 */

/* Dicas:
 * - Transações curtas;
 * - Comando que não afetam transações, manter fora da transação. 
 */

/* @@TRANCOUNT: Use essa função de sistema para controlar se existe transação 
 * aberta e quantas transações atualmente estão abertas na conexão/sessão atual.
 *
 * @@TRANCOUNT retorna um número INTeiro com a quantidade de transação.
 *
 * Se 0, não tem transação aberta. Se maior ou igual a 1, indica que tem 
 * transação aberta e o número indica a quantidade de transações em aberto. 
 *
 * Vamos usar também a função @@ERROR para controlar o COMMIT e o ROLLBACK.
 */

/*
 * Exemplo de BEGIN TRANSACTION e COMMIT 
 */
	BEGIN TRANSACTION 
	SELECT @@TRANCOUNT

	BEGIN TRANSACTION 
	SELECT @@TRANCOUNT

	BEGIN TRANSACTION 
	SELECT @@TRANCOUNT

	COMMIT 
	SELECT @@TRANCOUNT

	COMMIT 
	SELECT @@TRANCOUNT

	COMMIT 
	SELECT @@TRANCOUNT

	IF @@TRANCOUNT > 0 COMMIT 

/* Dica: Antes de realizar um COMMIT ou ROLLBACK, verifique se existe 
 * transações abertas. 
 */

/*
 * Exemplo de BEGIN TRANSACTION e ROLLBACK 
*/
	BEGIN TRANSACTION 
	SELECT @@TRANCOUNT

	BEGIN TRANSACTION 
	SELECT @@TRANCOUNT

	BEGIN TRANSACTION 
	SELECT @@TRANCOUNT

	ROLLBACK
	SELECT @@TRANCOUNT

	IF @@TRANCOUNT > 0 ROLLBACK

/*
 * Exemplo da utilização do @@TRANCOUNT para controlar a execução do fluxo
 * do processo de confirmar ou reverter uma transação.
 */

/*
 * Vamos simular um erro com esse Comando
 */
	DELETE FROM tCADLivro 
	WHERE iIDLivro= 137

/*
 * Exemplo 
 */
	DECLARE @nNumeroError INT 

	BEGIN 
	   BEGIN TRANSACTION
		   UPDATE tCADCliente 
		   SET mCredito = 100 
		   WHERE iidcliente = 34
   
		   UPDATE tCADLivro 
		   SET nPaginas = 100 
		   WHERE iIDLivro = 137

/*
 * Aqui vai ocorrer um erro
 */
		   DELETE FROM tCADLivro 
		   WHERE iIDLivro= 137
   
		   SET @nNumeroError = @@ERROR

		   IF @@TRANCOUNT > 0 AND @nNumeroError > 0 BEGIN
			  RAISERROR('DesFazendo. Código do erro gerado %d',10,1,@nNumeroError) 
			  ROLLBACK
		   END

		   IF @@TRANCOUNT > 0 AND @nNumeroError = 0 BEGIN
			  RAISERROR('ConfirmANDo',10,1)
			  COMMIT
	   END 
	END 

/*
 * Rotina que faz um pedido, atualiza o estoque e o crédito do cliente
 */
	DECLARE @iidCliente INT = 8834	
	DECLARE @iidLivro INT = 106		
	DECLARE @iidLoja INT = 9		
	DECLARE @nQuantidade INT = 1	 
	DECLARE @iIDPedido INT			
	DECLARE @mValor SMALLMONEY		
	DECLARE @nNumeroError INT 

	BEGIN 
/*
 * Recupera qual o valor do livro de uma determinada loja
 */
		SELECT @mValor = mValor 
		FROM tRELEstoque 
		WHERE iIDLivro = @iidLivro 
		AND iIDLoja = @iidLoja 
    
	   RAISERROR('Incluindo Pedido...',10,1) WITH NOWAIT; 
   
/*
 * Recupera o próximo número de pedido
 */
	   SELECT @iIDPedido = NEXT VALUE FOR seqIDPedido;

	   BEGIN TRANSACTION 

/*
 * Inseri o cabeçalho do pedido
 */
	   INSERT INTO dbo.tMOVPedido           
	   (iIDPedido ,iIDCliente,iIDLoja,iIDENDereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDESConto)
	   VALUES (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,GETDATE()),DATEADD(d,10,GETDATE()),null,587885,5)
   
	   SET @nNumeroError = @@ERROR
   
	   RAISERROR('Incluindo item de pedido...',10,1) WITH NOWAIT 
   
/*
 * Inseri o Item do pedido
 */
	   INSERT INTO tMOVPedidoItem (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDESConto)
	   VALUES (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)
   
	   SET @nNumeroError = @@ERROR

	   RAISERROR('Atualizando estoque do Livro...',10,1) WITH NOWAIT 
/*
 * Atualiza o saldo do estoque do livro para a loja
 */
	   UPDATE tRELEstoque 
	   SET nQuantidade = nQuantidade - @nQuantidade 
	   WHERE iIDLivro = @iidLivro 
	   AND iIDLoja = @iidLoja 

	   SET @nNumeroError = @@ERROR

	   RAISERROR('Atualizando crédito de cliente...',10,1) WITH NOWAIT 

/* 
 * Atualiza o crédito do cliente
 */
	   UPDATE tCADCliente 
	   SET mCredito = mCredito - @mValor 
	   WHERE iIDCliente = @iidCliente
	
	   SET @nNumeroError = @@ERROR

/*
 * Primeiro teste, tem transação aberta? 
 */
	   IF @@TRANCOUNT > 0 
/*
 * Ocorreu um erro? Não, então confirma
 */
		  IF @nNumeroError = 0 BEGIN 
			 COMMIT 
			 RAISERROR('Confirmando.',10,1) 
		  END 
/*
 * Sim, então desfaz
 */
		  ELSE BEGIN 
			 ROLLBACK 
			 RAISERROR('DesFazendo. Código do erro gerado %d',10,1,@nNumeroError) 
		  END 
	END 

/*
 * Finaliza a operacação
 */

/* Transações aninhadas:
 *	- Quando temos uma transação dentro de outra transação;
 *	- Você deve controlar a execução do BEGIN TRANSACTION;
 *	- COMMIT ou ROLLBACK pela função @@TRANCOUNT.
 */

/*
 * Exemplo 01 - Usandoo BEGIN TRANSACTION e COMMIT 
 */
	SELECT @@TRANCOUNT
	BEGIN 
	   BEGIN TRANSACTION 
		  --Comando C1 
		  BEGIN TRANSACTION 
			-- Comando C2 
			 BEGIN TRANSACTION 
				-- Comando C3 
				 -- Comando C4 
				 -- Comando C5
			 COMMIT 
			 -- Comando C6
		  COMMIT 
		  -- Comando C7
	   COMMIT 
	END
	IF @@TRANCOUNT > 0
	   COMMIT 

	SELECT @@TRANCOUNT
 
/*
 * Exemplo 02 - Usandoo de BEGIN TRANSACTION e ROLLBACK 
 */
	SELECT @@TRANCOUNT
	BEGIN 
	   BEGIN TRANSACTION
		  --Comando C1
		  BEGIN TRANSACTION
			-- Comando C2 
			 BEGIN TRANSACTION 
   			-- Comando C3 
				-- Comando C4 
				-- Comando C5 
			 ROLLBACK 
			 -- Comando C6
		  ROLLBACK 
		  -- Comando C7 
	   ROLLBACK 
	END
	SELECT @@TRANCOUNT


/*
 * Fazendo o controle do ROLLBACK 
 */
	SELECT @@TRANCOUNT
	BEGIN 
	   BEGIN TRANSACTION
		  --Comando C1
		  BEGIN TRANSACTION
			-- Comando C2 
			 BEGIN TRANSACTION 
   			 -- Comando C3 
				 -- Comando C4 
				 -- Comando C5 
			 IF @@TRANCOUNT > 0 ROLLBACK 
			 -- Comando C6
		  IF @@TRANCOUNT > 0 ROLLBACK 
		  -- Comando C7 
	   IF @@TRANCOUNT > 0 ROLLBACK 
	END
	SELECT @@TRANCOUNT

/* Exemplo 03 - Usando BEGIN TRANSACTION, COMMIT e  ROLLBACK 
 * Não ocorre o erro.
 */
	SELECT @@TRANCOUNT
	BEGIN 
	   BEGIN TRANSACTION
		  --Comando C1
		  BEGIN TRANSACTION
			-- Comando C2 
			 BEGIN TRANSACTION 
				-- Comando C3
				 -- Comando C4
				 -- Comando C5
			 COMMIT 
			 -- Comando C6
		  COMMIT 
		  -- Comando C7
	   ROLLBACK 
	END 
	SELECT @@TRANCOUNT

/* Exemplo de BEGIN TRANSACTION, COMMIT e  ROLLBACK 
 * Ocorre o erro.
 */
	SELECT @@TRANCOUNT
	BEGIN 
	   BEGIN TRANSACTION
		  --Comando C1
		  BEGIN TRANSACTION
			 -- Comando C2 
			 BEGIN TRANSACTION 
				-- Comando C3
				-- Comando C4
				-- Comando C5
			 COMMIT 
			 -- Comando C6
		  ROLLBACK  
		  -- Comando C7
	   COMMIT 
	END 
	SELECT @@TRANCOUNT

/*
 *
 */
	UPDATE tMOVNotaFiscal 
	SET mValorICMS = 10  
	WHERE iIDNotaFiscal = 1

	SELECT 
			mValorICMS 
	FROM tMOVNotaFiscal 
	WHERE iIDNotaFiscal = 1
 
	BEGIN TRANSACTION 
	   UPDATE tMOVNotaFiscal SET mValorICMS += 1  WHERE iIDNotaFiscal = 1
	   BEGIN TRANSACTION
		  UPDATE tMOVNotaFiscal SET mValorICMS += 1  WHERE iIDNotaFiscal = 1
 		   BEGIN TRANSACTION 
			  UPDATE tMOVNotaFiscal SET mValorICMS += 1  WHERE iIDNotaFiscal = 1
			   UPDATE tMOVNotaFiscal SET mValorICMS += 1  WHERE iIDNotaFiscal = 1
			   UPDATE tMOVNotaFiscal SET mValorICMS += 1  WHERE iIDNotaFiscal = 1
		   COMMIT 
		   UPDATE tMOVNotaFiscal SET mValorICMS += 1  WHERE iIDNotaFiscal = 1

	   IF @@TRANCOUNT > 0
		  ROLLBACK 

	   UPDATE tMOVNotaFiscal SET mValorICMS += 1  WHERE iIDNotaFiscal = 1

	IF @@TRANCOUNT > 0
	   COMMIT 

	SELECT 
			mValorICMS 
	FROM tMOVNotaFiscal 
	WHERE iIDNotaFiscal = 1

/* Bloqueios ou Lock:
	- Quando um conexão bloqueia recursos durante uma transação 
	  e outras conexões ou sessões não consegue acessar o mesmo recurso;
	- Para demonstrar o bloqueio, temos que abriar duas sessões do SSMS.

	https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-AND-row-versioning-guide?view=sql-server-2014#Lock_Engine
 */

/* 
 * Hide Solution Explorer e Object Explorer 
 */
	UPDATE tCADCliente 
	   SET mCredito = 1
	 WHERE iIDCliente = 1 

/*
 * Conexão 1 
 */
	SELECT @@SPID

	SELECT mCredito
	  FROM tCADCliente
	 WHERE iIDCliente = 1 

	BEGIN TRANSACTION

	UPDATE tCADCliente 
	   SET mCredito = 2
	 WHERE iIDCliente = 1 

	SELECT @@TRANCOUNT

	ROLLBACK

/*
Abrir um outra sessão e copiar o código abaixo 
*/
	SELECT @@SPID
	go

	UPDATE tCADCliente 
	   SET mCredito = 1
	 WHERE iIDCliente = 1 

/*
VisualizANDo os bloqueios e os recursos 
bloqueado e os com a INTenção de bloqueio.
*/
	SELECT 
			resource_type AS TYPE, 
			request_mode AS mode,
			request_type AS request,
		    request_status AS status,
			request_session_id AS session,
			CASE WHEN resource_type = 'OBJECT' 
				 THEN object_name(resource_associated_entity_id)
			END AS OBJECT,
		   resource_DESCription
	 FROM sys.dm_tran_locks 
	 WHERE request_session_id in (75,59) -- Ajustar esses SPID para seu cenário.
	 ORDER BY request_session_id

/*
 * https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-AND-row-versioning-guide?view=sql-server-2014#lock-granularity-AND-hierarchies
 */

/* Bloqueio e Recursos:
 *	O engine do SQL Server decide a melhor forma de realizar um "bloqueio"
 *	em um "recurso". Isso para garantir a eficiência da transação versus a sobrecarga
 *	de recursos de hardware e o do SQL Server.
 *	
 *	Um bloqueio pode ser feito de várias formas que chamamos de "Modo de Bloqueio".
 *
 *	- Quando ele realiza um bloqueio de um recurso qualquer, esse bloqueio é chamado de 
 *	bloqueio exclusivo e é representado pela letra X. A sessão que realiza o bloqueio
 *	detêm o bloqueio do recurso e outra sessão não pode solicitar o bloqueio do mesmo 
 *	recurso.
 */
	BEGIN TRANSACTION

	UPDATE tCADCliente 
	SET mCredito = 100
	WHERE iIDCliente = 1 -- A coluna é um chave primária, o recurso será KEY.
 
	SELECT 
			resource_type AS TYPE , 
			request_mode as mode,
			request_type as request,
			request_status as status,
			request_session_id as session,
			CASE WHEN resource_type = 'OBJECT' 
				 THEN object_name(resource_associated_entity_id)
			END AS OBJECT,
			resource_DESCription
	 FROM sys.dm_tran_locks 
	 WHERE request_session_id = @@SPID
	 ORDER BY request_session_id, resource_type

	ROLLBACK 
	GO

/* Quando um operação de leitura é realizada, a sessão tenta obter um 
 *  bloqueio compartilhado representado pela letra S. A sessão que realiza o bloqueio
 *  detêm o bloqueio do recurso e outra sessão pode solicitar somente bloqueio compartilhados
 *  ou com INTenção de bloqueio
 */

/* Executar esse SELECT em outra sessão. Pegar o SPID 
 * da outra sessão para colocar no SELECT abaixo.
 */
	SELECT * FROM tMOVPedidoItem

	SELECT 
			resource_type AS TYPE , 
		    request_mode as mode,
			request_type as request,
		    request_status as status,
			request_session_id as session,
			CASE WHEN resource_type = 'OBJECT' 
				  THEN object_name(resource_associated_entity_id)
			END AS OBJECT,
		   resource_DESCription
	 FROM sys.dm_tran_locks 
	 WHERE request_session_id = 54
	 ORDER BY TYPE

/* Os recursos:
	Podemos dizer que os recursos são as unidades de alocação do dados que podem
	sofrer algum tipo de bloqueio. 

	Abaixo temos a hierarquia do recursos do menor até o maior 

	Link : https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-AND-row-versioning-guide?view=sql-server-2014#lock-granularity-AND-hierarchies

	Recurso	         DESCrição
	------------------------------------------------------------------------------
	RID	            Um identificador de linha usado para bloquear uma única 
					  linha dentro de um heap.
	KEY	            Um bloqueio de linha dentro de um índice usado para 
					  proteger um INTervalo de chaves em transações.
	PAGE	            Uma página de 8 quilobytes (KB) em um banco de dados, 
					  como dados ou páginas de índice.
	EXTENT	         Um grupo contíguo de oito páginas, como dados ou 
					  páginas de índice.
	HoBT	            Um heap ou árvore-B. Um bloqueio protegENDo uma 
					  árvore-B (índice) ou o heap de páginas de dados 
					  que não tem um índice clusterizado.
	TABLE	            A tabela INTeira, inclusive todos os dados e índices.
	FILE	            Um arquivo do banco de dados.
	APPLICATION	      Um recurso de aplicativo especIFicado.
	METADATA	         Bloqueios de metadados.
	ALLOCATION_UNIT	Uma unidade de alocação.
	DATABASE	         O banco de dados INTeiro.
 */
 
/*
 * Bloqueando uma chave (KEY)
 */
	BEGIN TRANSACTION

	UPDATE tCADCliente 
	   SET mCredito = 100
	 WHERE iIDCliente = 1 


	 SELECT 
			resource_type AS TYPE , 
			request_mode as mode,
			request_type as request,
			request_status as status,
			request_session_id as session,
			CASE WHEN resource_type = 'OBJECT' 
				  THEN object_name(resource_associated_entity_id)
			END AS OBJECT,
			resource_DESCription
	 FROM sys.dm_tran_locks 
	 WHERE request_session_id = @@SPID 
	 ORDER BY request_session_id

	 ROLLBACK

/*
 * Bloqueando a tabela TCADCliente  (OBJECT) 
 */
	BEGIN TRANSACTION

	UPDATE tCADCliente 
	SET mCredito = 100
	WHERE dCadastro > '2018-01-01'


	SELECT 
			resource_type AS TYPE , 
			request_mode as mode,
			request_type as request,
			request_status as status,
			request_session_id as session,
			CASE WHEN resource_type = 'OBJECT' 
				  THEN object_name(resource_associated_entity_id)
			END AS OBJECT,
			resource_DESCription
	FROM sys.dm_tran_locks 
	WHERE request_session_id = @@SPID 
	ORDER BY request_session_id

	ROLLBACK

/* Um bloqueio de granularidade menor é Quando o SQL SERVER realiza o bloqueio
	da linha (RID) ou da chave (KEY) onde temos o menor recurso 
	que uma linha de dados.

	Entretanto, ele pode solicitar o que chamados de INTenção de bloqueio
	que pode ser exclusivo (IX) ou compartilhado (IS).

	Para executar uma instrução onde requer um bloqueio, o engine do SQL Server
	solicita a INTenção de bloqueios nos níveis mais alto
	do recurso que será bloqueado.

	Por exemplo, se o engine decide bloquear uma KEY, ele tenta obter a INTenção 
	de bloqueio de recursos maiores como PAGE ou TABLE.

	Exemplo: 
 */
	BEGIN TRANSACTION

	UPDATE tCADCliente 
	SET mCredito = 100
	WHERE iIDCliente = 1 

	SELECT 
			resource_type AS TYPE , 
			request_mode as mode,
			request_type as request,
			request_session_id as session,
			request_status as status,
			CASE WHEN resource_type = 'OBJECT' 
				 THEN object_name(resource_associated_entity_id)
			END AS OBJECT,
			resource_DESCription
	 FROM sys.dm_tran_locks 
	 WHERE request_session_id = 53
	 ORDER BY request_session_id

/*
 * Bloqueando várias chaves 
 */
	BEGIN TRANSACTION

		UPDATE tCADCliente 
		SET mCredito = 100
		WHERE iIDCliente <= 10 

	ROLLBACK
	
	BEGIN TRANSACTION
		UPDATE tCADCliente 
		SET mCredito = 100
		WHERE iIDCliente <= 5000

	ROLLBACK

	BEGIN TRANSACTION
		UPDATE tCADCliente 
		SET mCredito = 100
		WHERE iIDCliente <= 11000

	ROLLBACK

	SELECT 
			resource_type AS TYPE , 
			request_mode as mode,
			request_type as request,
			request_status as status,
			request_session_id as session,
			CASE WHEN resource_type = 'OBJECT' 
				 THEN object_name(resource_associated_entity_id)
			END AS OBJECT,
			resource_DESCription
	FROM sys.dm_tran_locks 
	WHERE request_session_id = @@SPID

	SELECT COUNT(1) FROM tCADCliente

/*
 * Derrubando uma conexão;
 */
	KILL 59

/* Mensagem que aparece para a conexão 53 
	Msg 596, Level 21, State 1, Line 0
	Cannot continue the execution because the session is in the kill state.
	Msg 0, Level 20, State 0, Line 0
	A severe error occurred on the current commAND.  The results, IF any, should be discarded.
 */

/* https://docs.microsoft.com/pt-br/sql/2014-toc/sql-server-transaction-locking-AND-row-versioning-guide?view=sql-server-2014#deadlocking

 * Deadlock ou chamado abraço mortal ocorre quando existe uma 
 * dependência cíclica entre duas conexões.

 * Os recursos de duas conexões tem uma dependência entre si. A transação A tem uma 
 * dependência com a transação B e vice-versa.

 * Exemplo:
 */

/* 
 * Conexão 01 
 */
	BEGIN TRANSACTION

	UPDATE tCADCliente 
	   SET mCredito  = 1
	 WHERE iIDCliente = 1

	UPDATE tCADLivro  
	   SET nPaginas = 617
	 WHERE iIDLivro = 1

	COMMIT 

/*
 * Conexão 02 
 */
	BEGIN TRANSACTION
		UPDATE tCADLivro  
		SET nPaginas = 617
		WHERE iIDLivro = 1

		UPDATE tCADCliente 
		SET mCredito  = 1
		WHERE iIDCliente = 1

	COMMIT 

/* Mensagem de Erro 

	Msg 1205, Level 13, State 51, Line 32
	Transaction (Process ID 54) was deadlocked on lock resources with another 
	process AND has been chosen as the deadlock victim. Rerun the transaction.
 */

/* Mas como o SQL Server define qual conexão será a vítima?

	Ele avalia as conexões e elege a que consumiu menos recursos para ser a vítima.
	Como o deadlock ocorrem em transações, o custo de ROLLBACK será menor se a conexão vítima da
	transação consumiu menos recursos que a outra conexão.

	Um dos fatores para calcular esse custo é quanto a transação consumiu 
	do log de transação.

	Exemplos:
*/

/*
 * Conexão 01 - Temos três instruções e pela 
 * definição, ela irá consumir mais recursos.
 */
	BEGIN TRANSACTION

		UPDATE tMOVPedido 
		SET dCancelado = GETDATE()
		WHERE iIDCliente = 1 

		UPDATE tCADCliente 
		SET mCredito  = 1
		WHERE iIDCliente = 1

		UPDATE tCADLivro  
		SET nPaginas = 617
		WHERE iIDLivro = 1

	COMMIT 

/*
 * Conexão 02 - Temos duas instruções e consumirá menos recursos que a conexão 1
 */
	BEGIN TRANSACTION

		UPDATE tCADLivro  
		SET nPaginas = 617
		WHERE iIDLivro = 1

		UPDATE tCADCliente 
		SET mCredito  = 1
		WHERE iIDCliente = 1

	COMMIT 

/* Minimizando a ocorrência de deadlock 

	- Na medida do possível, criar os códigos com mesma sequência
		lógica para atENDer o processo ou uma regra de négocio.

	- Sempre utilizar o mesmo objeto de programação para atENDer
		um processo, evitANDo ter código igual em objetos dIFerente.

	- Utilize transações curtas, com Comandos somente de
		atualização de dados. 
 */

/* Existem opções para voce configurar o comportamento do
 * bloqueio e do deadlocks.

	SET LOCK_TIMEOUT 

	Define o tempo de "timeout" de um bloqueio que a sessão espera. 

	Utilize um valor em milisegundos.
 */
	SET LOCK_TIMEOUT 5000 -- Define um tempo de 5 segundos.

	SET LOCK_TIMEOUT 0    -- Não define tempo para bloqueio.

	SET LOCK_TIMEOUT -1   -- Espera indefinidamente.

/* Por padrão, a conexão espera indefinidamente pela liberação do bloqueio.
 * A dica aqui é usar esse Comando de forma pontual, onde existe processos com 
 * uma grande incidência de bloqueios e que a regra de negócio 
 * permite interromper a transação.

 *	Exemplo:
 */

/*
 * Conexão 1 
 */ 
	SELECT @@SPID

	SELECT mCredito
	FROM tCADCliente
	WHERE iIDCliente = 1 

	BEGIN TRANSACTION
		UPDATE tCADCliente 
		SET mCredito = 2
		WHERE iIDCliente = 1 

	SELECT @@TRANCOUNT

	ROLLBACK

/*
 * Abrir um outra sessão e copiar o código abaixo 
 */
	SET LOCK_TIMEOUT 5000 -- Define um tempo de 5 segundos.

	SELECT @@SPID
	GO

	UPDATE tCADCliente 
	SET mCredito = 2
	WHERE iIDCliente = 1 


/* Msg 1222, Level 16, State 56, Line 6 Lock request time out period exceeded.
 * Como ocorre uma mensagem de erro, a mesma deve ser tratada no código.
 */

/* Utilizando o SET LOCK_TIMEOUT 0 
	Com essa configuração, não existe "timeout" de bloqueio.
	Assim que a conexão identIFica que um recurso está bloqueado e ela não consegue
	obter qualquer modo de bloqueio, ele emite imediatamente a mensagem 1222 
 */

/*
 * Conexão 1
 */
	SELECT @@SPID

	SELECT mCredito
	FROM tCADCliente
	WHERE iIDCliente = 1 

	BEGIN TRANSACTION
		UPDATE tCADCliente 
		SET mCredito = 2
		WHERE iIDCliente = 1 

	SELECT @@TRANCOUNT

	ROLLBACK
/*
 * Conexão 2
 */
	SET LOCK_TIMEOUT 0 -- Não tem TIMEOUT de bloqueio.

	SELECT @@SPID
	GO

	SELECT mCredito
	FROM tCADCliente
	WHERE iIDCliente = 1 

/* SET DEADLOCK_PRIORITY 
	Define a prioridade das conexões durante a fase de resolução de um DEADLOCK.

	Como vimos, Quando ocorre um deadlock, o SQL Server escolhe a vítima da 
	transação que consumiu menos recursos, desde que as conexões tenham a 
	mesma prioridade na resolução do deadlock.

	Quando alteramos a prioridade do deadlock, a conexão que tem a prioridade 
	maior que as outras NÃO será eleita a vitima do deadlock, mesmo que ele 
	tenha consumido poucos recursos.

	A faixa de prioridade é de  -10 até 10, sENDo o 10 a maior prioridade e o -10 
	a menor prioridade.

	Valores 

	NORMAL - que representa o valor 0 (zero) é o padrão de prioridade.
	HIGH   - representa o valor 5 e tem prioridade sobre as conexões com valor -10 até 4.
	LOW    - tem o valor -5 e será eleita vítima sobre as conexões com valor -4 até 10.

	Voce tem a opção de definir também um número entre -10 até 10.

	Exemplos: 
 */

/*
 * Conexão 01 - Temos três instruções e, pela definição irá consumir mais recursos.
 */
	BEGIN TRANSACTION

	UPDATE tMOVPedido 
	   SET dCancelado = GETDATE()
	  WHERE iIDCliente = 1 

	UPDATE tCADCliente 
	   SET mCredito  = 1
	 WHERE iIDCliente = 1

	UPDATE tCADLivro  
	   SET nPaginas = 617
	 WHERE iIDLivro = 1

	COMMIT 

/* 
 * Conexão 02 - Temos duas instruções e consumirá menos recursos que a conexão 1
 */
	SET DEADLOCK_PRIORITY HIGH 

	BEGIN TRANSACTION
		UPDATE tCADLivro  
		SET nPaginas = 617
		WHERE iIDLivro = 1

		UPDATE tCADCliente 
		SET mCredito  = 1
		WHERE iIDCliente = 1

	COMMIT 

/* https://docs.microsoft.com/pt-br/sql/t-sql/statements/SET-deadlock-priority-transact-sql?view=sql-server-2017
 * https://www.dirceuresENDe.com/blog/sql-server-como-gerar-um-monitoramento-de-historico-de-deadlocks-para-analise-de-falhas-em-rotinas/
 */

/* SEQUENCE com transações: 
	A numeração gerada pelo SEQUENCE é utilizada em um processo de transação, 
	indepENDente se a transação foi confirmada ou revertida. 

	Isso signIFica que uma ver utilizado o NEXT VALUE FOR para obter o
	próximo número, ele já foi recuperado mesmo que você não utiliza ele.

	DIFerente do IDENTITY(), que em um processo de transação revertido, o 
	número não é perdido.
 */	
	SELECT 
			TOP 2 * 
	FROM tMOVPedido 
	ORDER BY iIDPedido DESC 

	SELECT 
			current_value 
	FROM sys.sequences
	WHERE name = 'seqIDPedido'

/*
 * Rotina que faz um pedido, atualiza o estoque e o crédito do Cliente. 
 */
	SET NOCOUNT ON 

	DECLARE @iidCliente INT = 8834	
	DECLARE @iidLivro INT = 106		
	DECLARE @iidLoja INT = 9		 
	DECLARE @nQuantidade INT = 1	 
	DECLARE @iIDPedido INT			
	DECLARE @mValor SMALLMONEY		
	DECLARE @nNumeroError INT 

	BEGIN 
/*
 * Recupera qual o valor do livro de uma determinada loja
 */
	   SELECT 
			@mValor = mValor 
	   FROM tRELEstoque 
	   WHERE iIDLivro = @iidLivro 
	   AND iIDLoja = @iidLoja 
    
	   RAISERROR('Incluindo Pedido...',10,1) WITH NOWAIT; 
   
	   SELECT @iIDPedido = NEXT VALUE FOR seqIDPedido; -- Recupera o próximo número de pedido.

	   PRINT 'Numero do pedido'
	   PRINT @iIDPedido 

	   BEGIN TRANSACTION 
/* 
 * Insere o cabeçalho do pedido
 */
	   INSERT INTO dbo.tMOVPedido (iIDPedido ,iIDCliente,iIDLoja,iIDENDereco,iIDStatus,dPedido,dValidade,dEntrega,dCancelado,nNumero,mDESConto)
	   VALUES (@iIDPedido ,@iidCliente,@iidLoja,1,1,GETDATE(),DATEADD(d,15,GETDATE()),DATEADD(d,10,GETDATE()),null,587885,5)
   
	   SET @nNumeroError = @@ERROR
   
	   RAISERROR('Incluindo item de pedido...',10,1) WITH NOWAIT 
   
/* 
 * Inseri o item do pedido
 */
	   INSERT INTO tMOVPedidoItem (iIDPedido,IDLivro,iIDLoja,nQuantidade,mValorUnitario,mDESConto)
	   VALUES (@iIDPedido,@iidLivro,@iidLoja,@nQuantidade,@mValor ,5)
   
	   SET @nNumeroError = @@ERROR

	   RAISERROR('AtualizANDo Estoque do Livro...',10,1) WITH NOWAIT 
/* 
 * Atualiza o saldo do estoque do livro para a loja
 */ 
	   UPDATE tRELEstoque 
	   SET nQuantidade = (nQuantidade - @nQuantidade)
	   WHERE iIDLivro = @iidLivro 
	   AND iIDLoja = @iidLoja 

	   SET @nNumeroError = @@ERROR

	   RAISERROR('AtualizANDo Crédito de Cliente...',10,1) WITH NOWAIT 
/* 
 * Atualiza o crédito do cliente
 */
	   UPDATE tCADCliente 
	   SET mCredito =  (mCredito * 0 - @mValor) -- Simulando erro
	   WHERE iIDCliente = @iidCliente
	
	   SET @nNumeroError = @@ERROR

	   IF @@TRANCOUNT > 0 -- Primeiro teste, tem transação aberta? 
		  IF @nNumeroError = 0 BEGIN -- Ocorreu um erro? Não, então confirma.
			 COMMIT 
			 RAISERROR('ConfirmANDo a transação.',10,1) 
		  END 
		  ELSE BEGIN -- Sim, então desfaz!!!
			 ROLLBACK 
			  RAISERROR('DesFazendo a transação. Código do erro gerado %d',10,1,@nNumeroError) 
		  END 
	END 
/*
 * Finaliza a operacação
 */


