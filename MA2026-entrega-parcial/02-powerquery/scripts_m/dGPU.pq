// dGPU -- dimensão de placas de vídeo (Dim GPU da proposta)
let
    Pares = Table.Distinct(Table.SelectColumns(cad_GPU, {"GPU_Padrao", "GPU_Tipo"}), {"GPU_Padrao"}),
    Renomeada = Table.RenameColumns(Pares, {{"GPU_Tipo", "Tipo_da_GPU"}}),
    ComNaoIdentificado = Table.Combine({Renomeada, #table(type table [GPU_Padrao = text, Tipo_da_GPU = text], {{"Não identificado", "Não identificado"}})}),
    SoUsados = Table.SelectRows(ComNaoIdentificado, each List.Contains(List.Buffer(List.Distinct(fAnuncios[GPU_Padrao])), [GPU_Padrao])),
    Ordenada = Table.Sort(SoUsados, {{"GPU_Padrao", Order.Ascending}})
in
    Ordenada
