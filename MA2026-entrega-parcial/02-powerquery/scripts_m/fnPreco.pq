// fnPreco -- " R$ 17.990,00 " (texto) -> 17990 (número), lido em pt-BR (defeito de tipo, D6)
(valor as any) as nullable number =>
    let
        Resultado =
            if valor = null then null
            else if valor is number then valor
            else
                let
                    Texto = Text.Trim(Text.Replace(Text.Replace(Text.From(valor), "R$", ""), Character.FromNumber(160), ""))
                in
                    if Texto = "" then null else Number.From(Texto, "pt-BR")
    in
        try Resultado otherwise null
