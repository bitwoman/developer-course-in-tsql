/*
 * Variável - Local temporário na memória para alocar dados escalares ou tabelas.
 * 
 * - A variável é criada com a instrução DECLARE 
 * - Começa com @.
 * - Define o tipo de dado que será armazenado.
 * - Opcional, define um valor.
 * - Se não definir valor, será asSUMido NULL.
 * - Ela existirá somente no contexto de execução do códiGO ou do lote
 */

/*
 * Definindo uma variável
 */
	DECLARE @cNome VARCHAR(200)

/*
 * Definindo várias variáveis
 */
	DECLARE @nSaldo INT, @nValor NUMERIC(10)

	DECLARE @nSalario SMALLMONEY,
			@mAumento SMALLMONEY,
			@mFGTS SMALLMONEY

/*
 * Recebe estrutura no formato XML
 */
	DECLARE @xPedidoExportar XML = '<tcadlivro iIDLivro = "1" cTitulo = "Underground"/>'

/*
 * Definindo variável com o valor DEFAULT
 */
	DECLARE @cNome VARCHAR(200) = 'José da Silva'

/* A utilização de variável começa com a associação de um valor que será 
 * atribuído a variável.
 *
 * SET
 * SELECT, declarANDo direto valor na variável.
 * SELECT, carregANDo os dados do resultado de uma consulta.
 */
	USE eBook
	GO
	SET NOCOUNT ON

/*
 * Atribuindo valor escalar
 */
	DECLARE @cNome VARCHAR(200) = 'José da Silva'
	GO

	DECLARE @cNome VARCHAR(200) 
	SET @cNome = 'José da Silva'
	GO

	DECLARE @cNome VARCHAR(200) 
	SELECT @cNome = 'José da Silva'
	GO

/*
 * Atribuindo valores a partir de funções do SQL Server 
 */
	DECLARE @dDiaHoje DATETIME = GETDATE()
	PRINT @dDiaHoje 
	GO

	DECLARE @dDiaHoje DATETIME 
	SET @dDiaHoje = GETDATE()  -- CapturANDo a data e hora do momento. 
	PRINT @dDiaHoje


	DECLARE @cNomeBanco SYSNAME  
	SET @cNomeBanco = DB_NAME() -- Retorna o nome do banco de dados 
	PRINT @cNomeBanco
	GO

	DECLARE @nQtdLinhasProcessadas INT 
	SELECT * FROM tCADLivro WHERE iIDDestaque = 6
	SET @nQtdLinhasProcessadas = @@ROWCOUNT
	PRINT CAST(@nQtdLinhasProcessadas AS VARCHAR(200)) + ' linhas processadas.'
	GO


	DECLARE @cNome VARCHAR(200)  
	DECLARE @cSobreNome VARCHAR(200), @cNomeCompleto VARCHAR(200) 
	SET @cNome = 'José' 
	SET @cSobreNome  = 'da Silva' 
	SELECT @cNomeCompleto = @cNome + ' ' +@cSobreNome -- Função de atribuir
	RAISERROR(@cNomeCompleto, 10,1)
	GO

/*
 * Definindo variaveis e atribuindo o valor em lote separados: ERRO
 */
	DECLARE @cNome VARCHAR(200)  
	SET @cNome = 'Jose' 
	RAISERROR(@cNome , 10,1)
	GO

	DECLARE @cSobreNome VARCHAR(200), @cNomeCompleto VARCHAR(200) 
	SET @cSobreNome  = 'da Silva' 
	SELECT @cNomeCompleto = @cNome + ' ' +@cSobreNome 
	RAISERROR(@cNomeCompleto, 10,1)
	GO

/*
 * Carregando os dados a partir de consultas 
 */

/*
 * SET 
 */ 
	DECLARE @cNome VARCHAR(200)  
	DECLARE @mCredito SMALLMONEY 

	SET @cNome =    (SELECT cNome FROM tCADCliente WHERE iidcliente = 1)
	SET @mCredito = (SELECT mCredito FROM tCADCliente WHERE iidcliente = 1)

	PRINT @cNome 
	PRINT @mCredito 
	GO

/*
 * SELECT 
 */ 
	DECLARE @cNome VARCHAR(200)  
	DECLARE @dAniversario DATE
	DECLARE @mCredito SMALLMONEY 

	SELECT @cNome = cNome, @dAniversario = dAniversario, @mCredito = mCredito 
	FROM tCADCliente 
	WHERE iidcliente = 1 

	PRINT @cNome 
	PRINT @dAniversario
	PRINT @mCredito 
	GO

	DECLARE @cNome VARCHAR(200)  
	DECLARE @dAniversario DATE
	DECLARE @mCredito SMALLMONEY 

	SELECT @cNome = cNome, 
		   @dAniversario = dAniversario, 
		   @mCredito = mCredito 
	FROM tCADCliente 
	WHERE iidcliente = 1 

	PRINT @cNome 
	PRINT @dAniversario
	PRINT @mCredito 
	GO

