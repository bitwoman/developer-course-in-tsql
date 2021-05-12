/* Fluxo de execução 

	- Execução sequêncial de um conjunto de instruções. \

	<Ponto de Início>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	<Ponto de Término>

	- Execução sequêncial com desvio no fluxo de instruções. 

	<Ponto de Início>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   IF <Condição>
		  <Comandos...>
	   ELSE 
		  <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	<Ponto de Término>

	- Execução sequêncial com repetição de instruções. 

	<Ponto de Início>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   WHILE <Condição>
		  <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	<Ponto de Término>

	- Execução sequêncial com chamada de Stored Procedure 

	<Ponto de Início>    
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   Execute <Procedure01>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	<Ponto de Término>

	<Procedure01>
	<Ponto de Início>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	<Ponto de Término>

*/
	ALTER SEQUENCE seqiIDSolicitacao RESTART
	TRUNCATE TABLE tMOVSolicitacaoCompra

/*
 * Cálculo de consumo médio 
 */

/* Procedimento para calcular o consumo médio
 * de um livro nos último 6 meses, calcular a previsão
 * de consumo para os próximos 12 meses e 
 * gerar uma solicitacao de comprAS de livro. 
 */
	DECLARE @iidSolicitacao INT         
	DECLARE @iIDLivro INT				    
	DECLARE @nPeso NUMERIC(13,1)		   
	DECLARE @nQtdMesesConsumo INT		   
	DECLARE @nQtdEstoque INT			  
	DECLARE @nQtdMediaConsumida INT		
	DECLARE @nQtdSolicitada INT			
	DECLARE @mValorEstimado SMALLMONEY   
	DECLARE @mPesoEstimado NUMERIC(13,1) 
	DECLARE @dReferenciaData DATE
	DECLARE @dReferencia DATETIME

/* Necessário criar uma variável como DATE para SETar a data, e posteriormente, 
 * convertê-la para DATETIME. Do contrário, dará erro.
 */
	SET @dReferenciaData = '2018-09-15'

	SET @iIDLivro = 8513 
	SET @dReferencia = @dReferenciaData

/* 
 * Recupera o Peso atual do livro e a quantidade de meses prevista para consumo 
 */
	SELECT 
		   @nPeso = nPeso, 
		   @nQtdMesesConsumo = nMesesConsumo  
	FROM tCADLivro 
	WHERE iIDLivro = @iIDLivro

/* 
 * Calcula o estoque atual do livro e o valor médio para estimativa da compra. 
 */
	SELECT @nQtdEstoque = SUM(nQuantidade),
		   @mValorEstimado = AVG(mValor) 
	FROM tRELEstoque 
	WHERE iIDLivro = @iIDLivro

/* 
 * Calcula a quantidade média consumida nos últimos seis meses. 
 */
	SELECT 
		@nQtdMediaConsumida = AVG(nQuantidade)
	FROM tMOVPedido AS Pedido 
	JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
	WHERE Item.IDLivro = 8513 AND Pedido.dPedido >= DATEADD(MONTH,-6,@dReferencia /*GETDATE()*/ )

/* 
 * Calcula a quantidade que de ser solicitada
 */
	SET @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

/*
 * Calcula o valor estimado da quantidad solicitada 
 */
	SET @mValorEstimado = @mValorEstimado * @nQtdSolicitada

/* 
 * Calcula o peso estimado
 */
	SET @mPesoEstimado = @nQtdSolicitada * @nPeso

