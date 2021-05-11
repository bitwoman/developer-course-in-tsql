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
	   if <Condição>
		  <Comandos...>
	   else 
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
	   While <Condição>
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
 * gerar uma solicitacao de compras de livro. 
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

/* Necessário criar uma variável como DATE para setar a data, e posteriormente, 
 * convertê-la para DATETIME. Do contrário, dará erro.
 */
	SET @dReferenciaData = '2018-09-15'

	SET @iIDLivro = 8513 
	SET @dReferencia = @dReferenciaData

/* 
 * Recupera o Peso atual do livro e a quantidade de meses prevista para consumo 
 */
	SELECT @nPeso = nPeso, 
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
	WHERE Item.IDLivro = 8513 AND Pedido.dPedido >= DATEADD(MONTH,-6,@dReferencia /*getdate()*/ )

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


	SELECT * FROM tMOVSolicitacaoCompra