/*
 * AssociANDo dados XML 
 */
	DECLARE @xEnviarPedido XML
	SET @xEnviarPedido = (SELECT * 
						  FROM tMOVPedido
						  JOIN tMOVPedidoItem ON tMOVPedido.iIDPedido = tMOVPedidoItem.iIDPedido
						  --WHERE tMOVPedido.dPedido BETWEEN '2011-06-28' AND '2011-06-29' 
						  FOR XML AUTO, ELEMENTS
						 )
	SELECT @xEnviarPedido

/*
 * Atribuição de Operação 
 */
	DECLARE @mValor INT = 50
	SET @mValor += 100 
	SELECT @mValor
	GO

/*
 * Equivalente à:
 */
	DECLARE @mValor INT = 50
	SET @mValor = @mValor + 100 
	SELECT @mValor

/* Uma das atividades para quem desenvolve códiGO é criar e
 * utilizar as variáveis. No caso do T-SQL, vamos demonstrar como usar 
 * variáveis com as instruções DML para:
 * 
 * - Recuperar dados de instruções DML
 * - Utilizar elas em filtros de pesquisas no WHERE ou HAVING
 * - Opção de usar na cláusula TOP 
 * - Utilizar na cláusula SELECT na apresentação e operações de colunas
 */

/*
 * UtilizANDo no INSERT 
 */

/*
 * Exemplo 01 - Inserir dados de um novo autor 
 */

/*
 * Variáveis para receber os dados 
 */
	DECLARE @cNome VARCHAR(260)
	DECLARE @dNascimento DATETIME

/*
 * Variáveis de controle e dados padrão 
 */
	DECLARE @iIDAutor INT = (SELECT MAX(iidAutor) FROM tCADAutor) + 1

/*
 * O ID desse Autor será o último iIDAutor da tabela tCADAutor acrescido de 1
 */ 
	DECLARE @dCadastro DATETIME = GETDATE() 

/*
 * Associa os Valores 
 */ 
	SET @cNome = 'Jose da Silva'
	SET @dNascimento = '1980-02-03' 

	INSERT INTO tCADAutor (iIDAutor, cNome, dNascimento ,dCadastro ) 
	VALUES (@iIDAutor, @cNome, @dNascimento , @dCadastro)

/*
 * Validando 
 */
	SELECT TOP 1 * FROM tCADAutor ORDER BY 1 DESC 
	GO

/*
 * Pegar o ID do Autor 17369
 */ 

/*
 * Sobre a definição do conteúdo de @iidAutor 
 * 6 formas diferentes de se obter o mesmo valor 
 */
	DECLARE @iIDAutor INT = (SELECT MAX(iidAutor) FROM tCADAutor) + 1
	PRINT @iIDAutor
	GO

	DECLARE @iIDAutor INT 
	SET @iIDAutor = (SELECT MAX(iidAutor) FROM tCADAutor) + 1
	PRINT @iIDAutor
	GO

	DECLARE @iIDAutor INT 
	SELECT @iIDAutor = MAX(iidAutor) + 1 FROM tCADAutor
	PRINT @iIDAutor
	GO

/*
 * OU 
 */ 
	DECLARE @iIDAutor INT = (SELECT TOP 1 iidAutor 
							 FROM tCADAutor 
							 ORDER BY iidautor DESC) + 1
	PRINT @iIDAutor
	GO

	DECLARE @iIDAutor INT 
	SET @iIDAutor = (SELECT TOP 1 iidAutor 
					 FROM tCADAutor 
					 ORDER BY iidautor DESC) + 1
	PRINT @iIDAutor
	GO

	DECLARE @iIDAutor INT 
	
	SELECT TOP 1 @iIDAutor  = iidAutor+1 
	FROM tCADAutor 
	ORDER BY iidautor DESC
	
	PRINT @iIDAutor
	GO 

/*
 * Utilizando no UPDATE
 */

/*
 * Exemplo 02 - Atualizando dados de autor 
 * Atualização pelo ID do autor, alterando o nome e a data de nascimento.
 */

	SELECT * FROM tCADAutor 
	WHERE iIDAutor = 17369

/*
 * Variáveis para receber os dados 
 */ 
	DECLARE @cNome VARCHAR(260) 
	DECLARE @dNascimento DATETIME

/*
 * Variáveis de controle e dados padrão 
 */ 

	DECLARE @iIDAutor INT =  17369

	SET @cNome = 'João da Silva'
	SET @dNascimento = '1982-12-10'

	UPDATE tCADAutor 
	SET cNome = @cNome,
		dNascimento = @dNascimento 
	WHERE iIDAutor = @iIDAutor

