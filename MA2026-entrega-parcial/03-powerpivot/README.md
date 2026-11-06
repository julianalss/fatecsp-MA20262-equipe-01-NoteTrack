Etapa 3 – Power Pivot e DAX

Arquivo: NoteTrack_03_PowerPivot.xlsx

Aqui a gente não limpa mais nada. O arquivo lê as tabelas prontas da Etapa 2, liga umas às outras no Modelo de Dados do Excel e cria os cálculos (medidas DAX) que respondem à nossa pergunta: quanto custa, em média, cada modelo, processador, quantidade de RAM e tipo de placa de vídeo.


Como abrir

1. Abra NoteTrack_03_PowerPivot.xlsx.
2. O parâmetro pArquivoEtapa2 guarda o caminho completo de NoteTrack_02_PowerQuery.xlsx no computador onde o arquivo foi montado. Em outro computador, ajuste esse caminho em Dados → Consultas e Conexões.
3. Clique em Dados → Atualizar Tudo e veja a aba Conferencia.

Para montar do zero, existe a macro MontarModelo.bas. Ela cria as consultas, carrega as tabelas no modelo, liga as tabelas, cria as medidas e monta as abas Validacao e Conferencia.

Alguns passos foram feitos à mão, na janela do Power Pivot: marcar o calendário como tabela de datas, ordenar os meses e a RAM pela ordem certa (janeiro antes de fevereiro, 16 GB antes de 32 GB) e esconder as colunas que só servem de ligação.


Como as tabelas se ligam

No centro fica fAnuncios, com um anúncio por linha (76). Ela se liga a cinco tabelas que descrevem o anúncio:

- dModelo: os 6 modelos, com marca e especificações de referência;
- dCPU: os processadores e o fabricante (Apple, Intel, AMD, Qualcomm);
- dRAM: as quantidades de RAM;
- dGPU: as placas de vídeo e se são integradas ou dedicadas;
- dCalendario: os dias de 2026.

A ligação com o calendário é pela data da coleta. O Mercado Livre não informa a data de cada anúncio, então usamos a data em que a coleta foi feita (23/09/2026), que vem da Etapa 1. Isso também prepara o modelo para comparar coletas futuras.

A tabela Rejeitados também está no modelo, mas solta. Ela só serve para conferir se nenhum anúncio se perdeu.

O desenho do modelo e os detalhes de cada tabela estão em docs/modelo_relacional.md.


Os cálculos

O principal é o Preço Médio. Os outros ajudam a entender ele:

- Soma Preços e Qtd Anúncios: a base do preço médio.
- Preço Mínimo e Preço Máximo: o anúncio mais barato e o mais caro.
- Preço Médio Geral: a média de todos os anúncios, ignorando qualquer filtro. Serve de referência.
- Variação vs Média Geral %: quanto um modelo (ou processador, RAM etc.) está acima ou abaixo da média geral.
- Qtd Modelos: quantos modelos aparecem no filtro.
- RAM Total (GB) e Preço por GB de RAM: quanto se paga por GB de memória (R$ 591,56 no geral).
- Preço Médio GPU Dedicada e % Anúncios GPU Dedicada: o preço com placa de vídeo dedicada e quantos anúncios têm uma (9%).

Além desses, criamos 11 medidas de conferência, que começam com "Conf". Elas contam linhas, procuram anúncio sem modelo, processador, RAM, placa de vídeo ou data, e procuram código repetido.

Todas as fórmulas estão em dax/medidas_preliminares.dax, cada uma com a pergunta que responde.


Resultados

A aba Validacao mostra, em tabelas dinâmicas ligadas ao modelo, o preço médio por modelo, processador, RAM e placa de vídeo.

Por modelo, com o anúncio mais barato, o mais caro e a comparação com a média geral:

