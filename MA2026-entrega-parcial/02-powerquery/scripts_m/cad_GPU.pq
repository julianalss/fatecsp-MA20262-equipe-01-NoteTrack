// cad_GPU -- termos procurados no título (Tab_GPU da Etapa 1). A ORDEM das linhas importa.
let
    Fonte = cad_Etapa1{[Item = "Tab_GPU", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Termo", type text}, {"GPU_Padrao", type text}, {"GPU_Tipo", type text}})
in
    Table.Buffer(Tipos)