/* Pode utilizar o UPDATE para recuperar o dados que foi
 * atualizado e colocar em um variável. 
 * 
 * Cenário: atualizar o preço do livro "The Art of Dreaming"
 * da loja 32 em 7% e capturar esse novo valor.
 */
	SELECT iIDLivro, cTitulo   
	FROM tCADLivro 
	WHERE cTitulo = 'The Art of Dreaming'
 
	SELECT * FROM tRELEstoque 
	WHERE iIDLivro = 158 AND iIDLoja = 32
	-- 87,9056

	DECLARE @mValorNovo SMALLMONEY 

	UPDATE tRelEstoque SET mValor  = mValor * 1.07
	WHERE iIDLivro = 158 AND iIDLoja = 32

	SELECT @mValorNovo = mValor  
	FROM tRELEstoque 
	WHERE iIDLivro = 158 AND iIDLoja = 32

	PRINT @mValorNovo
	GO

/*
 * Repetindo o processo, mas somente utilizANDo o UPDATE. 
 * 94.06
 */ 
	DECLARE @mValorNovo SMALLMONEY 

	UPDATE tRelEstoque 
	SET @mValorNovo = mValor = mValor * 1.07
	WHERE iIDLivro = 158 AND iIDLoja = 32

	PRINT @mValorNovo
	GO

	SELECT * FROM tRELEstoque 
	WHERE iIDLivro = 158 AND iIDLoja = 32

/*
 * Determinado o valor da clausula TOP
 */
	DECLARE  @nQtdLinhas INT = 5
	SELECT TOP (@nQtdLinhas) * FROM tCADLivro

/*
 * Na apresentação dos dados pela cláusula SELECT 
 */

/*
 * Relatório para conceder aumento de R$ 100,00 no crédito dos clientes
 */ 
	DECLARE @mAumento SMALLMONEY = 100.00
	
	SELECT cNome, 
		   mCredito, 
		   mCredito + @mAumento as mNovoCredito 
	FROM tCADCliente 
	GO

/*
 * Relatório de calculando o aumento dos livros
 */ 
	DECLARE @nPercentualAumento DECIMAL(5,2) 
	SET @nPercentualAumento = 12.50

	SELECT Livro.cTitulo, 
		   Livro.nPeso , 
		   Loja.cDESCricao,
		   (Estoque.mValor * Estoque.nQuantidade) AS mValorEstoque ,
		   ((Estoque.mValor * Estoque.nQuantidade) * (1+(@nPercentualAumento)/100)) AS mValorAumento
	 FROM tRELEstoque AS Estoque
	 JOIN tCADLivro AS Livro ON (Estoque.iIDLivro = Livro.iIDLivro)
	 JOIN tCADLoja AS Loja ON (Estoque.iIDLoja = Loja.iIDLoja)
	 WHERE Livro.iIDLivro = 2354
	 
	 GO

/*
 * Utilizando variável como contador 
 */
	DECLARE @nContagem INT = 0

	SET @nContagem += 1
	PRINT @nContagem

	SET @nContagem += 1
	PRINT @nContagem

	SET @nContagem += 1
	PRINT @nContagem

	SET @nContagem += 1
	PRINT @nContagem

/*
 * - DECLARE todas as variáveis dentro da mesma região do seu código.
 * - Se possível, comentar a função de cada variável.
 * - Evite nomes que não são legíveis. Exemplo:
 */
	DECLARE @x INT 
	DECLARE @Valor MONEY 
	DECLARE @e1 INT, @e2 INT , @e3 INT 
	DECLARE @saidaA VARCHAR(10), @saidaB VARCHAR(20)

/*
 * Utilize nomes que dão sentido ao propósito da variável.
 */
	DECLARE @iDMovimento INT 
	DECLARE @nValorProduto MONEY 
	DECLARE @mEstoqueAtual INT, @nEstoqueAnterior  INT , @mEstoqueNovo INT 
	DECLARE @cRetornoNome VARCHAR(10), @cRetornoSobreNome VARCHAR(20)

/* Define corretamente os tipos de dados. Evite tipos que representam dados
 * que não são aderente ao negócio.
 */
	DECLARE @cNome nVARCHAR(1000)
	DECLARE @nValorEstoque FLOAT 
	DECLARE @nIdadeAluno BIGINT 
	DECLARE @dDataPedido VARCHAR(10)
	DECLARE @nQuantidadeEstoque CHAR(10)
	GO

/*
 * Corrigindo...
 */
	DECLARE @cNome VARCHAR(50)
	DECLARE @nValorEstoque SMALLMONEY
	DECLARE @nIdadeAluno TINYINT 
	DECLARE @dDataPedido DATE
	DECLARE @nQuantidadeEstoque SMALLINT 

