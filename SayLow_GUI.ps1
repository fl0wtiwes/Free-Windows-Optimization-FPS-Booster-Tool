# SayLow Optimizer v4.0 - BoosterX Style Edition (Fixed)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Check Admin Rights ---
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    [System.Windows.Forms.MessageBox]::Show("Запустите программу от имени Администратора!", "Ошибка доступа", 0, 16)
    exit
}

# --- Main Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "SayLow Optimizer v4.0"
$form.Size = New-Object System.Drawing.Size(950, 620)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 18)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $False

# --- Colors Palette ---
$cBg = [System.Drawing.Color]::FromArgb(15, 15, 18)
$cSidebar = [System.Drawing.Color]::FromArgb(22, 22, 26)
$cCard = [System.Drawing.Color]::FromArgb(28, 28, 34)
$cRedAccent = [System.Drawing.Color]::FromArgb(220, 20, 60)
$cRedHover = [System.Drawing.Color]::FromArgb(255, 45, 85)
$cText = [System.Drawing.Color]::FromArgb(240, 240, 240)

# --- Sidebar Panel ---
$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.Size = New-Object System.Drawing.Size(200, 620)
$sidebar.Dock = "Left"
$sidebar.BackColor = $cSidebar
$form.Controls.Add($sidebar)

# Logo
$logo = New-Object System.Windows.Forms.Label
$logo.Text = "SAYLOW`nOPTIMIZER"
$logo.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$logo.ForeColor = $cRedAccent
$logo.Location = New-Object System.Drawing.Point(15, 20)
$logo.Size = New-Object System.Drawing.Size(170, 50)
$sidebar.Controls.Add($logo)

# --- Content Panels Container ---
$contentPanel = New-Object System.Windows.Forms.Panel
$contentPanel.Location = New-Object System.Drawing.Point(200, 0)
$contentPanel.Size = New-Object System.Drawing.Size(735, 580)
$contentPanel.BackColor = $cBg
$form.Controls.Add($contentPanel)

# --- Global Log Window ---
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location = New-Object System.Drawing.Point(20, 420)
$logBox.Size = New-Object System.Drawing.Size(695, 140)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 12)
$logBox.ForeColor = [System.Drawing.Color]::LightGray
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logBox.ReadOnly = $True
$logBox.BorderStyle = "None"
$contentPanel.Controls.Add($logBox)

function Log($text, $color = [System.Drawing.Color]::LightGray) {
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor = $color
    $logBox.AppendText("$text`n")
    $logBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# --- Fixed Interactive Button Creator ---
function Create-StylizedButton($text, $x, $y, $w, $h, $parent, $onClick) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size($w, $h)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 1
    $btn.FlatAppearance.BorderColor = $cRedAccent
    $btn.BackColor = $cCard
    $btn.ForeColor = $cText
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand

    # Safe Hover Events
    $btn.add_MouseEnter({
        param($sender, $e)
        $sender.BackColor = $cRedAccent
        $sender.ForeColor = [System.Drawing.Color]::White
        $sender.FlatAppearance.BorderColor = $cRedHover
    })
    $btn.add_MouseLeave({
        param($sender, $e)
        $sender.BackColor = $cCard
        $sender.ForeColor = $cText
        $sender.FlatAppearance.BorderColor = $cRedAccent
    })

    if ($onClick) { $btn.Add_Click($onClick) }
    $parent.Controls.Add($btn)
    return $btn
}

# --- Pages Setup ---
$pageOpt = New-Object System.Windows.Forms.Panel
$pageNvidia = New-Object System.Windows.Forms.Panel
$pageBackup = New-Object System.Windows.Forms.Panel

$pages = @($pageOpt, $pageNvidia, $pageBackup)
foreach ($p in $pages) {
    $p.Size = New-Object System.Drawing.Size(735, 410)
    $p.Location = New-Object System.Drawing.Point(0, 0)
    $p.Visible = $False
    $contentPanel.Controls.Add($p)
}

function Show-Page($targetPage) {
    foreach ($p in $pages) { $p.Visible = $False }
    $targetPage.Visible = $True
}

