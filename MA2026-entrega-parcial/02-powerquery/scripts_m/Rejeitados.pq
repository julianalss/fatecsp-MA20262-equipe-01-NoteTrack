// Rejeitados -- toda linha lida que não chegou a fAnuncios, com o motivo
let
    Origem = stg_Anuncios_Bruto,
    // 1. linhas lidas que NÃO estão em fAnuncios (junção anti esquerda)
    Mescla = Table.NestedJoin(Origem, {"Arquivo_Origem", "Linha_Origem"}, fAnuncios, {"Arquivo_Origem", "Linha_Origem"}, "Aceita", JoinKind.LeftAnti),
    SoRejeitadas = Table.RemoveColumns(Mescla, {"Aceita"}),

    // 2. apoio ao diagnóstico
    ChaveLinha = (r) => r[Arquivo_Origem] & "|" & Text.From(r[Linha_Origem]),
    ComDados = Table.SelectRows(Origem, each [URL_Produto] <> null and Text.Trim([URL_Produto]) <> ""
                                         and [Titulo_Anuncio] <> null and Text.Trim([Titulo_Anuncio]) <> ""
                                         and fnPreco([Preco_BRL]) <> null and fnPreco([Preco_BRL]) > 0),
    Mantidas = Table.Distinct(Table.Buffer(Table.Sort(ComDados, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})), {"URL_Produto"}),
    LinhasMantidas = List.Buffer(Table.TransformRows(Mantidas, ChaveLinha)),
    Modelos = List.Buffer(cad_DeParaModelo[Chave_Modelo]),
    DePara = Table.Buffer(cad_DeParaModelo),
    ModelosEmAnalise = List.Buffer(List.Distinct(fAnuncios[Cod_Modelo])),
    Referencia = stg_PrecoRef,
    Vazio = (v) => v = null or Text.Trim(Text.From(v)) = "",

    // 3. mesma ordem das regras de fAnuncios: o primeiro teste que falha é o motivo
    Diagnostico = (r as record) as text =>
        let
            Valores = List.RemoveMatchingItems(Record.FieldValues(Record.SelectFields(r, ColunasAlvo)), {"", null}),
            Busca = fnTextoBusca(fnLimparTexto(r[Titulo_Anuncio])),
            Chave = if r[Modelo_Pesquisado] = null then null else Text.Upper(fnLimparTexto(r[Modelo_Pesquisado])),
            Cod = if Chave = null or not List.Contains(Modelos, Chave) then null else DePara{[Chave_Modelo = Chave]}[Cod_Modelo],
            Chaves = if Cod = null then {} else Table.SelectRows(cad_ChavesModelo, (c) => c[Cod_Modelo] = Cod)[Chave],
            ForaRecorte = if Cod = null then {} else Table.SelectRows(cad_ForaRecorte, (f) => f[Cod_Modelo] = Cod)[Termo],
            Ref = if Cod = null or Table.IsEmpty(Table.SelectRows(Referencia, (x) => x[Cod_Modelo] = Cod)) then null
                  else Table.SelectRows(Referencia, (x) => x[Cod_Modelo] = Cod){0}[Preco_Ref]
        in
            if List.IsEmpty(Valores) then "Linha em branco"
            else if Vazio(r[URL_Produto]) then "URL vazia"
            else if Vazio(r[Titulo_Anuncio]) then "Título vazio"
            else if fnPreco(r[Preco_BRL]) = null or fnPreco(r[Preco_BRL]) <= 0 then "Preço inválido"
            else if not List.Contains(LinhasMantidas, ChaveLinha(r)) then "Anúncio duplicado"
            else if Cod = null then "Modelo sem correspondência"
            else if not List.AnyTrue(List.Transform(Chaves, (k) => Text.Contains(Busca, k))) then "Modelo divergente do pesquisado"
            else if List.AnyTrue(List.Transform(ForaRecorte, (t) => Text.Contains(Busca, t))) then "Modelo fora do recorte (não lançado em 2025)"
            else if Text.Contains(Busca, "recondicionado") then "Anúncio recondicionado"
            else if Text.Contains(Busca, "caixa aberta") then "Anúncio de caixa aberta"
            else if Ref <> null and Number.Abs(fnPreco(r[Preco_BRL]) / Ref - 1) > pLimiteDesvio then "Preço fora do limite de desvio"
            else if not List.Contains(ModelosEmAnalise, Cod) then "Modelo abaixo do mínimo de anúncios"
            else "Outro (verificar)",
    ComMotivo = Table.AddColumn(SoRejeitadas, "Motivo", each Diagnostico(_), type text),
    Ordenada = Table.Sort(ComMotivo, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})
in
    Ordenada
