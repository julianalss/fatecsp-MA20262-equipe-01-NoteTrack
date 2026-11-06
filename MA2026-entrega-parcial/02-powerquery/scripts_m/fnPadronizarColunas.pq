// fnPadronizarColunas -- nomes e ordem de colunas no formato-alvo (D10), via DeParaColunas
(tabela as table) as table =>
    let
        CabecalhosLimpos = Table.TransformColumnNames(tabela, Text.Trim),
        Pares = List.Zip({DeParaColunas[Nome_Origem], DeParaColunas[Nome_Alvo]}),
        Renomeada = Table.RenameColumns(CabecalhosLimpos, Pares, MissingField.Ignore),
        NoFormatoAlvo = Table.SelectColumns(Renomeada, ColunasAlvo, MissingField.UseNull)
    in
        NoFormatoAlvo
