// Rejeitados -- auditoria: tudo como texto, exceto o número da linha (fora da estrela, só para contagens)
let
    Fonte = cad_Etapa2{[Item = "Rejeitados", Kind = "Table"]}[Data],
    TudoTexto = Table.TransformColumnTypes(Fonte, List.Transform(Table.ColumnNames(Fonte), each {_, type text})),
    Tipos = Table.TransformColumnTypes(TudoTexto, {{"Linha_Origem", Int64.Type}})
in
    Tipos