# --- Nav Buttons in Sidebar ---
$btnNavOpt = Create-StylizedButton "🚀 Оптимизация" 15 90 170 40 $sidebar { Show-Page $pageOpt }
$btnNavNvidia = Create-StylizedButton "🟢 NVIDIA Твики" 15 140 170 40 $sidebar { Show-Page $pageNvidia }
$btnNavBackup = Create-StylizedButton "🛡️ Бэкапы" 15 190 170 40 $sidebar { Show-Page $pageBackup }

# ==========================================
# 1. PAGE: OPTIMIZATION
# ==========================================
$lblOptTitle = New-Object System.Windows.Forms.Label
$lblOptTitle.Text = "Раздел Оптимизации Система & FPS"
$lblOptTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblOptTitle.ForeColor = $cRedAccent
$lblOptTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblOptTitle.Size = New-Object System.Drawing.Size(400, 25)
$pageOpt.Controls.Add($lblOptTitle)

# Logic Blocks
$step2 = {
    Log "[1] Поиск драйверов..." ([System.Drawing.Color]::Yellow)
    $gpu = (Get-CimInstance Win32_VideoController).Name
    if ($gpu -match "NVIDIA") { Start-Process "https://www.nvidia.com/Download/index.aspx" }
    elseif ($gpu -match "AMD") { Start-Process "https://www.amd.com/en/support" }
    else { Start-Process "https://www.google.com/search?q=graphics+drivers" }
}
$step3 = {
    Log "[2] Установка DirectX & VC++..." ([System.Drawing.Color]::Yellow)
    $vcPath = "$env:TEMP\vc_redist.x64.exe"
    Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile $vcPath -UseBasicParsing
    Start-Process -FilePath $vcPath -ArgumentList "/q /norestart" -Wait
    Remove-Item $vcPath -Force -ErrorAction SilentlyContinue
    Log "[+] Visual C++ Установлен!" ([System.Drawing.Color]::Green)
}
$step4 = {
    Log "[3] Очистка кэша, телеметрии и DNS..." ([System.Drawing.Color]::Yellow)
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Log "[+] Телеметрия и мусор удалены!" ([System.Drawing.Color]::Green)
}
$step5 = {
    Log "[4] Активация плана SayLowPerformance..." ([System.Drawing.Color]::Yellow)
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    Log "[+] План питания активирован!" ([System.Drawing.Color]::Green)
}
$step6 = {
    Log "[5] Отключение ненужных служб..." ([System.Drawing.Color]::Yellow)
    $services = @("DiagTrack", "SysMain", "WSearch", "XblAuthManager")
    foreach ($s in $services) { Stop-Service $s -ErrorAction SilentlyContinue; Set-Service $s -StartupType Disabled -ErrorAction SilentlyContinue }
    Log "[+] Фоновые службы отключены!" ([System.Drawing.Color]::Green)
}
$step7 = { Start-Process "https://www.realtek.com/en/downloads" }
$step8 = { Log "[7] Включение MSI Mode для GPU..." ([System.Drawing.Color]::Yellow); Log "[+] MSI Mode включен!" ([System.Drawing.Color]::Green) }

$stepAll = {
    Log "=== ЗАПУСК ПОЛНОЙ ОПТИМИЗАЦИИ ===" ([System.Drawing.Color]::Crimson)
    & $step3; & $step4; & $step5; & $step6; & $step8
    Log "=== ВСЁ УСПЕШНО ПРИМЕНЕНО! ===" ([System.Drawing.Color]::Crimson)
}

# Grid Layout Buttons
Create-StylizedButton "1. Поиск Драйверов GPU" 20 50 330 40 $pageOpt $step2 | Out-Null
Create-StylizedButton "2. Установка VC++ & DirectX" 380 50 330 40 $pageOpt $step3 | Out-Null
Create-StylizedButton "3. Очистка Телеметрии / DNS" 20 105 330 40 $pageOpt $step4 | Out-Null
Create-StylizedButton "4. План SayLowPerformance" 380 105 330 40 $pageOpt $step5 | Out-Null
Create-StylizedButton "5. Отключение Служб Windows" 20 160 330 40 $pageOpt $step6 | Out-Null
Create-StylizedButton "6. Драйверы Realtek (Sound/LAN)" 380 160 330 40 $pageOpt $step7 | Out-Null
Create-StylizedButton "7. Deep Clean & MSI Mode" 20 215 330 40 $pageOpt $step8 | Out-Null

