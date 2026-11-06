// fnLerCsv -- lê um CSV da coleta (separador ;) em UTF-8 (65001): resolve a codificação
// corrompida registrada na auditoria da Etapa 1
(conteudo as binary) as table =>
    let
        Csv = Csv.Document(conteudo, [Delimiter = ";", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
        ComCabecalho = Table.PromoteHeaders(Csv, [PromoteAllScalars = true])
    in
        ComCabecalho