- Acer Predator Helios Neo 16 AI: média de R$ 16.621,86 (7 anúncios), de R$ 13.999,00 a R$ 22.499,00. Fica 47,7% acima da média geral.
- Apple MacBook Pro 14 M5: média de R$ 16.385,78 (9 anúncios), de R$ 13.749,00 a R$ 20.159,00. Fica 45,6% acima.
- Lenovo ThinkPad T14 Gen 6: média de R$ 11.850,00 (9 anúncios), de R$ 10.762,00 a R$ 14.355,00. Fica 5,3% acima.
- Apple MacBook Air 13 M4: média de R$ 11.511,46 (13 anúncios), de R$ 8.035,00 a R$ 15.199,00. Fica 2,3% acima.
- Dell Pro 14: média de R$ 9.446,80 (5 anúncios), de R$ 7.990,00 a R$ 10.279,00. Fica 16,1% abaixo.
- ASUS Zenbook A14: média de R$ 8.725,58 (33 anúncios), de R$ 5.861,00 a R$ 11.408,00. Fica 22,5% abaixo.

No total, são 76 anúncios, com média de R$ 11.253,97, entre R$ 5.861,00 e R$ 22.499,00.

Placa de vídeo: com placa dedicada, a média é de R$ 16.621,86 (7 anúncios, todos do Predator). Com placa integrada, é de R$ 10.709,41 (69 anúncios).

Processador: Apple R$ 13.505,50, Intel R$ 13.328,31, AMD R$ 10.105,50 e Qualcomm R$ 8.762,59.

RAM: 16 GB R$ 10.633,82 (44 anúncios), 24 GB R$ 17.962,33 (3) e 32 GB R$ 12.657,40 (10). Em 19 anúncios o título não diz a RAM.

AMD (2 anúncios) e 24 GB (3) têm poucos anúncios, então esses números servem só de indicação.


Conferência (aba Conferencia)

A aba compara o que está no modelo com o que saiu da Etapa 2:

- 367 linhas lidas, 76 aceitas e 291 rejeitadas, iguais à Etapa 2;
- a soma dos preços (R$ 855.302,00), o número de modelos (6) e o preço médio geral (R$ 11.253,97) iguais aos da Etapa 2;
- nenhum anúncio sem modelo, processador, RAM, placa de vídeo ou data;
- nenhum código repetido nas tabelas.


Teste de linhagem

Para provar que uma mudança na Etapa 1 chega sozinha até aqui, fizemos o teste do guia em 01/11/2026. Na Etapa 1, trocamos o mínimo de anúncios por modelo de 5 para 2, só como teste. Depois atualizamos a Etapa 2 e a Etapa 3, sem digitar nada nelas.

O Dell Pro 14 Premium, que tinha 2 anúncios e estava fora, entrou no modelo:

- anúncios aceitos: de 76 para 78; rejeitados: de 291 para 289; lidos continuam 367;
- modelos em análise: de 6 para 7;
- soma dos preços: de R$ 855.302,00 para R$ 887.123,00;
- preço médio geral: de R$ 11.253,97 para R$ 11.373,37;
- Dell Pro 14 Premium com preço médio de R$ 15.910,50.

Como a coluna da Etapa 2 na aba Conferencia é fixa, a coluna Diferença mostrou na hora o que mudou: 2 anúncios, 1 modelo e R$ 31.821,00 na soma.

Depois voltamos o mínimo para 5, atualizamos a Etapa 2 e a Etapa 3, e tudo voltou para 76 anúncios, 6 modelos e diferença 0.


Capturas de tela (pasta evidencias/)

- diagrama.png: o diagrama do modelo (também copiado em docs/diagrama_modelo.png).
- gerenciar_relacoes.png: as cinco ligações.
- gerenciar_medidas.png: a lista de medidas.
- validacao.png: a aba Validacao.
- conferencia.png: a aba Conferencia.
- teste_linhagem.png: a aba Conferencia durante o teste de linhagem.

O código de cada consulta está em scripts_m/.


Decisões que vieram da Etapa 2

Caixa aberta não conta como novo, modelos de 2026 ficam fora e preço a mais de 40% da média do modelo também sai. Essas regras estão na Etapa 1 e valem para tudo o que vem depois.
