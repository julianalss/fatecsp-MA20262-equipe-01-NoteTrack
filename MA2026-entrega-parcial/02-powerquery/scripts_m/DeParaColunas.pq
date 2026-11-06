// DeParaColunas -- nomes que uma coleta futura pode trazer -> nome-alvo
let
    Tabela = #table(type table [Nome_Origem = text, Nome_Alvo = text], {
        {"Modelo",       "Modelo_Pesquisado"},
        {"Titulo",       "Titulo_Anuncio"},
        {"Título",       "Titulo_Anuncio"},
        {"Preco",        "Preco_BRL"},
        {"Preço",        "Preco_BRL"},
        {"Processador",  "CPU"},
        {"Memoria",      "RAM"},
        {"URL",          "URL_Produto"},
        {"Link",         "URL_Produto"}
    })
in
    Tabela
