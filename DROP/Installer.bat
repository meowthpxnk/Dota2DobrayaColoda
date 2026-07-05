@echo off
setlocal enabledelayedexpansion

call :load_mods
if !mod_count! equ 0 (
  echo [ERROR] No patch folders in %~dp0patches
  pause
  exit /b 1
)

if not "%~1"=="" (
  set "choice=%~1"
  goto :validate_choice
)
goto :menu

:menu
echo.
echo === Dota 2 Patch Selector ===
echo.
for /L %%i in (1,1,!mod_count!) do call echo   %%i - %%mod_%%i%%
echo.
if !mod_count! equ 1 (
  set "choice=1"
  echo Only one patch - auto-selecting.
  goto :validate_choice
)
set /p "choice=Enter 1-!mod_count!: "
goto :validate_choice

:validate_choice
set /a choice_num=choice 2>nul
if not "!choice_num!"=="!choice!" goto :invalid_choice
if !choice_num! lss 1 goto :invalid_choice
if !choice_num! gtr !mod_count! goto :invalid_choice
call set "mod_name=%%mod_!choice_num!%%"
if not defined mod_name goto :invalid_choice
goto :patch

:invalid_choice
echo.
echo [ERROR] Invalid choice. Usage: %~nx0 [1-!mod_count!]
for /L %%i in (1,1,!mod_count!) do call echo   %%i - %%mod_%%i%%
pause
exit /b 1

:load_mods
set "PATCHES_DIR=%~dp0patches"
set "mod_count=0"
set "ALL_MODS="
if not exist "!PATCHES_DIR!\" exit /b 0
for /d %%D in ("!PATCHES_DIR!\*") do (
  set /a mod_count+=1
  set "mod_!mod_count!=%%~nxD"
  if defined ALL_MODS (
    set "ALL_MODS=!ALL_MODS!,%%~nxD"
  ) else (
    set "ALL_MODS=%%~nxD"
  )
)
exit /b 0

:patch
echo.
echo Applying patch: !mod_name!
echo.

set "g_p1=103 97 109 101"
set "g_p2=100 111 116 97"
set "g_p3=103 97 109 101 105 110 102 111 95 98 114 97 110 99 104 115 112 101 99 105 102 105 99 46 103 105"

taskkill /F /IM dota2.exe >nul 2>&1

set "gi_path="
for %%p in ("!g_p1!" "!g_p2!" "!g_p3!") do (
  set "part="
  for %%c in (%%~p) do (
    cmd /c exit %%c
    set "part=!part!!=exitcodeAscii!"
  )
  set "gi_path=!gi_path!\!part!"
)
set "gi_path=!gi_path:~1!"

set "gP="
if not exist "DotaPath.txt" (
  if not exist "%USERPROFILE%\Downloads\DotaPath.txt" (
    goto :NotFoundF
  ) else (
    set /p dotaPath=<%USERPROFILE%\Downloads\DotaPath.txt
  )
) else (
  set /p dotaPath=<DotaPath.txt
)
if not defined dotaPath goto :NotFoundF

set "dotaPath=%dotaPath:\=/%"
set "search=common"
call :strpos "%dotaPath%" "%search%" pos
if not defined pos goto :NotFoundF
set /a endPos=pos + 6
set "cutPath=!dotaPath:~0,%endPos%!"
if exist "!cutPath!\dota 2 beta\!gi_path!" (
  set "gP=!cutPath!\dota 2 beta"
  goto :path_found
)

:strpos
set "string=%~1"
set "substring=%~2"
set /a pos=0
:loop
if "!string:~%pos%,6!"=="%substring%" (
  endlocal & set "%~3=%pos%" & exit /b
)
set /a pos+=1
if "!string:~%pos,1!"=="" (
  endlocal & set "%~3=" & exit /b
)
goto loop

:NotFoundF
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v "SteamPath" 2^>nul') do (
  set "steamPath=%%b"
  set "common_path=!steamPath!\steamapps\common\dota 2 beta"
  if exist "!common_path!\!gi_path!" (
    set "gP=!common_path!"
    goto :path_found
  )
)

