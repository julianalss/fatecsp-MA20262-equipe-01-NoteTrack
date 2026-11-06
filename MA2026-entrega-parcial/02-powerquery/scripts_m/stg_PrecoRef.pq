// stg_PrecoRef -- preço de referência de cada modelo: média dos anúncios novos e válidos (= Tab_Modelos[Preco_Ref] da Etapa 1)
let
    Agrupada = Table.Group(stg_Anuncios_Novos, {"Cod_Modelo"}, {{"Preco_Ref", each List.Average([Preco_BRL]), type number}})
in
    Table.Buffer(Agrupada)
