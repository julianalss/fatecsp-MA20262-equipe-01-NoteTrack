// dGPU -- dimensão de placas de vídeo
let
    Fonte = cad_Etapa2{[Item = "dGPU", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"GPU_Padrao", type text}, {"Tipo_da_GPU", type text}})
in
    Tipos