/*
 * Inclui a solicitação de compras
 */
	INSERT INTO tMOVSolicitacaoCompra (iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
	VALUES (@iIDLivro, @nQtdSolicitada , @mValorEstimado,@mPesoEstimado) 

	SELECT * 
	FROM tMOVSolicitacaoCompra

/* BEGIN / END

	Agrupa váriAS instruções em um bloco de comandos. 

	BEGIN
	   <Comandos>
	   <Comandos>
		...
	END

	Melhor organização de código.
*/

	BEGIN
/*
 * Iniciando a consulta
 */
	   SET NOCOUNT ON

	   SELECT 
			cTitulo 
	   FROM tCADLivro 
	   WHERE iIDLivro = 3443

	   RAISERROR('Consulta realizada com sucesso', 10, 1)
	END 
	GO

/*
 * Blocos Aninhados 
 */
	BEGIN
	   SET NOCOUNT ON
/*
 * IniciANDo a consulta
 */
	   BEGIN 
		  SELECT cTitulo 
  		  FROM tCADLivro 
		  WHERE iIDLivro = 3443

		  RAISERROR('Consulta realizada com sucesso', 10, 1)
	   END 

/*
 * Confirma o pedido 
 */
	   BEGIN 

		  UPDATE tMOVPedido 
		  SET dCancelado = GETDATE() 
		  WHERE iidpedido = 182965

		  RAISERROR('Pedido cancelado', 10,1) 
	   END 
	END 
	GO

/*
 * Se tirar todos os blocos, o script será igual ao exemplo abaixo 
 */

/*
 * Iniciando a consulta
 */
	SET NOCOUNT ON
	
	SELECT cTitulo 
	FROM tCADLivro 
	WHERE iIDLivro = 3443
	
	RAISERROR('Consulta realizada com sucesso',10,1)

/*
 * Confirma o pedido 
 */
	UPDATE tMOVPedido 
	SET dCancelado = GETDATE() 
	WHERE iidpedido = 182965
	
	RAISERROR('Pedido cancelado', 10,1) 

/*
 * Exemplo de script com comentários, definição de variáveis e bloco BEGIN/END
 */
	BEGIN 
	   SET NOCOUNT ON

/* Procedimento para calcular o consumo médio de um livro nos último 6 meses, 
 * calcular a previsão de consumo para os próximos 12 meses e gerar uma 
 * solicitação de comprAS de livro. 
 */	
		DECLARE @iidSolicitacao int        
		DECLARE @iIDLivro int				   
		DECLARE @nPeso NUMERIC(13,1)		   
		DECLARE @nQtdMesesConsumo int		  
		DECLARE @nQtdEstoque int			   
		DECLARE @nQtdMediaConsumida int		
		DECLARE @nQtdSolicitada int			
		DECLARE @mValorEstimado SMALLMONEY  
		DECLARE @mPesoEstimado NUMERIC(13,1) 
		DECLARE @dReferenciaData DATE
		DECLARE @dReferencia DATETIME

/* Necessário criar uma variável como DATE para SETar a data, e posteriormente, 
 * convertê-la para DATETIME. Do contrário, dará erro.
 */
		SET @dReferenciaData = '2018-09-15'

		SET @iIDLivro = 8513 
		SET @dReferencia = @dReferenciaData
	
/* Recupera o Peso atual do livro e a 
 * quantidade de meses prevista para consumo.
 */
		SELECT 
				@nPeso = nPeso, 
				@nQtdMesesConsumo = nMesesConsumo  
		FROM tCADLivro 
		WHERE iIDLivro = @iIDLivro

/* Calcula o estoque atual do livro e o valor médio para estimativa da compra. 
 */
		SELECT 
				@nQtdEstoque =  SUM(nQuantidade),
				@mValorEstimado = AVG(mValor) 
		FROM tRELEstoque 
		WHERE iIDLivro = @iIDLivro

/* Calcula a quantidade média consumida nos últimos seis meses. 
 */
		SELECT 
			@nQtdMediaConsumida = AVG(nQuantidade)
		FROM tMOVPedido AS Pedido 
		JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
		WHERE Item.IDLivro = @iIDLivro
		AND dPedido <= DATEADD(MONTH,-6, @dReferencia  /*GETDATE()*/  )

/*
 * Calcula a quantidade que deve ser solicitada
 */
		SET @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

/*
 * Calcula o valor estimado da quantidade solicitada
 */ 
		SET @mValorEstimado = @mValorEstimado * @nQtdSolicitada

/*
 * Calcula o peso estimado
 */ 
		SET @mPesoEstimado = @nQtdSolicitada * @nPeso

/*
 * Inclui a solicitação de comprAS
 */ 
		SET @iidSolicitacao = NEXT VALUE FOR seqiIDSolicitacao

		INSERT INTO tMOVSolicitacaoCompra (iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
		VALUES (@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)

	END 

/*
 * Fim do cálculo de consumo médio 
 */
	SELECT * 
	FROM tMOVSolicitacaoCompra

/* IF / ELSE
 * Causa um desvio condicional no fluxo de Comandos.

 * - Precisa de uma expressão lógica para validar o desvio.
 * - ELSE é opcional.

	IF <Expressão lógica>
	   <Bloco de Comandos>
	ELSE 
	   <Bloco de Comandos>
 */
	UPDATE tMOVPedido 
	SET dCancelado = GETDATE() 
	WHERE iidPedido = 145430000

	IF @@ROWCOUNT > 0 
	  RAISERROR('O comANDo foi processado', 10,1)

/*
 * Utilizando o ELSE
 */
	SET NOCOUNT ON 

	UPDATE tMOVPedido 
	SET dCancelado = GETDATE() 
	WHERE iidPedido = 14543534543

	IF @@ROWCOUNT > 0 
	  RAISERROR('O comANDo foi processado', 10,1)
	ELSE 
	  RAISERROR('O Pedido não foi encontrado', 10,1)

/*
 * Condição lógica 
 */

/*
 * DATEPART() função nativa do SQL Server  
 */ 
	IF DATEPART(dw, GETDATE()) IN (1,7)
	   RAISERROR('Hoje é um final de semana',10,1)
	ELSE 
	   RAISERROR('Hoje é um dia de semana',10,1)

/*
 * Dados escalar de uma tabela
 */ 
	IF (SELECT iidcliente FROM tCADcliente WHERE iidcliente = 1)  > 0
		RAISERROR('Cliente já cadastrado.',10,1)
	ELSE
		RAISERROR('Cliente não cadastrado.',10,1)

/*
 * AgrupANDo vários Comandos IF e ELSE é necessário utilizar BEGIN/END 
 */
	IF (SELECT iidcliente FROM tCADcliente WHERE iidcliente = 1)  > 0
	   UPDATE tCADCliente 
	   SET dExclusao = GETDATE() 
	   WHERE iidcliente = 1

	   RAISERROR('Cliente foi cancelado.',10,1)
	ELSE
	   RAISERROR('Cliente não cadastrado.',10,1)

	GO

/* Msg 156, Level 15, State 1, Line 64
 * Incorrect syntax near the keyword 'ELSE'. Apesar da mensagem não informar 
 * a real causa do erro, o que ocorre é que temos dois Comandos depois do IF.
 */

/*
 * Cancela nota fiscal e pedido 
 */
	BEGIN 
	   IF (SELECT iidcliente FROM tCADcliente WHERE iidcliente = 1)  > 0
		  BEGIN
			 
			 UPDATE tCADCliente 
			 SET dExclusao = GETDATE() 
			 WHERE iidcliente = 1
			 
			 RAISERROR('Cliente foi cancelado.',10,1)
		  END 
	   ELSE
		  RAISERROR('Cliente não cadastrado.',10,1)
	END

/* A mesma regra vale para o ELSE. Se voce precisa executar dois
 * ou mais Comandos no ELSE, voce tem que utilizar BEGIN/END 
 */

/* Dica na utilização do @@ROWCOUNT:
 * Utilizar o @@ROWCOUNT imediatamente após a instrução DML.
 */
	SELECT COUNT(1) 
	FROM tCADLivro 
	WHERE iIDDestaque = 1

	DECLARE @nRetorno INT 
	
	UPDATE tCADLivro 
	SET nPaginAS = nPaginAS -1 
	WHERE iIDDestaque = 1 
	SET @nRetorno = 1 

	IF @@ROWCOUNT > 1
	   RAISERROR('VáriAS linhAS foram atualizadAS',10,1)

	GO 

/*
 * CORREÇÃO
 */ 
	DECLARE @nRetorno int 
	
	UPDATE tCADLivro 
	SET nPaginAS = nPaginAS -1 
	WHERE iIDDestaque = 1 

	IF @@ROWCOUNT > 1
	   RAISERROR('Várias linhas foram atualizadas', 10, 1)

	SET @nRetorno = 1 

/* Procedimento para calcular o consumo médio de um livro nos último 6 meses, 
 * calcular a previsão de consumo para os próximos 12 meses e gerar uma solicitação 
 * de comprAS de livro. 
 */
	BEGIN 
	   SET NOCOUNT ON

/* Procedimento para calcular o consumo médio de um livro nos último 6 meses, 
 * calcular a previsão de consumo para os próximos 12 meses e gerar uma 
 * solicitação de comprAS de livro. 
 */		
		DECLARE @iidSolicitacao int        
		DECLARE @iIDLivro int				   
		DECLARE @nPeso NUMERIC(13,1)		   
		DECLARE @nQtdMesesConsumo int		  
		DECLARE @nQtdEstoque int			   
		DECLARE @nQtdMediaConsumida int		
		DECLARE @nQtdSolicitada int			
		DECLARE @mValorEstimado SMALLMONEY  
		DECLARE @mPesoEstimado NUMERIC(13,1) 
		DECLARE @dReferenciaData DATE
		DECLARE @dReferencia DATETIME

/* Necessário criar uma variável como DATE para SETar a data, e posteriormente, 
 * convertê-la para DATETIME. Do contrário, dará erro.
 */
		SET @dReferenciaData = '2018-09-15'

		SET @iIDLivro = 8513 
		SET @dReferencia = @dReferenciaData
	
/* Recupera o Peso atual do livro e a 
 * quantidade de meses prevista para consumo.
 */
		SELECT @nPeso = nPeso , 
		    @nQtdMesesConsumo = nMesesConsumo  
		FROM tCADLivro 
		WHERE iIDLivro = @iIDLivro

		IF @@ROWCOUNT = 0
		RAISERROR('O ID do livro não foi encontrado',10,1)
		ELSE BEGIN 

/* Calcula o estoque atual do livro e o valor médio para estimativa da compra. 
 */
		SELECT 
				@nQtdEstoque =  SUM(nQuantidade),
				@mValorEstimado = AVG(mValor) 
		FROM tRELEstoque 
		WHERE iIDLivro = @iIDLivro

/* Calcula a quantidade média consumida nos últimos seis meses. 
 */
		SELECT 
			@nQtdMediaConsumida = AVG(nQuantidade)
		FROM tMOVPedido AS Pedido 
		JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
		WHERE Item.IDLivro = @iIDLivro
		AND dPedido <= DATEADD(MONTH,-6, @dReferencia  /*GETDATE()*/  )

/*
 * Calcula a quantidade que deve ser solicitada
 */
		SET @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

/*
 * Calcula o valor estimado da quantidade solicitada
 */ 
		SET @mValorEstimado = @mValorEstimado * @nQtdSolicitada

/*
 * Calcula o peso estimado
 */ 
		SET @mPesoEstimado = @nQtdSolicitada * @nPeso

/*
 * Inclui a solicitação de comprAS
 */ 
		SET @iidSolicitacao = NEXT VALUE FOR seqiIDSolicitacao

		INSERT INTO tMOVSolicitacaoCompra (iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
		VALUES (@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)

		END -- IF @@ROWCOUNT = 0
	END 

/*
 * Fim do cálculo de consumo médio 
 */
	SELECT * FROM tMOVSolicitacaoCompra

/* RETURN: Finaliza a execução de um conjunto de instruções em lote ou de uma
 * stored procedure.
 */
	BEGIN
	   SELECT MAX(iidcliente) FROM tMOVPedido

	   RETURN 

	   SELECT TOP 1 * FROM tCADLivro 
	END 

/*
 * Início
 */
	SET NOCOUNT ON 

	BEGIN
	   IF (SELECT iidcliente FROM tCADcliente WHERE iidcliente = 3)  > 0
		  BEGIN 
			 UPDATE tCADCliente 
			 SET dExclusao = GETDATE() 
			 WHERE iidcliente = 1
			 
			 RAISERROR('Cliente foi cancelado.',10,1)
		  END 
	   ELSE
		  BEGIN 
			 RAISERROR('Cliente não cadastrado.',10,1)
			   RETURN 
		   END
	   
	   RAISERROR('Script processado com sucesso.',10,1)
	END
	
/*
 * Fim
 */
	BEGIN

	   SET NOCOUNT ON 
    
/* Procedimento para calcular o consumo médio de um livro nos último 6 meses, 
 * calcular a previsão de consumo para os próximos 12 meses e gerar uma 
 * solicitação de comprAS de livro. 
 */
	DECLARE @iidSolicitacao INT         
	DECLARE @iIDLivro INT				   
	DECLARE @nPeso NUMERIC(13,1)		   
	DECLARE @nQtdMesesConsumo INT		   
	DECLARE @nQtdEstoque INT			  
	DECLARE @nQtdMediaConsumida INT		
	DECLARE @nQtdSolicitada INT			
	DECLARE @mValorEstimado SMALLMONEY   
	DECLARE @mPesoEstimado NUMERIC(13,1) 
	DECLARE @dReferenciaDATE DATE
	DECLARE @dReferencia DATETIME

	SET @iIDLivro = 8513
	SET @dReferenciaDATE = '2018-09-15'
	SET @dReferencia = @dReferenciaDATE

/* Recupera o Peso atual do livro e a quantidade de meses prevista para consumo 
*/
	SELECT @nPeso = nPeso , 
		    @nQtdMesesConsumo = nMesesConsumo  
	FROM tCADLivro 
	WHERE iIDLivro = @iIDLivro

	IF @@ROWCOUNT = 0 
	BEGIN
	   RAISERROR('O ID do livro não foi encontrado', 10, 1)
      RETURN 
	END
 
/* Calcula o estoque atual do livro e o valor médio para estimativa da compra. 
*/
	SELECT @nQtdEstoque =  SUM(nQuantidade),
		      @mValorEstimado = AVG(mValor) 
	FROM tRELEstoque 
	WHERE iIDLivro = @iIDLivro

/* Calcula a quantidade média consumida nos últimos seis meses. 
*/
	SELECT 
			@nQtdMediaConsumida = AVG(nQuantidade)
	FROM tMOVPedido AS Pedido 
	JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
	WHERE Item.IDLivro = @iIDLivro 
	AND dPedido <= DATEADD(MONTH, -6, @dReferencia) /*GETDATE()*/

/*
 * Calcula a quantidade que deve ser solicitada
 */ 
	SET @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

/*
 * Calcula o valor estimado da quantidade solicitada
 */ 
	SET @mValorEstimado = @mValorEstimado * @nQtdSolicitada

/*
 * Calcula o peso estimado
 */ 
   SET @mPesoEstimado = @nQtdSolicitada * @nPeso

/*
 * Inclui a solicitação de comprAS
 */ 
	SET @iidSolicitacao = NEXT VALUE FOR seqiIDSolicitacao

	INSERT INTO tMOVSolicitacaoCompra
	(iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
	VALUES
	(@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)
   
	END 
/*
 * Fim do cálculo de consumo médio 
 */
	SELECT * FROM tMOVSolicitacaoCompra

/* WHILE: Executa um bloco de Comandos diversAS vezes.
	Precisa de uma expressão lógica para repetir o bloco de Comandos.

	WHILE <Expressão Lógica>
	   <Bloco de Comandos>
*/

/*
 * Processar um intervalo de Itens.
 */
	SET NOCOUNT ON 

	DECLARE @nContaLivro int = 1 -- @nContaLivro é igual a 1

	WHILE @nContaLivro < 4 BEGIN -- Faça enquanto @nContaLivro menor 4
		  SELECT * 
		  FROM tCADLivro 
		  WHERE iIDLivro = @nContaLivro

		   SET @nContalivro += 1 -- Soma 1 na variável @nContaLivro
	END 

	PRINT @nContalivro
	GO

/*
 * Processar um intervalo de datas
 */
	DECLARE @dInicio DATE = '2018-12-01'  -- Começo do mês
	DECLARE @dFinal DATE  = '2018-12-31'  -- Final do mês

	WHILE @dInicio <= @dFinal BEGIN
		   PRINT 'Calculo de consumo de ' + CAST(@dInicio AS VARCHAR(20))+' '+ DATEname(dw,@dInicio)
		   SET @dInicio = DATEADD(Day, 1, @dInicio)  -- Adiciona um dia a data @dInicio
	END 

/*
 * Executar enquanto houver linhas para serem processadas
 */
	BEGIN 
	   DECLARE @nQtdLivros TINYINT  = 0

	   UPDATE tRELEstoque 
	   SET dUltimoConsumo = '1900-01-01' 
	   WHERE iidlivro = 108 

/*
 * Retorno 8 linhas
 */
	   SET @nQtdLivros = @@ROWCOUNT

	   WHILE @nQtdLivros > 0  BEGIN

			 UPDATE TOP(1) tRELEstoque -- Retorna 1 linha, para WHERE Verdadeiro 
			 SET dUltimoConsumo = GETDATE()
			 WHERE iidlivro = 108 
		     AND dUltimoConsumo = '1900-01-01'
			
			 SET @nQtdLivros = @@ROWCOUNT

			 PRINT @nQtdLivros
	   END
	END

/*
 * Fim do script 
 */

/*
 * Deletando um grande quantidade de linhas 
 */

/*
 * Para relizar a simulação 
 */
	DROP TABLE IF EXISTS tTMPPedidoItem

	SELECT * INTO tTMPPedidoItem
	FROM tMOVPedidoItem

/*
 * Solução 1
 */
	DELETE FROM tTMPPedidoItem WHERE iIDPedidoItem <= 1000000

/* Problemas: 
 * - Teria uma transação aberta e talvez bloqueANDo a tabela inteira;
 * - Isso causaria uma sequência de bloqueios em outras conexões;
 * - O seu Log de Transação ficaria grande.
 */

/*
 * Solução 2. Faça DELETE menores. 
 */
	SELECT COUNT(1) 
	FROM tTMPPedidoItem 
	WHERE iIDPedidoItem <= 1000000

/*
 * São 1.000.000 de linhAS e vamos fazer deleções a cada 49.000
 */
	DECLARE @nDeletANDo bit = 1

	WHILE @nDeletANDo = 1 BEGIN 

		  RAISERROR('Deletando....', 10,1) WITH NOWAIT 

		  DELETE TOP (49000) 
			 FROM tTMPPedidoItem 
			WHERE iIDPedidoItem <= 1000000

		   IF @@ROWCOUNT < 49000 
			  SET @nDeletANDo = 0
	END 
	GO

/*
 * Script para aguardar a mudança de uma coluna da tabela 
 */

/*
 * Outra Sessão 
 */
	UPDATE tRELEstoque SET nQuantidade = 0 WHERE nQuantidade = 1

	RAISERROR('Aguardando liberação do estoque...',10,1) WITH NOWAIT

	WHILE (SELECT TOP 1 1 FROM tRELEstoque WHERE nQuantidade = 0) IS NULL
		  WAITFOR DELAY '00:00:10'

	RAISERROR('Estoque liberado...', 10, 1) WITH NOWAIT

	UPDATE tRELEstoque SET nQuantidade = 1 WHERE nQuantidade = 0

/* Criar um job por exemplo, que fique aguardando com o status de algum dos
 * dados que foram alterados e iniciar um processo ou tarefa.
 */
	TRUNCATE TABLE tMOVSolicitacaoCompra

/*
 * Fazendo o cálculo para vários livros:
 */
	BEGIN

	   SET NOCOUNT ON 
  
/* Procedimento para calcular o consumo médio de um livro nos último 6 meses, 
 * calcular a previsão de consumo para os próximos 12 meses e gerar uma 
 * solicitação de compras de livro. 
 */	
		DECLARE @iidSolicitacao int         
		DECLARE @iIDLivro int				    
		DECLARE @nPeso NUMERIC(13,1)		   
		DECLARE @nQtdMesesConsumo int		    
		DECLARE @nQtdEstoque int			    
		DECLARE @nQtdMediaConsumida int		
		DECLARE @nQtdSolicitada int			 
		DECLARE @mValorEstimado SMALLMONEY    
		DECLARE @mPesoEstimado NUMERIC(13,1) 
		DECLARE @dReferenciaDATE DATE       
		DECLARE @dReferencia DATETIME

		SET @iIDLivro = 8513 
		SET @dReferenciaDATE = '2018-09-15'
		SET @dReferencia = @dReferenciaDATE

/* 
 * Tabela para dados temporários do livro (iIDLivro int)
 */	   
	   TRUNCATE TABLE tTMPLivro
   
/* Insere na table, 10 ID de livros que tem o estoque abaixo
 * do estoque mínimo.
 */
	   INSERT INTO tTMPLivro
	   SELECT 
			TOP 10 Livro.iidlivro 
	   FROM tCADLivro AS Livro 
	   JOIN tRELEstoque AS Estoque ON (Livro.iIDLivro = Estoque.iIDLivro)
	   WHERE Estoque.nQuantidadeMinima > Estoque.nQuantidade
   
	   IF @@ROWCOUNT = 0 BEGIN
		   RAISERROR('Não existem livros para serem processados.', 10, 1) WITH NOWAIT
		  RETURN 
		END

/*
 * Processa um livro por vez.
 */	   
		WHILE (SELECT TOP 1 iIDLivro FROM tTMPLivro) > 0 BEGIN 

			 SET @iIDLivro = (SELECT TOP 1 iIDLivro FROM tTMPLivro)

/* Recupera o Peso atual do livro e a quantidade de meses prevista para consumo 
*/
			  SELECT @nPeso = nPeso , 
					  @nQtdMesesConsumo = nMesesConsumo  
			  FROM tCADLivro 
			  WHERE iIDLivro = @iIDLivro

/* Calcula o estoque atual do livro e o valor médio para estimativa da compra 
*/
			  SELECT @nQtdEstoque =  SUM(nQuantidade),
						@mValorEstimado = AVG(mValor) 
				 FROM tRELEstoque 
				 WHERE iIDLivro = @iIDLivro

/* Calcula a quantidade média consumida nos últimos seis meses. 
 */
			  SELECT @nQtdMediaConsumida = AVG(nQuantidade)
			  FROM tMOVPedido AS Pedido 
			  JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
			  WHERE Item.IDLivro = @iIDLivro
			  AND dPedido <= DATEADD(MONTH, -6, @dReferencia /*GETDATE()*/)

/* 
 * Calcula a quantidade que deve ser solicitada
 */
			 SET @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

			 IF @nQtdSolicitada > 0 BEGIN
/* 
 * Calcula o valor estimado da quantidade solicitada.
 */				 
			 SET @mValorEstimado = @mValorEstimado * @nQtdSolicitada

/*
 * Calcula o peso estimado
 */
			 SET @mPesoEstimado = @nQtdSolicitada * @nPeso

/* 
 * Inclui a solicitação de compras
 */
          
				SET @iidSolicitacao = NEXT VALUE FOR seqiIDSolicitacao

				 INSERT INTO tMOVSolicitacaoCompra
				 (iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
				 VALUES 
				 (@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)
   
			 END -- IF @nQtdSolicitada >= 0 

/*
 * Ao fim do processo, apaga o livro da tabela
 */
			 DELETE tTMPLivro WHERE iidlivro = @iIDLivro 
    
	   END  -- WHILE    
	END 

/*
 * Fim do cálculo de Consumo Médio 
 */
	SELECT * FROM tMOVSolicitacaoCompra


/* Segundo Teste - Preparando 1 livro para ser processando:
	UPDATE tRElEstoque SET nQuantidadeMinima = 0

	UPDATE tRelEstoque 
	SET nQuantidadeMinima  = 10, nQuantidade = 5
	WHERE iidlivro = 111

	SELECT TOP 1 * FROM tRelEstoque 
	WHERE iidlivro = 111

	SELECT AVG(nQuantidade)
	FROM tMOVPedido AS Pedido 
	JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
	WHERE Item.IDLivro = 111
    AND dPedido <= DATEADD(MONTH,-6, @dReferencia /*GETDATE()*/)
*/

/* Terceiro  - Preparando 10 livro para ser processando
	UPDATE tRelEstoque 
	SET nQuantidadeMinima  = 10, nQuantidade = 5
	WHERE iidlivro IN (SELECT TOP 10 iidlivro  
					   FROM tRelEstoque 
						 GROUP BY iidlivro
						HAVING COUNT(*)  =1
						)

	SELECT * FROM tRelEstoque 
	WHERE iidlivro IN (SELECT TOP 10 iidlivro  
					   FROM tRelEstoque 
					   GROUP BY iidlivro
					   HAVING COUNT(*)  = 1)

      SELECT AVG(nQuantidade)
	         FROM tMOVPedido AS Pedido 
	         JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
	         WHERE Item.IDLivro = 111
	         AND dPedido <= DATEADD(MONTH,-6, @dReferencia /*GETDATE()*/)
*/

/* Bloco TRY e CATCH 

	Controla as exceções e tratamento de erros

	O bloco TRY controlAS AS exceções, detectANDo os erros gerados por Comandos
	ou pela instrução RAISERROR() e envia para bloco CATCH.

	O bloco CACTH recebe do bloco TRY o erro, identIFica os valores retornados 
	usANDo funções de tratamento de erro exclusivAS desse bloco. Neste bloco
	você tem a opção de devolver o erro para que fez a chamado ou tratar o erro para 
	gerar um log em tabela ou no SQL Server Logs. 

	<Blocos de Comandos> 

	BEGIN TRY

	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>
	   <Comandos...>   

	END TRY



	BEGIN CATCH

	   <Comandos...>
	   <Comandos...>
	   <Comandos...>

	END CATCH 

	<Blocos de Comandos> 


- Blocos TRY e CATCH devem ficar juntos.
- Não pode existir Comandos entre os blocos.
- Somente erros com severidade acima de 10 são detectados
- Se não houver erro no bloco TRY, o fluxo é desviado para a próximo instrução
  abaixo do END CATCH;
- Voce pode decidir continuar a execução ou interromper no tratamento do erro 
*/


/* Exemplo com erro de divisão por zero 
 * - Simular sem o erro - SELECT 1/1
 * - Simular com o erro - SELECT 1/0 
 */
	BEGIN

	   SET NOCOUNT ON 

	   RAISERROR('01. Teste de simulação de erro',10,1) WITH NOWAIT 

	   BEGIN TRY

		  RAISERROR('02. Inicio Teste de simulação de erro',10,1) WITH NOWAIT 
		   SELECT 1/0
		   RAISERROR('03. Final Teste de simulação de erro',10,1) WITH NOWAIT 

	   END TRY

	   BEGIN CATCH

		   RAISERROR('99. IdentIFicação do erro.',10,1) WITH NOWAIT 

	   END CATCH 

	   RAISERROR('04. Teste de simulação de erro',10,1) WITH NOWAIT 

	END 

/*
 *Fim do exemplo
 */
	GO

/*
 * Simulando entre uma faixa de datas
 */
	BEGIN 

	   DECLARE @dData DATE = '2018-11-15'
	   DECLARE @dReferencia	DATE = '2018-11-30'
	   DECLARE @nResultado INT 

	   WHILE @dData <= @dReferencia BEGIN

		  BEGIN TRY
			 IF DATEPART(dw, @dData) in (1,7)
				 SET @nResultado = 1/0 

			  RAISERROR('Lançamentos de contabilizado', 10,1)  

		  END TRY 

		  BEGIN CATCH

			 PRINT '--- Houve um erro no dia ' 
			  PRINT @dData 

		  END CATCH 

		  SET @dData = DATEADD(d,1,@dData)

	   END -- WHILE @dData <= @dReferencia

	END 
	GO

/* Identificando o erro no bloco CATCH 
 * Como vimos a função @@ERROR, vamos usar junto com o bloco TRY e CATCH 
 */

/*
 * Exemplo 
 */	
	BEGIN 

	   BEGIN TRY

		   SELECT 1/0 
       
	   END TRY

	   BEGIN CATCH 

		  IF @@ERROR = 8134
			 RAISERROR('Ocorreu um erro de divisão por zero.',10,1)

	   END CATCH 

	END

/*
 * Fim do exemplo 
 */

/*
 * Exemplo de atualização de dados com erro.
 */	
	BEGIN 

	   DECLARE @cNome VARCHAR(100)   
	   DECLARE @iIDCliente INT       
	   DECLARE @mCredito SMALLMONEY 
	   DECLARE @nCodigoErro INT      

	   SET @iIDCliente = 33612

	   BEGIN TRY
		   SELECT @cNome = cNome ,-- +  ' IndustriAS.' , 
				  @mCredito = mCredito
			 FROM tCADCliente
			WHERE iIDCliente = @iIDCliente 
       
		   IF @mCredito < 20 

			  UPDATE tCADCliente 
				 SET cNome = @cNome, -- Primeiro erro, dados truncados 
					 mCredito = 0    -- Segundo erro, violação da restrição CHECK  
			   WHERE iIDCliente = 33612
       
	   END TRY

	   BEGIN CATCH 
		  SET @nCodigoErro = @@ERROR
   
/*
 * Os dados de cadeia ou binários ficariam truncados
 */		  
		  IF @nCodigoErro = 8152
			 RAISERROR('Erro 8152. Os dados de cadeia ou binários ficariam truncados.',10,1)
      
/* Conflito entre a instrução UPDATE e a restrição CHECK 
 * "CK__tCADClien__mCred__3D5E1FD2". O conflito ocorreu na bASe de 
 * dados "eBook", tabela "dbo.tCADCliente", column 'mCredito'.
 */		  
		  IF @nCodigoErro = 547
			 RAISERROR('Erro 547. Conflito entre a instrução UPDATE e a restrição CHECK.' ,10,1)
		  Else 
			 PRINT 'Codigo de error ' + CAST(@nCodigoErro AS VARCHAR(10))

	   END CATCH 

	END

/*
 * Fim do Exemplo 
 */

/*
 * Alguns erros não são capturados
 */
	BEGIN  TRY
	   SELECT * FROM TabelaNaoExiste
	END TRY

	BEGIN CATCH
		SELECT 'Houve um erro'
	END CATCH 
	GO

/*
 * Fazendo o cálculo para vários livros
 */
	BEGIN

	   SET NOCOUNT ON 
    
/* Procedimento para calcular o consumo médio de um livro nos último 6 meses, 
 * calcular a previsão de consumo para os próximos 12 meses e gerar uma 
 * solicitação de comprAS de livro. 
 */
	
	   DECLARE @iidSolicitacao INT          
	   DECLARE @iIDLivro INT				    
	   DECLARE @nPeso NUMERIC(13,1)		    
	   DECLARE @nQtdMesesConsumo INT		    
	   DECLARE @nQtdEstoque INT			 
	   DECLARE @nQtdMediaConsumida INT		
	   DECLARE @nQtdSolicitada INT			 
	   DECLARE @mValorEstimado SMALLMONEY   
	   DECLARE @mPesoEstimado NUMERIC(13,1) 
	   DECLARE @dReferenciaDATE DATE 
	   DECLARE @dReferencia DATETIME 

	   SET @iIDLivro = 8513 
	   SET @dReferenciaDATE = '2018-09-15'
	   SET @dReferencia = @dReferenciaDATE
   
/*
 * Tabela para dados temporários do livro (iIDLivro INT)
 */ 
	   TRUNCATE TABLE tTMPLivro
   
	   INSERT INTO tTMPLivro
	   SELECT TOP 10 Livro.iidlivro 
	   FROM tCADLivro AS Livro 
	   JOIN tRELEstoque AS Estoque ON (Livro.iIDLivro = Estoque.iIDLivro)
	   WHERE Estoque.nQuantidadeMinima > Estoque.nQuantidade
   
	   IF @@ROWCOUNT = 0 BEGIN
		   RAISERROR('Não existem livros para serem processados.',10,1)
		  RETURN 
		END

	   WHILE (SELECT TOP 1 iIDLivro FROM tTMPLivro) > 0 
		BEGIN 

			 SET @iIDLivro = (SELECT TOP 1 iIDLivro FROM tTMPLivro)

/* Recupera o Peso atual do livro e a quantidade de meses prevista para consumo 
 */
			  SELECT @nPeso = nPeso , 
					  @nQtdMesesConsumo = nMesesConsumo  
			  FROM tCADLivro 
			  WHERE iIDLivro = @iIDLivro

/* Calcula o estoque atual do livro e o valor médio para estimativa da compra. 
 */
			  SELECT @nQtdEstoque =  SUM(nQuantidade),
						@mValorEstimado = AVG(mValor) 
			  FROM tRELEstoque 
			  WHERE iIDLivro = @iIDLivro

/* Calcula a quantidade média consumida nos últimos seis meses. 
 */
			  SELECT @nQtdMediaConsumida = AVG(nQuantidade)
			  FROM tMOVPedido AS Pedido 
			  JOIN tMOVPedidoItem AS Item ON (Pedido.iIDPedido = Item.iIDPedido)
			  WHERE Item.IDLivro = @iIDLivro
			  AND dPedido <= DATEADD(MONTH, -6, @dReferencia) /*GETDATE()*/

/*
 * Calcula a quantidade que deve ser solicitada
 */			  
			 SET @nQtdSolicitada = (@nQtdMediaConsumida * @nQtdMesesConsumo ) - @nQtdEstoque

			 IF @nQtdSolicitada > 0 BEGIN
         
/*
 * Calcula o valor estimado da quantidade solicitada
 */ 
				SET @mValorEstimado = @mValorEstimado * @nQtdSolicitada

/*
 * Calcula o peso estimado
*/				
				SET @mPesoEstimado = @nQtdSolicitada * @nPeso

/* 
 * Inclui a solicitação de comprAS.
 */        
				SET @iidSolicitacao = NEXT VALUE FOR seqiIDSolicitacao

				BEGIN TRY 

					INSERT INTO tMOVSolicitacaoCompra
					(iidSolicitacao,iIDLivro, nQuantidade , mValorEstimado, mPesoEstimado)
					VALUES 
					(@iidSolicitacao,@iIDLivro,@nQtdSolicitada , @mValorEstimado, @mPesoEstimado)

				END TRY 

				BEGIN CATCH

				   RAISERROR('Houve um erro na inclusão da Solicitação de ComprAS',10,1)

				END CATCH 
   
			 END -- IF @nQtdSolicitada >= 0 

			 DELETE tTMPLivro WHERE iidlivro = @iIDLivro 
    
	   END  -- WHILE    

	END 

/*
 * Fim do cálculo de consumo médio 
 */

	SELECT * FROM tMOVSolicitacaoCompra

/* BREAK - Interrompe a execução do bloco WHILE, devolve o controle do fluxo
			para a próximo instrução após o WHILE.

	CONTINUE - Interrompe a execução do Bloco WHILE e volta o controle para o WHILE, ignorANDo
			   AS instruções abaixo do CONTINUE. 

	<Comandos>

	WHILE <Condição> BEGIN

	   <Comandos>

	   BREAK

	   <Comandos>

	   CONTINUE

	   <Comandos>

	END 

	<Comandos>
 */

/*
 * Demonstração 
 */
	RAISERROR('Inicio do fluxo' , 10,1)

	DECLARE @iIDLivro INT = 0  --- Começa com 0 na variável 

	WHILE @iIDLivro <= 15 
		BEGIN  -- Executa o Loop 15 vezes 

		   SET @iIDLivro += 1

		   IF @iIDLivro in (1,2,3,4,5)  -- Se contator entre 1 e 5
			  CONTINUE                  -- Volta para inicio do WHILE
   
		   IF @iIDLivro > 10 -- Se contador maior que 10, sai do Loop 
			  BREAK   --- Sair do laço. 

		   RAISERROR('Fluxo normal %d', 10,1,@iidlivro )
		END 

	RAISERROR('Final do fluxo' , 10,1)

