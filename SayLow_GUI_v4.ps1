Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase -ErrorAction Stop

# ==============================================================
# SayLow Optimizer v4.0 (Full Version + Telegram)
# ==============================================================

$ErrorActionPreference = 'SilentlyContinue'
$AppName = 'SayLow Optimizer'
$AppRoot = Join-Path $env:ProgramData 'SayLowOptimizer'
$ConfigFile = Join-Path $AppRoot 'settings.json'
$BackupRoot = Join-Path $AppRoot 'Backups'

# 🔗 ССЫЛКА НА ТВОЙ TELEGRAM
$TelegramLink = "https://t.me/SayLowRr"

New-Item -ItemType Directory -Force -Path $AppRoot, $BackupRoot | Out-Null

# ---------------- Persistent settings ----------------

$Defaults = [ordered]@{
    PowerPlan    = $true
    InputLag     = $true
    Services     = $true
    RestorePoint = $true
    Temp         = $true
    ShaderCache  = $false
}

function Get-SavedSettings {
    $result = @{}
    foreach ($k in $Defaults.Keys) { $result[$k] = $Defaults[$k] }

    if (Test-Path $ConfigFile) {
        try {
            $json = Get-Content $ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($k in $Defaults.Keys) {
                if ($null -ne $json.$k) { $result[$k] = [bool]$json.$k }
            }
        } catch {}
    }
    return $result
}

$Settings = Get-SavedSettings

function Save-SavedSettings {
    $Settings.PowerPlan    = [bool]$ChkPowerPlan.IsChecked
    $Settings.InputLag     = [bool]$ChkInputLag.IsChecked
    $Settings.Services     = [bool]$ChkServices.IsChecked
    $Settings.RestorePoint = [bool]$ChkRestorePoint.IsChecked
    $Settings.Temp         = [bool]$ChkTemp.IsChecked
    $Settings.ShaderCache  = [bool]$ChkShaderCache.IsChecked

    $Settings | ConvertTo-Json | Set-Content -Path $ConfigFile -Encoding UTF8 -Force
}