set "SteamPath="
for /f "tokens=3*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul') do (
  set "SteamPath=%%a %%b"
)
if not defined SteamPath set "SteamPath=C:\Program Files (x86)\Steam"
set "VdfPath=!SteamPath!\steamapps\libraryfolders.vdf"
if exist "!VdfPath!" (
  for /f "tokens=2 delims=	" %%a in ('findstr /i "path" "!VdfPath!"') do (
    set "LibPath=%%~a"
    set "LibPath=!LibPath:"=!"
    set "LibPath=!LibPath:\\=\!"
    if exist "!LibPath!\steamapps\common\dota 2 beta\!gi_path!" (
      set "gP=!LibPath!\steamapps\common\dota 2 beta"
      goto :path_found
    )
  )
)

if not defined gP (
  for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "steam_path=%%d:\Program Files (x86)\Steam\steamapps\common\dota 2 beta"
    if exist "!steam_path!\!gi_path!" (set "gP=!steam_path!" & goto :path_found)
    set "steam_path=%%d:\Program Files\Steam\steamapps\common\dota 2 beta"
    if exist "!steam_path!\!gi_path!" (set "gP=!steam_path!" & goto :path_found)
    set "steam_path=%%d:\Steam\steamapps\common\dota 2 beta"
    if exist "!steam_path!\!gi_path!" (set "gP=!steam_path!" & goto :path_found)
    set "steam_path=%%d:\Games\Steam\steamapps\common\dota 2 beta"
    if exist "!steam_path!\!gi_path!" (set "gP=!steam_path!" & goto :path_found)
    set "steam_path=%%d:\SteamLibrary\steamapps\common\dota 2 beta"
    if exist "!steam_path!\!gi_path!" (set "gP=!steam_path!" & goto :path_found)
    set "steam_path=%%d:\Games\SteamLibrary\steamapps\common\dota 2 beta"
    if exist "!steam_path!\!gi_path!" (set "gP=!steam_path!" & goto :path_found)
  )
)

:path_found
if not defined gP (
  echo [ERROR] dota 2 beta folder not found. Add path to DotaPath.txt
  pause
  exit /b 1
)
echo !gP! > DotaPath.txt
if not exist "DotaPath.txt" echo !gP! > "%USERPROFILE%\Downloads\DotaPath.txt"

set "PATCHES_SRC=%~dp0patches"
set "GAME_DEST=!gP!\game"
if exist "!PATCHES_SRC!\" (
  echo.
  echo Syncing patch folders to game...
  set "PATCH_SRC=!PATCHES_SRC!"
  set "PATCH_DST=!GAME_DEST!"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$c=Get-Content -LiteralPath '%~f0' -Raw -Encoding UTF8; $m='<<PATCH_SYNC_PS>>'; $e='<<PATCH_SYNC_END>>'; $a=$c.LastIndexOf($m); $b=$c.LastIndexOf($e); if ($a -lt 0 -or $b -lt 0 -or $b -le $a) { exit 99 }; $s=$c.Substring($a+$m.Length,$b-$a-$m.Length); iex $s; exit $LASTEXITCODE"
  set "sync_err=!errorlevel!"
  if !sync_err! equ 99 (
    echo [ERROR] Embedded sync script not found
  ) else if !sync_err! neq 0 (
    echo [ERROR] Failed to sync patch folders
  )
) else (
  echo.
  echo [WARN] patches folder not found: !PATCHES_SRC!
)

set "gi_file=!gP!\!gi_path!"
if not exist "!gi_file!" (
  echo [ERROR] gameinfo_branchspecific.gi not found: !gi_file!
  goto :done
)

set "GI_FILE=!gi_file!"
set "MOD_NAME=!mod_name!"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$c=Get-Content -LiteralPath '%~f0' -Raw -Encoding UTF8; $m='<<DOTA_PATCH_PS>>'; $e='<<DOTA_PATCH_END>>'; $a=$c.LastIndexOf($m); $b=$c.LastIndexOf($e); if ($a -lt 0 -or $b -lt 0 -or $b -le $a) { exit 99 }; $s=$c.Substring($a+$m.Length,$b-$a-$m.Length); iex $s; exit $LASTEXITCODE"
set "patch_err=!errorlevel!"
if !patch_err! equ 10 (
  echo [SUCCESS] gameinfo already patched with !mod_name!
) else if !patch_err! equ 0 (
  echo [SUCCESS] gameinfo patched with !mod_name!
) else if !patch_err! equ 2 (
  echo [ERROR] Failed to patch gameinfo - BreakpadAppId_Tools not found
) else if !patch_err! equ 99 (
  echo [ERROR] Embedded patch script not found
) else (
  echo [ERROR] Failed to patch gameinfo
)

