// Conf_Modelos -- anúncios e preço médio por modelo (deve bater com Tab_Modelos[Preco_Ref] da Etapa 1)
let
    Agrupada = Table.Group(fAnuncios, {"Cod_Modelo"}, {
        {"Anuncios", each Table.RowCount(_), Int64.Type},
        {"Preco_Medio", each Number.Round(List.Average([Preco_BRL]), 2), type number}}),
    ComNome = Table.NestedJoin(Agrupada, {"Cod_Modelo"}, dModelo, {"Cod_Modelo"}, "M", JoinKind.LeftOuter),
    Expandida = Table.ExpandTableColumn(ComNome, "M", {"Modelo"}, {"Modelo"}),
    Ordenada = Table.Sort(Table.SelectColumns(Expandida, {"Cod_Modelo", "Modelo", "Anuncios", "Preco_Medio"}), {{"Cod_Modelo", Order.Ascending}})
in
    Ordenada
