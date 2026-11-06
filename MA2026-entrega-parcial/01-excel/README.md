Etapa 1 – Excel

Arquivo: NoteTrack_01_Excel.xlsx

Aqui a gente pegou os 367 anúncios da coleta e organizou tudo no Excel, só com fórmulas.

A regra que seguimos foi não apagar nem alterar nada do original. Tudo o que foi corrigido ou descoberto aparece em colunas novas, e cada problema fica anotado numa aba de auditoria.


As abas

- Bruto: a coleta do jeito que veio, sem nenhuma alteração.
- Tratado: a tabela Tab_Anuncios, com as colunas originais e as colunas que a gente calculou.
- Cadastros: as tabelas de apoio que as fórmulas consultam. São os modelos de 2025, os nomes alternativos de cada modelo, as palavras-chave para conferir o modelo, os termos de processador, RAM, armazenamento e placa de vídeo, as correções de acento e os parâmetros da análise.
- Auditoria: uma linha para cada problema encontrado, com a linha de origem, o que aconteceu e o que fazer. No topo, um painel compara o que as fórmulas detectaram com o que foi anotado.


Os problemas da coleta e o que fizemos

Outros modelos na busca

Procuramos "Dell Pro 14 Premium" e vieram Dell Latitude de 2018, por exemplo. Para cada modelo cadastramos palavras-chave, e uma fórmula confere se o título do anúncio tem alguma delas. Se não tiver, o anúncio é marcado como "Divergente". Foram 272 casos.

Processador, RAM e placa de vídeo vazios

Essas três colunas vieram vazias em todos os anúncios, então tiramos as informações do título. Temos tabelas com termos como " i7", " 268v", " 16gb" e " rtx 5070", e a fórmula procura esses termos no título. Quando não acha nada, escreve "Não identificado".

Acentos estragados

85 títulos vieram com coisas como "PortÃ¡til", porque o arquivo foi aberto com a codificação errada. Uma tabela de correções troca esses pedaços pelo texto certo.

Anúncios repetidos

49 anúncios aparecem mais de uma vez, com a mesma URL. O primeiro fica e os outros são marcados como "Duplicado".

Recondicionados e caixa aberta

Encontramos 93 recondicionados e 8 de caixa aberta. Como o projeto é sobre notebook novo, os dois ficam marcados para sair na Etapa 2.

Modelo de 2026 no meio

Na busca do MacBook Pro 14 M5 apareceu a versão com M5 Max, que é de 2026. Criamos a tabela Tab_Fora_Recorte com essas variantes, e o anúncio fica marcado como "Fora do recorte".

Preço muito fora da média

Para cada modelo calculamos o preço médio só com os anúncios bons (novos, do modelo certo e sem repetição). Se um anúncio está mais de 40% acima ou abaixo dessa média, ele é marcado. Os 2 casos encontrados também eram anúncios repetidos.

Modelos com poucos anúncios

Só analisamos modelos com pelo menos 5 anúncios válidos. O Dell Pro 14 Premium ficou com 2 e saiu.

Os valores 40%, 5 anúncios e a data da coleta (23/09/2026) ficam na tabela Tab_Parametros. Se a equipe mudar de ideia, é só trocar ali.


Fórmulas principais

- PROCX, para achar o código do modelo pelo nome pesquisado e trazer dados do cadastro.
- ARRUMAR e SUBSTITUIR, para limpar espaços e acentos.
- SOMARPRODUTO com LOCALIZAR, para conferir se o título tem alguma palavra-chave do modelo.
- PROC(2;1/ÉNÚM(LOCALIZAR(...))), para achar no título o termo de processador, RAM ou placa de vídeo. Ela devolve o último termo da tabela que aparece no título, por isso os termos mais específicos ficam embaixo.
- CONT.SES, para marcar repetidos.
- MÉDIASES, para o preço médio de cada modelo.
- UNIRTEXTO, para juntar numa coluna todos os problemas de cada anúncio.

Também tem validação de dados (listas e preço maior que zero) e formatação condicional para destacar os problemas.


Resultado

Dos 367 anúncios, 95 são do modelo pesquisado, e um deles é o de 2026. Depois de tirar repetidos, recondicionados, caixa aberta e o modelo com poucos anúncios, ficam 76 anúncios de 6 modelos:

- ASUS Zenbook A14: 33
- Apple MacBook Air 13 M4: 13
- Apple MacBook Pro 14 M5: 9
- Lenovo ThinkPad T14 Gen 6: 9
- Acer Predator Helios Neo 16 AI: 7
- Dell Pro 14: 5

Cinco modelos pesquisados não tiveram nenhum anúncio aproveitável: Alienware 16 Area-51, Legion Pro 5 Gen 10, ROG Zephyrus G14, Swift Edge 14 AI e MacBook Air 15 M4. A busca por texto do Mercado Livre trouxe muita coisa errada. Numa próxima coleta, vale filtrar pelos campos de marca, modelo e condição do anúncio, em vez de só pelo texto.

A auditoria fecha com 881 problemas encontrados e 881 anotados, e nenhum erro de fórmula.

O arquivo precisa do Excel 365 ou 2021, por causa do PROCX e do UNIRTEXTO.