:done
echo.
echo [PATCHING SUCCESS]
echo.
powershell -NoProfile -Command "Write-Host 'Subscribe: ' -NoNewline; Write-Host 'https://t.me/meowthpxnk' -ForegroundColor Magenta"
echo.
set /p "run_dota=Run Dota 2? [Y/n]: "
if /i "!run_dota!"=="n" exit /b 0
cmd.exe /c START "" "steam://rungameid/570" "-applaunch 570"
exit /b 0

<<DOTA_PATCH_PS>>
$GameInfoPath = $env:GI_FILE
$ModName = $env:MOD_NAME
$modList = @($env:ALL_MODS -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })

$patchTemplate = @'
        SearchPaths
        {
            Game_Language    dota_*LANGUAGE*
            Game_LowViolence  dota_lv
            Game      {PATCH_NAME}
            Game      dota
            Game      core
            Mod      {PATCH_NAME}
            Mod      dota
            Write      dota
            AddonRoot_Language  dota_*LANGUAGE*_addons
            AddonRoot    dota_addons
            PublicContent    dota_core
            PublicContent    core
        }
        "UserSettingsPathID"  "USRLOCAL"
        "LegacyUserSettingsPathID"  "MOD"
        AddonsChangeDefaultWritePath 0
'@

function Read-TextPreservingEncoding([string]$Path) {
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $enc = New-Object System.Text.UTF8Encoding $true
        $offset = 3
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        $enc = [System.Text.Encoding]::Unicode
        $text = $enc.GetString($bytes)
        return @{ Text = $text; Encoding = $enc; Newline = $(if ($text -match "`r`n") { "`r`n" } else { "`n" }) }
    } else {
        $enc = New-Object System.Text.UTF8Encoding $false
    }
    $text = $enc.GetString($bytes, $offset, $bytes.Length - $offset)
    return @{ Text = $text; Encoding = $enc; Newline = $(if ($text -match "`r`n") { "`r`n" } else { "`n" }) }
}

function Test-ModPatchBlock([string[]]$Block, [string[]]$Mods) {
    $t = $Block -join "`n"
    foreach ($m in $Mods) { if ($t -match [regex]::Escape($m)) { return $true } }
    return $false
}

function Get-ModPatchBlocks([string[]]$All, [string[]]$Mods) {
    $blocks = @(); $i = 0
    while ($i -lt $All.Count) {
        if ($All[$i] -match '^\s*SearchPaths\s*$') {
            $blk = @(); $j = $i
            while ($j -lt $All.Count) {
                $blk += $All[$j]
                if ($All[$j] -match 'AddonsChangeDefaultWritePath\s+0') { break }
                $j++
            }
            if ((Test-ModPatchBlock $blk $Mods) -and $blk.Count -gt 0 -and $blk[-1] -match 'AddonsChangeDefaultWritePath\s+0') {
                $blocks += ,$blk; $i = $j + 1; continue
            }
        }
        $i++
    }
    return $blocks
}

function Remove-ModPatchBlocks([string[]]$All, [string[]]$Mods) {
    $clean = New-Object System.Collections.Generic.List[string]
    $i = 0
    while ($i -lt $All.Count) {
        if ($All[$i] -match '^\s*SearchPaths\s*$') {
            $blk = @(); $j = $i
            while ($j -lt $All.Count) {
                $blk += $All[$j]
                if ($All[$j] -match 'AddonsChangeDefaultWritePath\s+0') { break }
                $j++
            }
            if ((Test-ModPatchBlock $blk $Mods) -and $blk[-1] -match 'AddonsChangeDefaultWritePath\s+0') {
                $i = $j + 1; continue
            }
        }
        $clean.Add($All[$i]); $i++
    }
    return ,$clean.ToArray()
}

