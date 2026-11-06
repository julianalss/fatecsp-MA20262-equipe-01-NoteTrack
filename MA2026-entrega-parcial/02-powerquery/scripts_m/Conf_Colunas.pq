// Conf_Colunas -- colunas de cada arquivo que não foram mapeadas (deve ficar vazio)
let
    Origem = Folder.Files(pPastaAnuncios),
    SoCsv = Table.SelectRows(Origem, each Text.Lower([Extension]) = ".csv" and not Text.StartsWith([Name], "~$")),
    Pares = List.Zip({DeParaColunas[Nome_Origem], DeParaColunas[Nome_Alvo]}),
    NaoMapeadas = Table.AddColumn(SoCsv, "Colunas_Nao_Mapeadas", each
        let
            Cab = Table.ColumnNames(Table.RenameColumns(Table.TransformColumnNames(fnLerCsv([Content]), Text.Trim), Pares, MissingField.Ignore))
        in
            Text.Combine(List.Difference(Cab, ColunasAlvo), ", "), type text),
    Resultado = Table.SelectColumns(NaoMapeadas, {"Name", "Colunas_Nao_Mapeadas"})
in
    Resultado
