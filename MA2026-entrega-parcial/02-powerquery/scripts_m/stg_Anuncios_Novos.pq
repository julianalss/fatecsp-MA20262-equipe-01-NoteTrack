// stg_Anuncios_Novos -- anúncios únicos, do modelo pesquisado, lançados em 2025 e novos (antes do filtro de preço)
let
    Origem = stg_Anuncios_Bruto,

    // ---------- Atividade 3: linhas em branco, chave vazia, duplicatas ----------
    SemLinhasEmBranco = Table.SelectRows(Origem, each not List.IsEmpty(
        List.RemoveMatchingItems(Record.FieldValues(Record.SelectFields(_, ColunasAlvo)), {"", null}))),
    SemURLVazia = Table.SelectRows(SemLinhasEmBranco, each [URL_Produto] <> null and Text.Trim([URL_Produto]) <> ""),
    SemTituloVazio = Table.SelectRows(SemURLVazia, each [Titulo_Anuncio] <> null and Text.Trim([Titulo_Anuncio]) <> ""),

    // ---------- Atividade 4: tipo do preço (pt-BR) ----------
    PrecoNumero = Table.TransformColumns(SemTituloVazio, {{"Preco_BRL", fnPreco, type nullable number}}),
    SemPrecoInvalido = Table.SelectRows(PrecoNumero, each [Preco_BRL] <> null and [Preco_BRL] > 0),

    // mesma URL = mesmo anúncio: fica a 1ª ocorrência (menor Linha_Origem), como na Etapa 1
    OrdemOriginal = Table.Buffer(Table.Sort(SemPrecoInvalido, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})),
    SemDuplicatas = Table.Distinct(OrdemOriginal, {"URL_Produto"}),

    // ---------- Atividade 5: textos ----------
    TextosLimpos = Table.TransformColumns(SemDuplicatas,
        {{"Modelo_Pesquisado", fnLimparTexto, type text}, {"Titulo_Anuncio", fnLimparTexto, type text}, {"URL_Produto", Text.Trim, type text}}),
    ComBusca = Table.AddColumn(TextosLimpos, "Busca", each fnTextoBusca([Titulo_Anuncio]), type text),

    // ---------- Atividade 6: mesclagem com o de-para de modelos ----------
    ChaveModelo = Table.AddColumn(ComBusca, "Chave_Modelo", each Text.Upper([Modelo_Pesquisado]), type text),
    MesclaModelo = Table.NestedJoin(ChaveModelo, {"Chave_Modelo"}, cad_DeParaModelo, {"Chave_Modelo"}, "DePara", JoinKind.LeftOuter),
    ExpandeModelo = Table.ExpandTableColumn(MesclaModelo, "DePara", {"Cod_Modelo"}, {"Cod_Modelo"}),
    ComModelo = Table.SelectRows(ExpandeModelo, each [Cod_Modelo] <> null),

    // o título precisa conter uma palavra-chave do modelo pesquisado (Confere_Modelo da Etapa 1)
    ModeloConfere = Table.SelectRows(ComModelo, each
        let
            Linha = _,
            Chaves = Table.SelectRows(cad_ChavesModelo, (c) => c[Cod_Modelo] = Linha[Cod_Modelo])[Chave]
        in
            List.AnyTrue(List.Transform(Chaves, (k) => Text.Contains(Linha[Busca], k)))),

    // recorte do projeto: só modelo lançado em 2025 (variantes de outro ano, como o M5 Max, saem)
    NoRecorte = Table.SelectRows(ModeloConfere, each
        let
            Linha = _,
            Termos = Table.SelectRows(cad_ForaRecorte, (f) => f[Cod_Modelo] = Linha[Cod_Modelo])[Termo]
        in
            not List.AnyTrue(List.Transform(Termos, (t) => Text.Contains(Linha[Busca], t)))),

    // recorte do projeto: só notebook novo (recondicionado e caixa aberta saem)
    SoNovos = Table.SelectRows(NoRecorte, each not Text.Contains([Busca], "recondicionado")
                                               and not Text.Contains([Busca], "caixa aberta"))
in
    SoNovos