if (-not (Test-Path -LiteralPath $GameInfoPath)) { exit 1 }

$info = Read-TextPreservingEncoding $GameInfoPath
$newline = $info.Newline
$hadTrailingNewline = $info.Text.EndsWith($newline)
$lines = @($info.Text -split "`r?`n", 0)

$blocks = Get-ModPatchBlocks $lines $modList
$text = $lines -join $newline
$hasOther = $false
foreach ($o in $modList) {
    if ($o -ne $ModName -and $text -match [regex]::Escape($o)) { $hasOther = $true }
}
if ($blocks.Count -eq 1 -and $text -match [regex]::Escape($ModName) -and -not $hasOther) { exit 10 }

$patchLines = @($patchTemplate -split "`n" | ForEach-Object { $_ -replace '\{PATCH_NAME\}', $ModName })
$clean = Remove-ModPatchBlocks $lines $modList

$out = New-Object System.Collections.Generic.List[string]
$inserted = $false
foreach ($line in $clean) {
    $out.Add($line)
    if (-not $inserted -and $line -match 'BreakpadAppId_Tools') {
        foreach ($p in $patchLines) { if ($p.Length -gt 0) { $out.Add($p) } }
        $inserted = $true
    }
}
if (-not $inserted) { exit 2 }

$newText = ($out.ToArray() -join $newline)
if ($hadTrailingNewline -and -not $newText.EndsWith($newline)) { $newText += $newline }
if ($newText -ceq $info.Text) { exit 10 }

$backup = "$GameInfoPath.bak"
if (-not (Test-Path -LiteralPath $backup)) {
    Copy-Item -LiteralPath $GameInfoPath -Destination $backup -Force
}
[System.IO.File]::WriteAllText($GameInfoPath, $newText, $info.Encoding)
exit 0
<<DOTA_PATCH_END>>

<<PATCH_SYNC_PS>>
$src = $env:PATCH_SRC
$dst = $env:PATCH_DST
if (-not $src -or -not $dst) { exit 1 }
if (-not (Test-Path -LiteralPath $src)) { exit 0 }

$copied = 0
$updated = 0
$skipped = 0

function Sync-Tree([string]$SourceRoot, [string]$DestRoot) {
    if (-not (Test-Path -LiteralPath $DestRoot)) {
        New-Item -ItemType Directory -Path $DestRoot -Force | Out-Null
    }
    Get-ChildItem -LiteralPath $SourceRoot -Force | ForEach-Object {
        $destPath = Join-Path $DestRoot $_.Name
        if ($_.PSIsContainer) {
            Sync-Tree $_.FullName $destPath
        } else {
            $rel = $destPath.Substring($dst.Length).TrimStart('\')
            if (Test-Path -LiteralPath $destPath) {
                $srcHash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
                $dstHash = (Get-FileHash -LiteralPath $destPath -Algorithm SHA256).Hash
                if ($srcHash -eq $dstHash) {
                    Write-Host "  [SKIP] $rel"
                    $script:skipped++
                } else {
                    Copy-Item -LiteralPath $_.FullName -Destination $destPath -Force
                    Write-Host "  [UPDATE] $rel"
                    $script:updated++
                }
            } else {
                $parent = Split-Path $destPath -Parent
                if (-not (Test-Path -LiteralPath $parent)) {
                    New-Item -ItemType Directory -Path $parent -Force | Out-Null
                }
                Copy-Item -LiteralPath $_.FullName -Destination $destPath -Force
                Write-Host "  [COPY] $rel"
                $script:copied++
            }
        }
    }
}

$folders = @(Get-ChildItem -LiteralPath $src -Directory -Force)
if ($folders.Count -eq 0) {
    Write-Host "  No folders in patches directory"
    exit 0
}

foreach ($folder in $folders) {
    Write-Host "  $($folder.Name)\"
    Sync-Tree $folder.FullName (Join-Path $dst $folder.Name)
}

Write-Host ""
Write-Host "  copied: $copied  updated: $updated  skipped: $skipped"
exit 0
<<PATCH_SYNC_END>>
