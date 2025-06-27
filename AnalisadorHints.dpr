program AnalisadorHints;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, System.IOUtils, System.RegularExpressions, Windows, System.Types,
  System.Generics.Collections;

type
  TRelatorioProjeto = record
    NomeProjeto: string;
    Hints: TStringList;
    Warnings: TStringList;
  end;

procedure AnalisarProjeto(const CaminhoDPR: string; var Relatorios: TList<TRelatorioProjeto>; var Falhas: Boolean);
var
  ProjetoNome, ProjetoDir, LogFile, LogLine, Codigo, CmdLine: string;
  Output: TStringList;
  Match: TMatch;
  i: Integer;
  Processo: TProcessInformation;
  StartInfo: TStartupInfo;
  CmdLineBuffer: array[0..1023] of WideChar;
  Relatorio: TRelatorioProjeto;
begin
  ProjetoNome := ChangeFileExt(ExtractFileName(CaminhoDPR), '');
  ProjetoDir := ExtractFilePath(CaminhoDPR);
  LogFile := TPath.Combine(ProjetoDir, 'compilacao_temp.log');

  CmdLine := Format('cmd /C dcc32 "%s" > "%s" 2>&1', [CaminhoDPR, LogFile]);
  FillChar(CmdLineBuffer, SizeOf(CmdLineBuffer), 0);
  StrPLCopy(CmdLineBuffer, CmdLine, Length(CmdLineBuffer) - 1);

  ZeroMemory(@StartInfo, SizeOf(StartInfo));
  StartInfo.cb := SizeOf(StartInfo);

  if not CreateProcess(nil, @CmdLineBuffer[0], nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartInfo, Processo) then
  begin
    Writeln('Erro ao executar dcc32 para: ', CaminhoDPR);
    Exit;
  end;

  WaitForSingleObject(Processo.hProcess, INFINITE);
  CloseHandle(Processo.hProcess);
  CloseHandle(Processo.hThread);

  if not FileExists(LogFile) then Exit;

  Output := TStringList.Create;
  try
    Output.LoadFromFile(LogFile);

    Relatorio.NomeProjeto := ProjetoNome;
    Relatorio.Hints := TStringList.Create;
    Relatorio.Warnings := TStringList.Create;

    for i := 0 to Output.Count - 1 do
    begin
      LogLine := Output[i];
      Match := TRegEx.Match(LogLine, '^(.+)\((\d+)\)\s+(Hint|Warning):\s+(H|W)(\d{4})\s+(.*)');
      if Match.Success then
      begin
        Codigo := Match.Groups[4].Value + Match.Groups[5].Value;
        if Match.Groups[3].Value = 'Hint' then
        begin
          Relatorio.Hints.Add(Format('%s(%s): [%s] %s', [
            Trim(Match.Groups[1].Value),
            Match.Groups[2].Value,
            Codigo,
            Match.Groups[6].Value
          ]));
          Writeln('[HINT] ', Relatorio.Hints[Relatorio.Hints.Count - 1]);
        end
        else
        begin
          Relatorio.Warnings.Add(Format('%s(%s): [%s] %s', [
            Trim(Match.Groups[1].Value),
            Match.Groups[2].Value,
            Codigo,
            Match.Groups[6].Value
          ]));
          Writeln('[WARNING] ', Relatorio.Warnings[Relatorio.Warnings.Count - 1]);
        end;
      end;
    end;

    if (Relatorio.Hints.Count > 0) or (Relatorio.Warnings.Count > 0) then
    begin
      Falhas := True;
      Relatorios.Add(Relatorio);
    end
    else
    begin
      Relatorio.Hints.Free;
      Relatorio.Warnings.Free;
    end;

  finally
    Output.Free;
    SysUtils.DeleteFile(LogFile);
  end;
end;

procedure GerarRelatorioUnico(const Relatorios: TList<TRelatorioProjeto>; const DestinoRelatorio: string);
var
  HTML: TStringList;
  Relatorio: TRelatorioProjeto;
  Linha: string;
  HTMLFile: string;
