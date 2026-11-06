// cad_ChavesModelo -- palavras-chave que confirmam que o anúncio é do modelo pesquisado
let
    Fonte = cad_Etapa1{[Item = "Tab_Chaves_Modelo", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Cod_Modelo", type text}, {"Chave", type text}})
in
    Table.Buffer(Tipos)
