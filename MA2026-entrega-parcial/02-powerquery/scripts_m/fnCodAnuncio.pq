// fnCodAnuncio -- extrai o código do anúncio (MLB...) da URL, como a coluna Cod_Anuncio da Etapa 1
(url as nullable text) as nullable text =>
    if url = null or Text.PositionOf(url, "/MLB") < 0 then null
    else
        let
            Trecho = Text.Middle(url, Text.PositionOf(url, "/MLB") + 1, 30) & "-",
            // 1º hífen a partir do 5º caractere (pula o hífen de "MLB-")
            Fim = 4 + Text.PositionOf(Text.Range(Trecho, 4), "-"),
            Codigo = Text.Remove(Text.Start(Trecho, Fim), "-")
        in
            Codigo