# ---------------- GUI ----------------

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SayLow Optimizer"
        Width="1000" Height="720"
        MinWidth="900" MinHeight="650"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent">

    <Window.Resources>
        <Style x:Key="NavButton" TargetType="Button">
            <Setter Property="Height" Value="44"/>
            <Setter Property="Margin" Value="0,0,0,7"/>
            <Setter Property="Background" Value="#202126"/>
            <Setter Property="Foreground" Value="#A9ABB3"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Padding" Value="16,0,0,0"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style x:Key="ActionButton" TargetType="Button">
            <Setter Property="Height" Value="48"/>
            <Setter Property="Background" Value="#E50914"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Margin" Value="0,0,0,15"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI"/>
        </Style>
    </Window.Resources>

    <Border Background="#101114" CornerRadius="16" BorderBrush="#292B31" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="58"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- HEADER -->
            <Border Grid.Row="0" Background="#17181D" CornerRadius="16,16,0,0" Name="DragArea">
                <Grid>
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="22,0,0,0">
                        <TextBlock Text="SAYLOW" Foreground="#E50914" FontSize="17" FontWeight="Bold"/>
                        <TextBlock Text=" OPTIMIZER" Foreground="White" FontSize="17" FontWeight="Bold"/>
                        <Border Background="#26272D" CornerRadius="6" Padding="7,3" Margin="12,0,0,0">
                            <TextBlock Text="v4.0" Foreground="#B8BAC1" FontSize="10"/>
                        </Border>
                    </StackPanel>

                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button Name="BtnMin" Content="—" Width="46" Height="56" Background="Transparent" Foreground="#777A83" BorderThickness="0" FontSize="18"/>
                        <Button Name="BtnClose" Content="×" Width="52" Height="56" Background="Transparent" Foreground="#777A83" BorderThickness="0" FontSize="23"/>
                    </StackPanel>
                </Grid>
            </Border>

            <Grid Grid.Row="1">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="225"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- SIDEBAR -->
                <Border Grid.Column="0" Background="#15161A" Padding="13,18">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <StackPanel>
                            <TextBlock Text="РАЗДЕЛЫ" Foreground="#62646C" FontSize="10" FontWeight="Bold" Margin="10,0,0,12"/>

                            <Button Name="NavOptimize" Style="{StaticResource NavButton}" Content="⚡   Оптимизация"/>
                            <Button Name="NavClean" Style="{StaticResource NavButton}" Content="🧹   Очистка"/>
                            <Button Name="NavBackup" Style="{StaticResource NavButton}" Content="💾   Backup"/>

                            <!-- СИСТЕМА -->
                            <Border Background="#1D1E23" CornerRadius="9" Padding="12" Margin="0,15,0,0">
                                <StackPanel>
                                    <TextBlock Text="СИСТЕМА" Foreground="#62646C" FontSize="9" FontWeight="Bold"/>
                                    <TextBlock Name="TxtSystem" Text="Проверка..." Foreground="White" FontSize="11" Margin="0,7,0,0"/>
                                    <TextBlock Name="TxtAdmin" Text="" Foreground="#777A83" FontSize="9" Margin="0,3,0,0"/>
                                </StackPanel>
                            </Border>

                            <!-- TELEGRAM BLOCK -->
                            <Border Background="#161F2B" BorderBrush="#1F3147" BorderThickness="1" CornerRadius="9" Padding="12" Margin="0,10,0,0">
                                <StackPanel>
                                    <TextBlock Text="TELEGRAM" Foreground="#0088CC" FontSize="9" FontWeight="Bold"/>
                                    <TextBlock Text="Наш канал / Поддержка" Foreground="#777A83" FontSize="9" Margin="0,3,0,8"/>
                                    <Button Name="BtnTelegram" Content="✈   Перейти в Telegram" Height="32" Background="#0088CC" Foreground="White" BorderThickness="0" FontSize="10" FontWeight="Bold" Cursor="Hand">
                                        <Button.Resources>
                                            <Style TargetType="Border">
                                                <Setter Property="CornerRadius" Value="6"/>
                                            </Style>
                                        </Button.Resources>
                                    </Button>
                                </StackPanel>
                            </Border>
                        </StackPanel>

                        <StackPanel Grid.Row="1">
                            <Border Background="#1D191B" BorderBrush="#392126" BorderThickness="1" CornerRadius="9" Padding="12">
                                <StackPanel>
                                    <TextBlock Text="SAYLOW" Foreground="#E50914" FontWeight="Bold" FontSize="11"/>
                                    <TextBlock Text="Настройки сохраняются автоматически." Foreground="#777A83" FontSize="9" Margin="0,4,0,0" TextWrapping="Wrap"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- CONTENT -->
                <Grid Grid.Column="1" Margin="28,25,28,25">

                    <!-- OPTIMIZE -->
                    <ScrollViewer Name="PageOptimize" VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <TextBlock Text="Оптимизация" Foreground="White" FontSize="25" FontWeight="Bold"/>
                            <TextBlock Text="Выберите функции. Состояние каждой галочки сохраняется после закрытия программы." Foreground="#777A83" FontSize="11" Margin="0,6,0,21"/>

                            <Border Background="#191A1F" CornerRadius="11" Padding="17" Margin="0,0,0,11">
                                <StackPanel>
                                    <TextBlock Text="ПРОИЗВОДИТЕЛЬНОСТЬ" Foreground="#696B74" FontSize="10" FontWeight="Bold" Margin="0,0,0,15"/>
                                    <CheckBox Name="ChkPowerPlan" Content="Power Plan — SayLowPerformance"/>
                                    <CheckBox Name="ChkInputLag" Content="Input Lag — системные настройки отклика"/>
                                </StackPanel>
                            </Border>

                            <Border Background="#191A1F" CornerRadius="11" Padding="17" Margin="0,0,0,11">
                                <StackPanel>
                                    <TextBlock Text="ФОНОВЫЕ СЛУЖБЫ" Foreground="#696B74" FontSize="10" FontWeight="Bold" Margin="0,0,0,15"/>
                                    <CheckBox Name="ChkServices" Content="Отключить ненужные consumer / telemetry службы"/>
                                </StackPanel>
                            </Border>

                            <Border Background="#191A1F" CornerRadius="11" Padding="17" Margin="0,0,0,14">
                                <StackPanel>
                                    <TextBlock Text="ЗАЩИТА ПЕРЕД ИЗМЕНЕНИЯМИ" Foreground="#696B74" FontSize="10" FontWeight="Bold" Margin="0,0,0,15"/>
                                    <CheckBox Name="ChkRestorePoint" Content="Создать точку восстановления перед оптимизацией"/>
                                </StackPanel>
                            </Border>

                            <Button Name="BtnOptimize" Style="{StaticResource ActionButton}" Content="⚡   ПРИМЕНИТЬ ВЫБРАННЫЕ НАСТРОЙКИ"/>
                        </StackPanel>
                    </ScrollViewer>

                    <!-- CLEAN -->
                    <ScrollViewer Name="PageClean" Visibility="Hidden" VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <TextBlock Text="Очистка" Foreground="White" FontSize="25" FontWeight="Bold"/>
                            <TextBlock Text="Удаляет временные файлы." Foreground="#777A83" FontSize="11" Margin="0,6,0,21"/>

                            <Border Background="#191A1F" CornerRadius="11" Padding="17" Margin="0,0,0,11">
                                <StackPanel>
                                    <TextBlock Text="TEMP" Foreground="#696B74" FontSize="10" FontWeight="Bold" Margin="0,0,0,15"/>
                                    <CheckBox Name="ChkTemp" Content="Очистить пользовательский и системный Temp"/>
                                </StackPanel>
                            </Border>

                            <Border Background="#191A1F" CornerRadius="11" Padding="17" Margin="0,0,0,14">
                                <StackPanel>
                                    <TextBlock Text="SHADER CACHE" Foreground="#696B74" FontSize="10" FontWeight="Bold" Margin="0,0,0,15"/>
                                    <CheckBox Name="ChkShaderCache" Content="Очистить DirectX / NVIDIA Shader Cache"/>
                                </StackPanel>
                            </Border>

                            <Button Name="BtnClean" Style="{StaticResource ActionButton}" Content="🧹   ОЧИСТИТЬ ВЫБРАННОЕ"/>
                        </StackPanel>
                    </ScrollViewer>

                    <!-- BACKUP -->
                    <ScrollViewer Name="PageBackup" Visibility="Hidden" VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <TextBlock Text="Backup" Foreground="White" FontSize="25" FontWeight="Bold"/>
                            <TextBlock Text="Резервное копирование и точки восстановления." Foreground="#777A83" FontSize="11" Margin="0,6,0,21"/>

                            <Border Background="#1C191A" BorderBrush="#452027" BorderThickness="1" CornerRadius="11" Padding="18" Margin="0,0,0,12">
                                <StackPanel>
                                    <TextBlock Text="🛡  ТОЧКА ВОССТАНОВЛЕНИЯ WINDOWS" Foreground="White" FontSize="14" FontWeight="Bold"/>
                                    <Button Name="BtnRestore" Style="{StaticResource ActionButton}" Content="💾   СОЗДАТЬ ТОЧКУ ВОССТАНОВЛЕНИЯ" Height="48" Margin="0,15,0,0"/>
                                </StackPanel>
                            </Border>

                            <Border Background="#191A1F" CornerRadius="11" Padding="18" Margin="0,0,0,12">
                                <StackPanel>
                                    <TextBlock Text="📦  BACKUP НАСТРОЕК SAYLOW" Foreground="White" FontSize="14" FontWeight="Bold"/>
                                    <Button Name="BtnSettingsBackup" Style="{StaticResource ActionButton}" Content="📦   СОЗДАТЬ BACKUP НАСТРОЕК" Height="48" Margin="0,15,0,0"/>
                                </StackPanel>
                            </Border>

                            <Border Background="#191A1F" CornerRadius="11" Padding="18">
                                <StackPanel>
                                    <TextBlock Text="Где хранятся backup?" Foreground="#D5D6DA" FontSize="11" FontWeight="Bold"/>
                                    <TextBlock Name="TxtBackupPath" Foreground="#777A83" FontSize="10" Margin="0,6,0,0" TextWrapping="Wrap"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>

                    <!-- FOOTER STATUS -->
                    <Border VerticalAlignment="Bottom" Background="#18191E" CornerRadius="8" Padding="10" Margin="0,0,0,0" IsHitTestVisible="False">
                        <Grid>
                            <TextBlock Name="TxtStatus" Text="Готов к работе" Foreground="#C5C6CB" FontSize="10"/>
                            <ProgressBar Name="Progress" Height="4" Minimum="0" Maximum="100" Value="0" VerticalAlignment="Bottom" Margin="0,18,0,0"/>
                        </Grid>
                    </Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

