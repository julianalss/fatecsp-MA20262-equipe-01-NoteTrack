// cad_CPU -- termos procurados no título (Tab_CPU da Etapa 1). A ORDEM das linhas importa.
let
    Fonte = cad_Etapa1{[Item = "Tab_CPU", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Termo", type text}, {"CPU_Padrao", type text}, {"Fabricante", type text}})
in
    Table.Buffer(Tipos)