begin
  if DestinoRelatorio <> '' then
    HTMLFile := TPath.Combine(DestinoRelatorio, 'RelatorioCompleto.html')
  else
    HTMLFile := 'RelatorioCompleto.html';

  HTML := TStringList.Create;
  try
    HTML.Add('<html><head><meta charset="utf-8"><style>');
    HTML.Add('body{font-family:Arial;} h2{color:#003366;} h3{color:#333;} ul{margin-left:20px;}');
    HTML.Add('li{margin-bottom:4px;} .hint{color:green;} .warning{color:orange;}');
    HTML.Add('</style></head><body>');
    HTML.Add('<h1>Relatório Consolidado de Hints e Warnings</h1>');

    for Relatorio in Relatorios do
    begin
      HTML.Add('<hr><h2>' + Relatorio.NomeProjeto + '</h2>');

      if Relatorio.Hints.Count > 0 then
      begin
        HTML.Add('<h3>Hints</h3><ul>');
        for Linha in Relatorio.Hints do
          HTML.Add('<li class="hint">' + Linha + '</li>');
        HTML.Add('</ul>');
      end;

      if Relatorio.Warnings.Count > 0 then
      begin
        HTML.Add('<h3>Warnings</h3><ul>');
        for Linha in Relatorio.Warnings do
          HTML.Add('<li class="warning">' + Linha + '</li>');
        HTML.Add('</ul>');
      end;
    end;

    HTML.Add('</body></html>');
    HTML.SaveToFile(HTMLFile);

    Writeln;
    Writeln('✅ Relatório consolidado salvo em: ', HTMLFile);

  finally
    HTML.Free;
  end;
end;

procedure ExportarCSV(const Relatorios: TList<TRelatorioProjeto>; const DestinoRelatorio: string);
var
  CSV: TStringList;
  Relatorio: TRelatorioProjeto;
  Linha, NomeArquivo, CSVFile: string;
  Partes: TArray<string>;
begin
  CSV := TStringList.Create;
  try
    CSV.Add('Projeto;Tipo;Arquivo;Linha;Código;Mensagem');

    for Relatorio in Relatorios do
    begin
      for Linha in Relatorio.Hints do
      begin
        Partes := Linha.Split([':']);
        NomeArquivo := Copy(Partes[0], 1, Pos('(', Partes[0]) - 1);
        CSV.Add(Format('%s;Hint;%s;%s;%s;%s',
          [Relatorio.NomeProjeto,
           Trim(NomeArquivo),
           Copy(Partes[0], Pos('(', Partes[0]) + 1, Pos(')', Partes[0]) - Pos('(', Partes[0]) - 1),
           Copy(Partes[1], Pos('[' , Partes[1]) + 1, 5),
           Trim(Copy(Partes[1], Pos('] ', Partes[1]) + 2, MaxInt))]));
      end;

      for Linha in Relatorio.Warnings do
      begin
        Partes := Linha.Split([':']);
        NomeArquivo := Copy(Partes[0], 1, Pos('(', Partes[0]) - 1);
        CSV.Add(Format('%s;Warning;%s;%s;%s;%s',
          [Relatorio.NomeProjeto,
           Trim(NomeArquivo),
           Copy(Partes[0], Pos('(', Partes[0]) + 1, Pos(')', Partes[0]) - Pos('(', Partes[0]) - 1),
           Copy(Partes[1], Pos('[' , Partes[1]) + 1, 5),
           Trim(Copy(Partes[1], Pos('] ', Partes[1]) + 2, MaxInt))]));
      end;
    end;

    if DestinoRelatorio <> '' then
      CSVFile := TPath.Combine(DestinoRelatorio, 'RelatorioCompleto.csv')
    else
      CSVFile := 'RelatorioCompleto.csv';

    CSV.SaveToFile(CSVFile, TEncoding.UTF8);
    Writeln('📄 Exportação CSV salva em: ', CSVFile);

  finally
    CSV.Free;
  end;
end;

var
  DiretorioBase, DestinoRelatorio: string;
  Projetos: TArray<string>;
  Arquivo: string;
  AlgumComProblemas: Boolean;
  Relatorios: TList<TRelatorioProjeto>;
  Relatorio: TRelatorioProjeto;
begin
  if ParamCount < 1 then
  begin
    Writeln('Uso: AnalisadorHints.exe "C:\Fontes" ["C:\DestinoRelatorio"]');
    Halt(1);
  end;

  DiretorioBase := ParamStr(1);
  if not TDirectory.Exists(DiretorioBase) then
  begin
    Writeln('Diretório não encontrado: ', DiretorioBase);
    Halt(1);
  end;

end.
