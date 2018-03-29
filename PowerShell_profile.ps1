Import-Module 'posh-git'
Import-Module 'oh-my-posh'
Import-Module 'Get-ChildItemColor'

Set-Alias l Get-ChildItemColor -Option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope

function home {
  Set-Location D:
}

function vpn {
  param(
    [string]$switch)

  if ($switch -eq "on")
  {
    &"C:\Program Files\SonicWall\Global VPN Client\SWGVC.exe" /E "VPN - SGI" /U user /P pass
  }
  else
  {
    &"C:\Program Files\SonicWall\Global VPN Client\SWGVC.exe" /D "VPN - SGI"
  }
}

function remote {
  param(
    [string]$name)

  mstsc /v:$name
}

function vs {
  $solution = gci -Path .\ -Filter *.sln -Recurse -File -Name -Depth 3 | select -First 1
  start "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe" $solution -Verb runAs
}

function build {
  $solution = gci -Path .\ -Filter *.sln -Recurse -File -Name | select -First 1
  C:\PROGRA~2\MSBuild\14.0\Bin\MSBuild.exe $solution -verbosity:quiet
}

function msbuild15 {
  param(
    [string]$name)

  &'C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe' $name
}

function test {
  D:\BuildTools\nunit\3.6.1\nunit3-console.exe src\builds\nunit.tests.nunit --noresult
}

function migrate {
  param(
    [string]$version,
    [bool]$preview)

  if ($version) {
    executar-migrations -target MigrateToVersion -version $version -preview $preview
  }

  else {
    executar-migrations -target Migrate -preview $preview
  }
}

function rollback {
  executar-migrations rollback
}

function executar-migrations {
  param(
    [string]$target,
    [string]$version,
    [bool]$preview)

  $migrationConfig = gci -Path .\ -Filter migrations.proj -Recurse -File -Name | select -First 1

  if ($version) {
    C:\PROGRA~2\MSBuild\14.0\Bin\MSBuild.exe $migrationConfig /t:$target /p:Version=$version
  }
  else {
    C:\PROGRA~2\MSBuild\14.0\Bin\MSBuild.exe $migrationConfig /t:$target /p:previewOnly=$preview
  }
}

function restore {
  $bancos = New-Object "system.collections.generic.dictionary[string,string]"
  $bancos["foldername1"] = "databasename1"
  $bancos["foldername2"] = "databasename2"
  $bancos["foldername3"] = "databasename3"

  $backups = New-Object "system.collections.generic.dictionary[string,string]"
  $bancos["foldername1"] = "database1BakPath.bak"
  $bancos["foldername2"] = "database2BakPath.bak"
  $bancos["foldername3"] = "database3BakPath.bak"

  $diretorioAtual = (Get-Item -Path ".\" -Verbose).Name
  $banco = $bancos[$diretorioAtual]
  $backup = $backups[$diretorioAtual]

  Write-Host "### Restaurando $($diretorioAtual) ($($banco))"
  $sql = "use master; ALTER DATABASE $($banco) SET SINGLE_USER WITH ROLLBACK IMMEDIATE RESTORE DATABASE $($banco) FROM DISK = '$($backup)' WITH REPLACE"
  sqlcmd -Q $sql
}

function restaurar_banco_de_dados {
  param(
    [string]$nomeDoBanco,
    [string]$pathDosBackups)

  Write-Output "### Restaurando $($nomeDoBanco)"

  $bakMaisRecente = Get-ChildItem -Path $pathDosBackups -Filter *.bak | Sort-Object LastAccessTime -Descending | Select-Object -First 1

  Copy-Item $bakMaisRecente.FullName -Destination $PWD -Force

  $pathDoBakCopiado = "$($PWD)\$($bakMaisRecente.Name)"
  
  Invoke-Expression "sqlcmd -U sa -P password -Q `"EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$($nomeDoBanco)' DROP DATABASE [$($nomeDoBanco)]`""
  Invoke-Expression "sqlcmd -U sa -P password -Q `"CREATE DATABASE $($nomeDoBanco) ON (NAME = $($nomeDoBanco)_dat, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\$($nomeDoBanco).mdf') LOG ON (NAME = $($nomeDoBanco)_log, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\$($nomeDoBanco).ldf')`""
  Invoke-Expression "sqlcmd -U sa -P password -Q `"GO`""

  Invoke-Expression "sqlcmd -U sa -P password -Q `"use [master]`""
  Invoke-Expression "sqlcmd -U sa -P password -Q `"ALTER DATABASE $($nomeDoBanco) SET SINGLE_USER WITH ROLLBACK IMMEDIATE`""

  Invoke-Expression "sqlcmd -U sa -P password -Q `"RESTORE DATABASE [$($nomeDoBanco)] FROM  DISK = N'$($pathDoBakCopiado)' WITH  FILE = 1,  MOVE N'$($nomeDoBanco)' TO N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\$($nomeDoBanco).mdf',  MOVE N'$($nomeDoBanco)_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\$($nomeDoBanco)_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5`""
  
  Invoke-Expression "sqlcmd -U sa -P password -Q `"ALTER DATABASE [$($nomeDoBanco)] SET MULTI_USER`""
  Invoke-Expression "sqlcmd -U sa -P password -Q `"GO`""

  Remove-Item $pathDoBakCopiado
}

function U
{
    param
    (
        [int] $Code
    )
 
    if ((0 -le $Code) -and ($Code -le 0xFFFF))
    {
        return [char] $Code
    }
 
    if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF))
    {
        return [char]::ConvertFromUtf32($Code)
    }
 
    throw "Invalid character code $Code"
}

Set-Theme Paradox
home