try {
    $StringReader = New-Object System.IO.StringReader($Xaml)
    $XmlReader = [System.Xml.XmlReader]::Create($StringReader)
    $Window = [Windows.Markup.XamlReader]::Load($XmlReader)
} catch {
    [System.Windows.MessageBox]::Show($_.Exception.Message, "SayLow Optimizer - XAML Error")
    exit 1
}

# Resolve controls
[regex]::Matches($Xaml, 'Name="([^"]+)"') | ForEach-Object {
    $n = $_.Groups[1].Value
    Set-Variable -Name $n -Value $Window.FindName($n) -Scope Script
}

# ---------------- UI helpers ----------------

function Set-Status {
    param([string]$Text, [int]$Percent = 0)
    $TxtStatus.Text = $Text
    $Progress.Value = [Math]::Max(0,[Math]::Min(100,$Percent))
    $Window.Dispatcher.Invoke([action]{}, 'Render')
}

function Show-Page {
    param([string]$Page)
    $PageOptimize.Visibility = 'Hidden'
    $PageClean.Visibility = 'Hidden'
    $PageBackup.Visibility = 'Hidden'

    $NavOptimize.Background = '#202126'; $NavClean.Background = '#202126'; $NavBackup.Background = '#202126'
    $NavOptimize.Foreground = '#A9ABB3'; $NavClean.Foreground = '#A9ABB3'; $NavBackup.Foreground = '#A9ABB3'

    switch ($Page) {
        'Optimize' { $PageOptimize.Visibility = 'Visible'; $NavOptimize.Background = '#E50914'; $NavOptimize.Foreground = 'White' }
        'Clean'    { $PageClean.Visibility = 'Visible'; $NavClean.Background = '#E50914'; $NavClean.Foreground = 'White' }
        'Backup'   { $PageBackup.Visibility = 'Visible'; $NavBackup.Background = '#E50914'; $NavBackup.Foreground = 'White' }
    }
}

