// dCPU -- dimensão de processadores
let
    Fonte = cad_Etapa2{[Item = "dCPU", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"CPU_Padrao", type text}, {"Fabricante", type text}})
in
    Tipos
