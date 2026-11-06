// dModelo -- dimensão de modelos (Tab_Modelos da Etapa 1), só colunas de cadastro
let
    Fonte = cad_Etapa1{[Item = "Tab_Modelos", Kind = "Table"]}[Data],
    Selecionadas = Table.SelectColumns(Fonte, {"Cod_Modelo", "Marca", "Modelo", "CPU_Ref", "RAM_Ref", "GPU_Ref", "GPU_Tipo"}),
    Tipos = Table.TransformColumnTypes(Selecionadas, {{"Cod_Modelo", type text}, {"Marca", type text}, {"Modelo", type text},
              {"CPU_Ref", type text}, {"RAM_Ref", type text}, {"GPU_Ref", type text}, {"GPU_Tipo", type text}}),
    // só os modelos que de fato têm anúncios na base tratada (6 na coleta atual)
    EmAnalise = Table.SelectRows(Tipos, each List.Contains(List.Buffer(List.Distinct(fAnuncios[Cod_Modelo])), [Cod_Modelo]))
in
    EmAnalise