function Is-Administrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Create-RestorePoint {
    Set-Status "Создание точки восстановления Windows..." 10
    try { Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop } catch {}
    try {
        Checkpoint-Computer -Description 'SayLow Backup' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
        Set-Status "✔ Точка восстановления создана." 100
        return $true
    } catch {
        Set-Status "Error: $($_.Exception.Message)" 100
        return $false
    }
}

# ---------------- Power Plan ----------------

function Apply-SayLowPowerPlan {
    Set-Status "Power Plan: создаем SayLowPerformance..." 25
    $Ultimate = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    $output = (& powercfg -duplicatescheme $Ultimate 2>&1 | Out-String)
    $guid = $null

    if ($output -match '([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})') {
        $guid = $Matches[1]
    }

    if ($guid) {
        & powercfg -changename $guid 'SayLowPerformance' 'Max performance and minimum input lag by SayLow' | Out-Null
        & powercfg -setactive $guid | Out-Null
        Set-Status "✔ SayLowPerformance активирован." 42
        return $true
    }

    $schemes = (& powercfg -list | Out-String)
    $line = ($schemes -split "`r?`n" | Where-Object { $_ -match 'SayLowPerformance' } | Select-Object -First 1)

    if ($line -and $line -match '([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})') {
        $guid = $Matches[1]
        & powercfg -setactive $guid | Out-Null
        Set-Status "✔ Существующий SayLowPerformance активирован." 42
        return $true
    }

    Set-Status "⚠ Не удалось определить GUID Power Plan." 42
    return $false
}