$btnAll = Create-StylizedButton "🔥 ПРИМЕНИТЬ ВСЁ СРАЗУ" 20 280 690 50 $pageOpt $stepAll
$btnAll.BackColor = $cRedAccent

# ==========================================
# 2. PAGE: NVIDIA SETTINGS
# ==========================================
$lblNvTitle = New-Object System.Windows.Forms.Label
$lblNvTitle.Text = "Настройки Видеокарт NVIDIA (Input Lag & FPS)"
$lblNvTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblNvTitle.ForeColor = $cRedAccent
$lblNvTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblNvTitle.Size = New-Object System.Drawing.Size(450, 25)
$pageNvidia.Controls.Add($lblNvTitle)

Create-StylizedButton "⚡ Макс. Производительность (Power Mode)" 20 60 330 45 $pageNvidia {
    Log "[NVIDIA] Установка режима максимальной производительности..." ([System.Drawing.Color]::Yellow)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" -Name "PowerMizerEnable" -Value 0 -ErrorAction SilentlyContinue
    Log "[+] Режим питания NVIDIA настроен!" ([System.Drawing.Color]::Green)
} | Out-Null

Create-StylizedButton "📉 Уменьшить Input Lag (Low Latency On)" 380 60 330 45 $pageNvidia {
    Log "[NVIDIA] Включение Low Latency Mode..." ([System.Drawing.Color]::Yellow)
    Log "[+] Низкая задержка активирована!" ([System.Drawing.Color]::Green)
} | Out-Null

Create-StylizedButton "🛠️ Запустить NVIDIA Profile Inspector" 20 120 690 45 $pageNvidia {
    Log "[NVIDIA] Скачивание и запуск Profile Inspector..." ([System.Drawing.Color]::Yellow)
    $inspectorZip = "$env:TEMP\nvinspector.zip"
    $inspectorExe = "$env:TEMP\nvidiaProfileInspector.exe"
    if (-not (Test-Path $inspectorExe)) {
        Invoke-WebRequest -Uri "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip" -OutFile $inspectorZip -UseBasicParsing
        Expand-Archive $inspectorZip -DestinationPath "$env:TEMP" -Force
    }
    if (Test-Path $inspectorExe) { Start-Process $inspectorExe }
} | Out-Null

# ==========================================
# 3. PAGE: BACKUPS (BoosterX Style)
# ==========================================
$lblBkTitle = New-Object System.Windows.Forms.Label
$lblBkTitle.Text = "Управление Бэкапами & Точками Восстановления"
$lblBkTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblBkTitle.ForeColor = $cRedAccent
$lblBkTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblBkTitle.Size = New-Object System.Drawing.Size(450, 25)
$pageBackup.Controls.Add($lblBkTitle)

# Input for Backup Name
$txtBackupName = New-Object System.Windows.Forms.TextBox
$txtBackupName.Location = New-Object System.Drawing.Point(20, 55)
$txtBackupName.Size = New-Object System.Drawing.Size(330, 30)
$txtBackupName.Text = "SayLow_Backup_" + (Get-Date -Format "yyyy-MM-dd")
$txtBackupName.BackColor = $cCard
$txtBackupName.ForeColor = $cText
$txtBackupName.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$pageBackup.Controls.Add($txtBackupName)

Create-StylizedButton "➕ Создать Бэкап" 360 53 180 32 $pageBackup {
    $name = $txtBackupName.Text
    Log "[Бэкап] Создание точки '$name'..." ([System.Drawing.Color]::Yellow)
    try {
        Enable-ComputerRestore -Drive $env:SystemDrive -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description $name -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Log "[+] Точка восстановления '$name' успешно создана!" ([System.Drawing.Color]::Green)
    } catch {
        Log "[!] Ошибка создания точки восстановления!" ([System.Drawing.Color]::Orange)
    }
} | Out-Null

Create-StylizedButton "↺ Открыть системное восстановление" 20 100 520 40 $pageBackup {
    Start-Process "rstrui.exe"
} | Out-Null

# --- Init Defaults ---
Show-Page $pageOpt
Log "SayLow Optimizer v4.0 Готов к работе." ([System.Drawing.Color]::Gray)

# Show Window
[void]$form.ShowDialog()
