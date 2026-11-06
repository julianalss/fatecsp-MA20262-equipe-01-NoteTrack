// cad_ForaRecorte -- variantes de um modelo de 2025 que foram lançadas em outro ano (Tab_Fora_Recorte da Etapa 1)
let
    Fonte = cad_Etapa1{[Item = "Tab_Fora_Recorte", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Cod_Modelo", type text}, {"Termo", type text}, {"Motivo", type text}})
in
    Table.Buffer(Tipos)
