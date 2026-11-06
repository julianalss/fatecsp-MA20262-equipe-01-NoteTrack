// dRAM -- dimensão de memória RAM (RAM_GB serve para ordenar a coluna RAM)
let
    Fonte = cad_Etapa2{[Item = "dRAM", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"RAM", type text}, {"RAM_GB", Int64.Type}})
in
    Tipos
