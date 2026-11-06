// dModelo -- dimensão de modelos (lida da Etapa 2, que leu Tab_Modelos da Etapa 1)
let
    Fonte = cad_Etapa2{[Item = "dModelo", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"Cod_Modelo", type text}, {"Marca", type text}, {"Modelo", type text}, {"CPU_Ref", type text},
        {"RAM_Ref", type text}, {"GPU_Ref", type text}, {"GPU_Tipo", type text}})
in
    Tipos
