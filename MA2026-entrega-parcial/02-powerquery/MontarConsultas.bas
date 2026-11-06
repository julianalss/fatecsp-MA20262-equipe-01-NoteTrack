Attribute VB_Name = "MontarConsultas"
'==============================================================================
' NoteTrack - Etapa 2 (Power Query)
' Cria no arquivo ativo todas as consultas da pasta scripts_m (na ordem de
' _ordem.txt) e carrega as consultas de saída e de conferência em planilhas.
' Uso: abra NoteTrack_02_PowerQuery.xlsx (em branco) > Alt+F11 > Arquivo >
'      Importar arquivo... (este .bas) > F5 em MontarConsultasNoteTrack.
' Depois salve como .xlsx (o Excel avisa que o módulo VBA será descartado: Sim).
'==============================================================================
Option Explicit

Public Sub MontarConsultasNoteTrack()
    Dim wb As Workbook, pasta As String, linhas() As String, i As Long
    Dim partes() As String, nome As String, carga As String, formula As String
    Dim pPasta As String, pEtapa1 As String

    Set wb = ActiveWorkbook
    pasta = EscolherPasta(wb.Path & "\scripts_m\")
    If pasta = "" Then Exit Sub
    If Dir(pasta & "_ordem.txt") = "" Then
        MsgBox "Não encontrei _ordem.txt em " & pasta, vbCritical
        Exit Sub
    End If

    pPasta = InputBox("Pasta com o(s) CSV da coleta (pPastaAnuncios):", "NoteTrack", "C:\NoteTrack\dados_brutos\anuncios\")
    If pPasta = "" Then Exit Sub
    If Right(pPasta, 1) <> "\" Then pPasta = pPasta & "\"
    pEtapa1 = InputBox("Arquivo da Etapa 1 (pArquivoEtapa1):", "NoteTrack", "C:\NoteTrack\01_excel\NoteTrack_01_Excel.xlsx")
    If pEtapa1 = "" Then Exit Sub

    Application.ScreenUpdating = False
    wb.Queries.FastCombine = True   ' = Ignorar os Níveis de Privacidade (guia, seção 2.2)

    linhas = Split(Replace(LerUtf8(pasta & "_ordem.txt"), vbCr, ""), vbLf)
    ' 1) cria (ou recria) todas as consultas
    For i = LBound(linhas) To UBound(linhas)
        If Trim(linhas(i)) <> "" Then
            partes = Split(linhas(i), ";")
            nome = partes(0)
            formula = LerUtf8(pasta & nome & ".pq")
            If nome = "pPastaAnuncios" Then formula = TrocarTextoParametro(formula, pPasta)
            If nome = "pArquivoEtapa1" Then formula = TrocarTextoParametro(formula, pEtapa1)
            ApagarConsulta wb, nome
            wb.Queries.Add Name:=nome, Formula:=formula, Description:="Grupo " & partes(1)
        End If
    Next i

    ' 2) carrega as saídas, cada uma em sua planilha, e as conferências na aba Conferencia
    For i = LBound(linhas) To UBound(linhas)
        If Trim(linhas(i)) <> "" Then
            partes = Split(linhas(i), ";")
            nome = partes(0): carga = partes(2)
            If carga = "tabela" Then
                CarregarConsulta wb, nome, ObterPlanilha(wb, nome), "A1"
            ElseIf Left(carga, 12) = "conferencia:" Then
                CarregarConsulta wb, nome, ObterPlanilha(wb, "Conferencia"), Mid(carga, 13)
            End If
        End If
    Next i

    On Error Resume Next
    Application.DisplayAlerts = False
    wb.Worksheets("Planilha1").Delete
    wb.Worksheets("Sheet1").Delete
    Application.DisplayAlerts = True
    On Error GoTo 0
    Application.ScreenUpdating = True
    wb.Worksheets("Conferencia").Activate
    MsgBox "Consultas criadas e carregadas." & vbCrLf & _
           "Confira a aba Conferencia: a Diferença tem de ser 0.", vbInformation, "NoteTrack"
End Sub

Private Sub CarregarConsulta(wb As Workbook, nome As String, ws As Worksheet, destino As String)
    Dim lo As ListObject
    For Each lo In ws.ListObjects
        If lo.Name = nome Then lo.Delete: Exit For
    Next lo
    Set lo = ws.ListObjects.Add(SourceType:=0, Source:= _
        "OLEDB;Provider=Microsoft.Mashup.OleDb.1;Data Source=$Workbook$;Location=" & nome & ";Extended Properties=""""", _
        Destination:=ws.Range(destino))
    With lo.QueryTable
        .CommandType = xlCmdSql
        .CommandText = Array("SELECT * FROM [" & nome & "]")
        .RowNumbers = False
        .FillAdjacentFormulas = False
        .PreserveFormatting = True
        .RefreshOnFileOpen = False
        .BackgroundQuery = False
        .RefreshStyle = xlInsertDeleteCells
        .SavePassword = False
        .SaveData = True
        .AdjustColumnWidth = True
        .RefreshPeriod = 0
        .PreserveColumnInfo = True
        .ListObject.DisplayName = nome
        .Refresh BackgroundQuery:=False
    End With
End Sub

Private Function ObterPlanilha(wb As Workbook, nome As String) As Worksheet
    On Error Resume Next
    Set ObterPlanilha = wb.Worksheets(nome)
    On Error GoTo 0
    If ObterPlanilha Is Nothing Then
        Set ObterPlanilha = wb.Worksheets.Add(After:=wb.Worksheets(wb.Worksheets.Count))
        ObterPlanilha.Name = nome
    End If
End Function

Private Sub ApagarConsulta(wb As Workbook, nome As String)
    Dim q As WorkbookQuery
    For Each q In wb.Queries
        If q.Name = nome Then q.Delete: Exit Sub
    Next q
End Sub

' troca o texto entre as primeiras aspas do parâmetro: "C:\..." meta [...]
Private Function TrocarTextoParametro(formula As String, valor As String) As String
    Dim a As Long, b As Long
    a = InStr(1, formula, """")
    b = InStr(a + 1, formula, """")
    TrocarTextoParametro = Left(formula, a) & valor & Mid(formula, b)
End Function

Private Function LerUtf8(caminho As String) As String
    Dim st As Object
    Set st = CreateObject("ADODB.Stream")
    st.Type = 2: st.Charset = "utf-8": st.Open
    st.LoadFromFile caminho
    LerUtf8 = st.ReadText
    st.Close
End Function

Private Function EscolherPasta(padrao As String) As String
    With Application.FileDialog(msoFileDialogFolderPicker)
        .Title = "Escolha a pasta scripts_m"
        .InitialFileName = padrao
        If .Show = -1 Then EscolherPasta = .SelectedItems(1) & "\"
    End With
End Function
