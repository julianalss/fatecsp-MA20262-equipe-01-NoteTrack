// cad_RAM -- termos procurados no título (Tab_RAM da Etapa 1). A ORDEM das linhas importa.
let
    Fonte = cad_Etapa1{[Item = "Tab_RAM", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Termo", type text}, {"RAM_GB", Int64.Type}})
in
    Table.Buffer(Tipos)
