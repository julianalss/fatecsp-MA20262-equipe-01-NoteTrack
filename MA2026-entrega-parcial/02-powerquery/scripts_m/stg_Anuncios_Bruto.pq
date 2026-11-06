// stg_Anuncios_Bruto -- todos os arquivos de coleta da pasta, padronizados e empilhados
let
    Origem = Folder.Files(pPastaAnuncios),
    SoCsv = Table.SelectRows(Origem, each Text.Lower([Extension]) = ".csv"
                                     and not Text.StartsWith([Name], "~$")),
    ComDados = Table.AddColumn(SoCsv, "Dados", each fnLerAnuncios([Content])),
    SoNomeEDados = Table.SelectColumns(ComDados, {"Name", "Dados"}),
    Renomeada = Table.RenameColumns(SoNomeEDados, {{"Name", "Arquivo_Origem"}}),
    Anexada = Table.ExpandTableColumn(Renomeada, "Dados", ColunasAlvo & {"Linha_Origem"}),
    Ordenada = Table.Sort(Anexada, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})
in
    Ordenada
