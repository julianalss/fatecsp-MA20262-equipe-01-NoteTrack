// fAnuncios -- tabela fato: um anúncio válido por linha (base da análise de preço médio)
let
    Origem = stg_Anuncios_Novos,

    // anúncio com preço mais de pLimiteDesvio (40%) acima ou abaixo da referência do modelo sai
    MesclaRef = Table.NestedJoin(Origem, {"Cod_Modelo"}, stg_PrecoRef, {"Cod_Modelo"}, "Ref", JoinKind.LeftOuter),
    ExpandeRef = Table.ExpandTableColumn(MesclaRef, "Ref", {"Preco_Ref"}, {"Preco_Ref"}),
    DentroDoLimite = Table.SelectRows(ExpandeRef, each Number.Abs([Preco_BRL] / [Preco_Ref] - 1) <= pLimiteDesvio),

    // só modelos com pelo menos pMinAnuncios anúncios válidos (5)
    Contagem = Table.Group(DentroDoLimite, {"Cod_Modelo"}, {{"Anuncios_Modelo", each Table.RowCount(_), Int64.Type}}),
    MesclaContagem = Table.NestedJoin(DentroDoLimite, {"Cod_Modelo"}, Contagem, {"Cod_Modelo"}, "Cont", JoinKind.LeftOuter),
    ExpandeContagem = Table.ExpandTableColumn(MesclaContagem, "Cont", {"Anuncios_Modelo"}, {"Anuncios_Modelo"}),
    NoMinimo = Table.SelectRows(ExpandeContagem, each [Anuncios_Modelo] >= pMinAnuncios),
    // as colunas CPU, RAM e GPU da coleta vêm vazias: saem antes de criar as versões extraídas do título
    SemColunasVazias = Table.RemoveColumns(NoMinimo, {"CPU", "RAM", "GPU"}),

    // ---------- Atividade 7: colunas personalizadas (especificações extraídas do título) ----------
    TermosCPU = List.Buffer(cad_CPU[Termo]), ValoresCPU = List.Buffer(cad_CPU[CPU_Padrao]),
    TermosRAM = List.Buffer(cad_RAM[Termo]), ValoresRAM = List.Buffer(cad_RAM[RAM_GB]),
    TermosArm = List.Buffer(cad_Armazenamento[Termo]), ValoresArm = List.Buffer(cad_Armazenamento[Armaz_GB]),
    TermosGPU = List.Buffer(cad_GPU[Termo]), ValoresGPU = List.Buffer(cad_GPU[GPU_Padrao]), TiposGPU = List.Buffer(cad_GPU[GPU_Tipo]),
    TipoGPUModelo = Table.Buffer(Table.SelectColumns(cad_Etapa1{[Item = "Tab_Modelos", Kind = "Table"]}[Data], {"Cod_Modelo", "GPU_Tipo"})),

    ComCPU = Table.AddColumn(SemColunasVazias, "CPU_Padrao", each
        let v = fnExtrairTermo([Busca], TermosCPU, ValoresCPU) in if v = null then "Não identificado" else v, type text),
    ComRAM = Table.AddColumn(ComCPU, "RAM_GB", each fnExtrairTermo([Busca], TermosRAM, ValoresRAM), Int64.Type),
    ComRAMTexto = Table.AddColumn(ComRAM, "RAM", each if [RAM_GB] = null then "Não identificado" else Text.From([RAM_GB]) & " GB", type text),
    ComArm = Table.AddColumn(ComRAMTexto, "Armaz_GB", each fnExtrairTermo([Busca], TermosArm, ValoresArm), Int64.Type),
    ComGPU = Table.AddColumn(ComArm, "GPU_Padrao", each
        let v = fnExtrairTermo([Busca], TermosGPU, ValoresGPU) in if v = null then "Não identificado" else v, type text),
    // GPU_Tipo: do título; se o título não diz, do cadastro do modelo (o modelo já foi conferido)
    ComTipoGPU = Table.AddColumn(ComGPU, "GPU_Tipo", each
        let
            DoTitulo = fnExtrairTermo([Busca], TermosGPU, TiposGPU),
            Cod = [Cod_Modelo],
            DoCadastro = Table.SelectRows(TipoGPUModelo, (m) => m[Cod_Modelo] = Cod){0}[GPU_Tipo]
        in
            if DoTitulo <> null then DoTitulo else DoCadastro, type text),
    ComID = Table.AddColumn(ComTipoGPU, "ID_Anuncio", each fnCodAnuncio([URL_Produto]), type text),
    // data da coleta (Tab_Parametros da Etapa 1): liga o anúncio ao calendário na Etapa 3
    ComData = Table.AddColumn(ComID, "Data_Coleta", each pDataColeta, type date),

    FormatoFinal = Table.SelectColumns(ComData,
        {"ID_Anuncio", "Cod_Modelo", "Titulo_Anuncio", "Preco_BRL", "CPU_Padrao", "RAM", "RAM_GB",
         "Armaz_GB", "GPU_Padrao", "GPU_Tipo", "URL_Produto", "Data_Coleta", "Arquivo_Origem", "Linha_Origem"}),
    Ordenada = Table.Sort(FormatoFinal, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})
in
    Ordenada
