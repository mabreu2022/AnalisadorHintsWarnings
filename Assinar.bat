@echo off
echo Assinando AnalisadorHints.exe com SHA256 e timestamp...
"C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool\signtool.exe" sign ^
  /fd SHA256 ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  /a AnalisadorHints.exe

if %errorlevel% neq 0 (
  echo Erro ao assinar o executável. Código de saída: %errorlevel%
) else (
  echo Assinatura concluída com sucesso!
)
pause