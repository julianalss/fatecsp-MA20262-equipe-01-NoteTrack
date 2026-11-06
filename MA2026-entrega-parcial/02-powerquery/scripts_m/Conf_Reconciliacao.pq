// Conf_Reconciliacao -- a diferença tem de ser zero
let
    Lidas = Table.RowCount(stg_Anuncios_Bruto),
    Aceitas = Table.RowCount(fAnuncios),
    Rejeitadas = Table.RowCount(Rejeitados),
    Resultado = #table(type table [Indicador = text, Linhas = Int64.Type], {
        {"1. Linhas lidas (todas as coletas)", Lidas},
        {"2. Aceitas em fAnuncios", Aceitas},
        {"3. Registradas em Rejeitados", Rejeitadas},
        {"4. Diferença (1 - 2 - 3): deve ser 0", Lidas - Aceitas - Rejeitadas}})
in
    Resultado