/* Erros comuns na utilização de variável.
 * São três dicas para você não errar quando desenvolver com variáveis.
 */

/* Dica 1: Quando o SELECT não retorna linhas e não há dados para carregar 
 * para a variável.
 */
	SELECT * 
	FROM tRELEstoque
	WHERE iIDEstoque = 26140 OR iIDEstoque = 74823


/*
 * Quando saldo abaixo de 50, faça uma solicitação de compra 
 */
	DECLARE @nSaldoEstoque INT 

	SELECT @nSaldoEstoque = nQuantidade 
	FROM tRelEstoque
	WHERE iIDEstoque = 26140 

	PRINT @nSaldoEstoque

/*
 * Teste de erro:
 */
	SELECT @nSaldoEstoque = nQuantidade 
	FROM tRelEstoque
	WHERE iIDEstoque = 748230 /*ID errado, a consulta não retorna linhas*/
	/* e ela leva o valor da consulta anterior para a atual*/

	PRINT @nSaldoEstoque
	GO 

/*
 * Como corrigir?
 */
	DECLARE @nSaldoEstoque INT 

	SELECT @nSaldoEstoque = nQuantidade 
	FROM tRelEstoque
	WHERE iIDEstoque = 26140 

	PRINT @nSaldoEstoque
	SET @nSaldoEstoque = -1 /*Assim que usou a variável, colocar NULL.*/

	SELECT @nSaldoEstoque = nQuantidade 
	FROM tRelEstoque
	WHERE iIDEstoque = 748230

	PRINT @nSaldoEstoque
	GO
		
/*
 * OU 
 */
	DECLARE @nSaldoEstoque INT

	SET @nSaldoEstoque  = (SELECT nQuantidade 
						   FROM tRelEstoque
						   WHERE iIDEstoque = 26140)

	PRINT @nSaldoEstoque

	SET @nSaldoEstoque = (SELECT nQuantidade 
							FROM tRelEstoque
						   WHERE iIDEstoque = 748230)
	/* o SET assume automaticamente como NULL. */

	PRINT @nSaldoEstoque
	GO

/* Dica 2: Quando o SELECT retorna mais de uma linha.
 * Qual é o estoque do livro 106? 
 */
	DECLARE @nSaldoEstoque INT 

	SELECT @nSaldoEstoque = nQuantidade  
	FROM tRelEstoque 
	WHERE iIDLivro = 106 

	PRINT @nSaldoEstoque
	GO

/*
 * Analisando:
 */
	SELECT *
	FROM tRelEstoque 
	WHERE iIDLivro = 106 

	DECLARE @nSaldoEstoque INT = 0

	SELECT @nSaldoEstoque += nQuantidade  
	FROM tRelEstoque 
	WHERE iIDLivro = 106 

	PRINT @nSaldoEstoque
	GO

/*
 * Ou
 */
	DECLARE @nSaldoEstoque int = 0

	SELECT @nSaldoEstoque = SUM(nQuantidade) 
	FROM tRelEstoque 
	WHERE iIDLivro = 106 

	PRINT @nSaldoEstoque
	GO

/* Dica 3: Utilizando o SET e recuperando mais de uma linha pelo SELECT 
 */
	DECLARE @nSaldoEstoque INT 

	SET @nSaldoEstoque = (SELECT SUM(nQuantidade)
						  FROM tRelEstoque 
						  WHERE iIDLivro = 106 
						  )

	PRINT @nSaldoEstoque
	GO

/* SEM O SUM():
 * Msg 512, Level 16, State 1, Line 121
 * Subquery returned more than 1 value. 
 * This is not permitted when the subquery follows =, !=, <, <= , >, >= or 
 * when the subquery is used as an expression.
 */


/* 
 * TESTE 
 */
	DECLARE @nQuantidade INT = 100 
	DECLARE @mValor SMALLMONEY
	DECLARE @mValorEstoque SMALLMONEY = null
 
	Select @mValorEstoque = (@nQuantidade * @mValor),
		   @nQuantidade = nQuantidade, 
		   @mValor = mValor  
	FROM tRELEstoque
	WHERE iIDEstoque = 2640 
 
	SELECT @nQuantidade AS Quantidade, 
		   @mValor AS Valor, 
		   @mValorEstoque AS ValorEstoque

/* Apesar do SQL Server executar a instrução SELECT pelo conceito "ALL-AT-ONCE", 
 * onde a instrução é executada de uma só vez, a carga de conteúdo para as variáveis 
 * é executada somente uma única vez após o término da execução. Como é uma única 
 * execução, a multiplicação de @nQuantidade e @mValor estão com NULL é associado a 
 * @mValorEstoque. Depois o valor da coluna Quantidade é associado a variável 
 * @nQuantidade e por fim o valor da coluna mValor é associado a variável @mValor.
 */
