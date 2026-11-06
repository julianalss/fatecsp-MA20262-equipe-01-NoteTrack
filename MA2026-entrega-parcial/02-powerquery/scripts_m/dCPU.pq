// dCPU -- dimensão de processadores (Dim Processador da proposta)
let
    Pares = Table.Distinct(Table.SelectColumns(cad_CPU, {"CPU_Padrao", "Fabricante"})),
    ComNaoIdentificado = Table.Combine({Pares, #table(type table [CPU_Padrao = text, Fabricante = text], {{"Não identificado", "Não identificado"}})}),
    SoUsados = Table.SelectRows(ComNaoIdentificado, each List.Contains(List.Buffer(List.Distinct(fAnuncios[CPU_Padrao])), [CPU_Padrao])),
    Ordenada = Table.Sort(SoUsados, {{"Fabricante", Order.Ascending}, {"CPU_Padrao", Order.Ascending}})
in
    Ordenada
