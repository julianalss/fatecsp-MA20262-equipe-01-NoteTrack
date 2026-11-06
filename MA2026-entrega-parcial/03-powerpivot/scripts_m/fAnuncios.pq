// fAnuncios -- tabela fato (cópia fiel da fAnuncios da Etapa 2, com tipos): um anúncio válido por linha
let
    Fonte = cad_Etapa2{[Item = "fAnuncios", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"ID_Anuncio", type text}, {"Cod_Modelo", type text}, {"Titulo_Anuncio", type text},
        {"Preco_BRL", Currency.Type}, {"CPU_Padrao", type text}, {"RAM", type text}, {"RAM_GB", Int64.Type},
        {"Armaz_GB", Int64.Type}, {"GPU_Padrao", type text}, {"GPU_Tipo", type text}, {"URL_Produto", type text},
        {"Data_Coleta", type date}, {"Arquivo_Origem", type text}, {"Linha_Origem", Int64.Type}})
in
    Tipos
