// cad_Armazenamento -- termos procurados no título (Tab_Armazenamento da Etapa 1). A ORDEM das linhas importa.
let
    Fonte = cad_Etapa1{[Item = "Tab_Armazenamento", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Termo", type text}, {"Armaz_GB", Int64.Type}})
in
    Table.Buffer(Tipos)