# ---------------- Input lag ----------------

function Apply-InputLag {
    Set-Status "Input Lag: применяем настройки..." 50

    New-Item 'HKCU:\Software\Microsoft\GameBar' -Force | Out-Null
    Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -Name AutoGameModeEnabled -Type DWord -Value 1 -Force

    New-Item 'HKCU:\System\GameConfigStore' -Force | Out-Null
    Set-ItemProperty 'HKCU:\System\GameConfigStore' -Name GameDVR_Enabled -Type DWord -Value 0 -Force

    New-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -Force | Out-Null
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -Name AppCaptureEnabled -Type DWord -Value 0 -Force

    & powercfg -setacvalueindex SCHEME_CURRENT SUB_USB USBSELECTIVE 0 | Out-Null
    & powercfg -setactive SCHEME_CURRENT | Out-Null

    Set-Status "✔ Input Lag настройки применены." 58
}

# ---------------- Background services ----------------

function Optimize-BackgroundServices {
    Set-Status "Сканируем ненужные фоновые службы..." 62

    $ServiceNames = @(
        'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc',
        'DiagTrack', 'dmwappushservice', 'MapsBroker', 'RetailDemo', 'lfsvc',
        'Fax', 'RemoteRegistry', 'PhoneSvc', 'CDPSvc', 'CDPUserSvc', 'WerSvc'
    )

    $changed = 0; $skipped = 0

    foreach ($name in $ServiceNames) {
        $svc = Get-CimInstance Win32_Service -Filter "Name='$name'" -ErrorAction SilentlyContinue
        if (-not $svc) { continue }
        try {
            if ($svc.StartMode -ne 'Disabled') {
                Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $name -StartupType Disabled -ErrorAction SilentlyContinue
                $changed++
            }
        } catch { $skipped++ }
    }

    Set-Status "✔ Службы обрезаны." 73
    return $changed
}

# ---------------- Cleanup ----------------

function Remove-DirectoryContents {
    param([string]$Path)
    $count = 0
    if (-not (Test-Path $Path)) { return 0 }
    Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop; $count++ } catch {}
    }
    return $count
}

function Clean-Temp {
    Set-Status "Очистка Temp..." 20
    $a = Remove-DirectoryContents $env:TEMP
    $b = Remove-DirectoryContents (Join-Path $env:WINDIR 'Temp')
    return ($a + $b)
}

function Clean-ShaderCache {
    Set-Status "Очистка Shader Cache..." 60
    $paths = @((Join-Path $env:LOCALAPPDATA 'D3DSCache'), (Join-Path $env:LOCALAPPDATA 'NVIDIA\DXCache'), (Join-Path $env:LOCALAPPDATA 'NVIDIA\GLCache'))
    $total = 0
    foreach ($p in $paths) { $total += Remove-DirectoryContents $p }
    return $total
}

# ---------------- Full settings backup ----------------

function Create-SayLowBackup {
    Save-SavedSettings
    $stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $dir = Join-Path $BackupRoot "Backup_$stamp"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null

    Copy-Item $ConfigFile (Join-Path $dir 'settings.json') -Force
    & powercfg -list | Out-File (Join-Path $dir 'powerplans.txt') -Encoding UTF8
    & reg.exe export 'HKCU\Software\Microsoft\GameBar' (Join-Path $dir 'GameBar.reg') /y | Out-Null
    & reg.exe export 'HKCU\System\GameConfigStore' (Join-Path $dir 'GameConfigStore.reg') /y | Out-Null
    & reg.exe export 'HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR' (Join-Path $dir 'GameDVR.reg') /y | Out-Null

    return $dir
}

# ---------------- Initial state ----------------

$ChkPowerPlan.IsChecked = $Settings.PowerPlan
$ChkInputLag.IsChecked = $Settings.InputLag
$ChkServices.IsChecked = $Settings.Services
$ChkRestorePoint.IsChecked = $Settings.RestorePoint
$ChkTemp.IsChecked = $Settings.Temp
$ChkShaderCache.IsChecked = $Settings.ShaderCache

$TxtBackupPath.Text = $BackupRoot

