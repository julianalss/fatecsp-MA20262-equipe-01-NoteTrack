// dRAM -- dimensão de memória (Dim Memória RAM da proposta); RAM_GB serve para ordenar
let
    Pares = Table.Distinct(Table.SelectColumns(fAnuncios, {"RAM", "RAM_GB"})),
    Ordenada = Table.Sort(Pares, {{"RAM_GB", Order.Ascending}})
in
    Ordenada
