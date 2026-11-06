// fnLerAnuncios -- lê, padroniza e numera as linhas de UM arquivo de coleta
(conteudo as binary) as table =>
    let
        Arquivo = fnLerCsv(conteudo),
        Padronizada = fnPadronizarColunas(Arquivo),
        // Linha_Origem = número da linha no arquivo original (1ª linha de dados = 2), igual à Etapa 1
        ComLinha = Table.AddIndexColumn(Padronizada, "Linha_Origem", 2, 1, Int64.Type)
    in
        ComLinha