@($ChkPowerPlan,$ChkInputLag,$ChkServices,$ChkRestorePoint,$ChkTemp,$ChkShaderCache) | ForEach-Object {
    $_.Add_Click({ Save-SavedSettings })
}

# Navigation & Event Handlers
$NavOptimize.Add_Click({ Show-Page 'Optimize' })
$NavClean.Add_Click({ Show-Page 'Clean' })
$NavBackup.Add_Click({ Show-Page 'Backup' })

# Telegram
$BtnTelegram.Add_Click({
    [System.Diagnostics.Process]::Start($TelegramLink) | Out-Null
})

$BtnClose.Add_Click({ Save-SavedSettings; $Window.Close() })
$BtnMin.Add_Click({ $Window.WindowState = 'Minimized' })

$DragArea.AddHandler([System.Windows.UIElement]::MouseLeftButtonDownEvent, [System.Windows.Input.MouseButtonEventHandler]{ $Window.DragMove() })

# ---------------- Optimize action ----------------

$BtnOptimize.Add_Click({
    Save-SavedSettings
    $BtnOptimize.IsEnabled = $false

    try {
        if ($ChkRestorePoint.IsChecked) {
            if (-not (Create-RestorePoint)) {
                $q = "Не удалось создать точку восстановления. Продолжить?"
                $answer = [System.Windows.MessageBox]::Show($q, $AppName, 'YesNo', 'Warning')
                if ($answer -ne 'Yes') { return }
            }
        }

        if ($ChkPowerPlan.IsChecked) { Apply-SayLowPowerPlan | Out-Null }
        if ($ChkInputLag.IsChecked) { Apply-InputLag }
        if ($ChkServices.IsChecked) { Optimize-BackgroundServices | Out-Null }

        Set-Status "✔ Готово." 100
        [System.Windows.MessageBox]::Show("Оптимизация завершена!", $AppName, 'OK', 'Information') | Out-Null

    } finally {
        $BtnOptimize.IsEnabled = $true
    }
})

# ---------------- Clean action ----------------

$BtnClean.Add_Click({
    Save-SavedSettings
    $BtnClean.IsEnabled = $false

    try {
        $total = 0
        if ($ChkTemp.IsChecked) { $total += Clean-Temp }
        if ($ChkShaderCache.IsChecked) { $total += Clean-ShaderCache }

        Set-Status "✔ Очистка завершена." 100
        [System.Windows.MessageBox]::Show("Очистка завершена! Удалено объектов: $total", $AppName, 'OK', 'Information') | Out-Null

    } finally {
        $BtnClean.IsEnabled = $true
    }
})

# ---------------- Backup actions ----------------

$BtnRestore.Add_Click({
    $BtnRestore.IsEnabled = $false
    try {
        if (Create-RestorePoint) {
            [System.Windows.MessageBox]::Show("Точка восстановления создана.", $AppName, 'OK', 'Information') | Out-Null
        } else {
            [System.Windows.MessageBox]::Show("Ошибка создания точки.", $AppName, 'OK', 'Warning') | Out-Null
        }
    } finally {
        $BtnRestore.IsEnabled = $true
    }
})

$BtnSettingsBackup.Add_Click({
    $BtnSettingsBackup.IsEnabled = $false
    try {
        $dir = Create-SayLowBackup
        Set-Status "✔ Backup создан." 100
        [System.Windows.MessageBox]::Show("Backup создан в: $dir", $AppName, 'OK', 'Information') | Out-Null
    } catch {
        [System.Windows.MessageBox]::Show($_.Exception.Message, $AppName, 'OK', 'Error') | Out-Null
    } finally {
        $BtnSettingsBackup.IsEnabled = $true
    }
})

# ---------------- Startup info ----------------

$TxtSystem.Text = "$([Environment]::OSVersion.VersionString)"
if (Is-Administrator) {
    $TxtAdmin.Text = '✓ Права администратора'
} else {
    $TxtAdmin.Text = '⚠ Нужны права администратора'
}

Show-Page 'Optimize'
Set-Status 'Готов к работе' 0

$Window.ShowDialog() | Out-Null
