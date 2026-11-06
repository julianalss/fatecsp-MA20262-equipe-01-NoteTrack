// cad_DeParaModelo -- de-para com chave em MAIÚSCULAS e sem espaços nas pontas
let
    Fonte = cad_Etapa1{[Item = "Tab_DePara_Modelo", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {{"Nome_Origem", type text}, {"Cod_Modelo", type text}}),
    ComChave = Table.AddColumn(Tipos, "Chave_Modelo", each Text.Upper(fnLimparTexto([Nome_Origem])), type text)
in
    ComChave
