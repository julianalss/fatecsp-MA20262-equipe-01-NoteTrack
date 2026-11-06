// fnLimparTexto -- equivalente ao ARRUMAR da Etapa 1: troca espaço não separável,
// tira espaços das pontas e reduz espaços repetidos a um só
(texto as nullable text) as nullable text =>
    if texto = null then null
    else Text.Combine(List.Select(Text.Split(Text.Trim(Text.Replace(texto, Character.FromNumber(160), " ")), " "), each _ <> ""), " ")
