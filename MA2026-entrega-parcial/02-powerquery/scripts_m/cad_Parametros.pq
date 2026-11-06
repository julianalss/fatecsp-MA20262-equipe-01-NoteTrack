// cad_Parametros -- Tab_Parametros da Etapa 1 (Limite_Desvio, Min_Anuncios, Data_Coleta)
let
    Fonte = cad_Etapa1{[Item = "Tab_Parametros", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Parametro", type text}, {"Valor", type number}})
in
    Tipos
