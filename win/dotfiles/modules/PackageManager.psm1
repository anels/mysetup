# PackageManager Module - Unified package management abstraction

function Get-InstalledPackages {
    <#
    .SYNOPSIS
        获取已安装包的列表。

    .DESCRIPTION
        根据指定的包管理器类型返回已安装包的名称列表。
        内部辅助函数，供 Install-Packages 使用。

    .PARAMETER PackageManager
        包管理器类型：'scoop'、'pip' 或 'vscode'。

    .OUTPUTS
        String[]. 已安装包的名称数组。
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('scoop', 'pip', 'vscode')]
        [string]$PackageManager
    )

    try {
        switch ($PackageManager) {
            'scoop' {
                $result = scoop list 6>$null
                if ($result) {
                    return $result.Name
                }
                return @()
            }
            'pip' {
                $result = pip list --format=json 2>$null | ConvertFrom-Json
                if ($result) {
                    return $result.name
                }
                return @()
            }
            'vscode' {
                $result = code --list-extensions 2>$null
                if ($result) {
                    return $result
                }
                return @()
            }
        }
    }
    catch {
        Write-Verbose "Failed to retrieve installed packages for $PackageManager`: $($_.Exception.Message)"
        return @()
    }
}

function Get-NormalizeFunction {
    <#
    .SYNOPSIS
        返回包名标准化函数（scriptblock）。

    .DESCRIPTION
        根据包管理器类型返回相应的包名标准化函数。
        pip 需要特殊处理：转小写并将下划线替换为连字符。

    .PARAMETER PackageManager
        包管理器类型：'scoop'、'pip' 或 'vscode'。

    .OUTPUTS
        ScriptBlock. 接受字符串参数并返回标准化后的包名。
    #>
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('scoop', 'pip', 'vscode')]
        [string]$PackageManager
    )

    switch ($PackageManager) {
        'pip' {
            # pip 包名标准化：小写 + 连字符替代下划线
            return { param($name) $name.ToLower() -replace '[-_]', '-' }
        }
        default {
            # scoop 和 vscode 不需要特殊标准化
            return { param($name) $name }
        }
    }
}

function Invoke-PackageInstall {
    <#
    .SYNOPSIS
        执行实际的包安装命令。

    .DESCRIPTION
        根据包管理器类型和选项执行相应的安装命令。
        内部辅助函数，供 Install-Packages 使用。

    .PARAMETER PackageManager
        包管理器类型：'scoop'、'pip' 或 'vscode'。

    .PARAMETER PackageName
        要安装的包名称。

    .PARAMETER GlobalInstall
        (仅 scoop) 是否全局安装。

    .OUTPUTS
        Boolean. 安装是否成功（$LASTEXITCODE -eq 0）。
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('scoop', 'pip', 'vscode')]
        [string]$PackageManager,

        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [Parameter()]
        [switch]$GlobalInstall
    )

    try {
        switch ($PackageManager) {
            'scoop' {
                if ($GlobalInstall) {
                    scoop install -g $PackageName 2>&1 | Out-Null
                }
                else {
                    scoop install $PackageName 2>&1 | Out-Null
                }
            }
            'pip' {
                pip install -U $PackageName 2>&1 | Out-Null
            }
            'vscode' {
                code --install-extension $PackageName 2>&1 | Out-Null
            }
        }

        return ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE)
    }
    catch {
        Write-Verbose "Installation command failed: $($_.Exception.Message)"
        return $false
    }
}

function Install-Packages {
    <#
    .SYNOPSIS
        统一的包管理器安装接口，支持 scoop、pip 和 VSCode 扩展。

    .DESCRIPTION
        Install-Packages 提供统一的包安装抽象，支持三种包管理器：
        - scoop: Windows 包管理器，支持全局安装（-GlobalInstall）
        - pip: Python 包管理器，自动标准化包名（小写 + 连字符）
        - vscode: Visual Studio Code 扩展管理器

        功能特性：
        - 自动检测并跳过已安装的包
        - 彩色输出：已安装=灰色，安装中=绿色，成功=绿色，失败=红色
        - 返回详细的安装摘要（总数、成功、失败、跳过）
        - 支持 -WhatIf（预览模式）和 -Verbose（详细日志）
        - 错误处理：包管理器不可用时提前报错

    .PARAMETER PackageManager
        包管理器类型，可选值：'scoop'、'pip'、'vscode'。

    .PARAMETER Packages
        要安装的包名称数组（字符串数组）。

    .PARAMETER GlobalInstall
        (仅 scoop 有效) 是否全局安装包（需要管理员权限）。

    .EXAMPLE
        Install-Packages -PackageManager 'scoop' -Packages @('git', 'nodejs', 'python')

        安装 scoop 包到用户目录（默认）。

    .EXAMPLE
        Install-Packages -PackageManager 'scoop' -Packages @('vcredist2022') -GlobalInstall

        全局安装 scoop 包（通常用于系统级依赖）。

    .EXAMPLE
        Install-Packages -PackageManager 'pip' -Packages @('requests', 'pandas', 'numpy') -Verbose

        安装 Python 包，显示详细日志。包名会自动标准化（例如：Django-Rest-Framework → django-rest-framework）。

    .EXAMPLE
        Install-Packages -PackageManager 'vscode' -Packages @('ms-python.python', 'esbenp.prettier-vscode')

        安装 VSCode 扩展。

    .EXAMPLE
        Install-Packages -PackageManager 'scoop' -Packages @('git', 'nodejs') -WhatIf

        预览安装操作，但不实际执行（仅显示将要安装的包）。

    .OUTPUTS
        PSCustomObject. 包含以下字段的安装摘要：
        - PackageManager (string): 使用的包管理器
        - Total (int): 请求安装的包总数
        - Installed (int): 成功安装的包数量
        - Failed (int): 安装失败的包数量
        - Skipped (int): 跳过的包数量（已安装或 WhatIf）
        - Results (array): 每个包的详细结果（Package、Status、Error）

    .NOTES
        - 要求对应的包管理器命令（scoop/pip/code）在系统 PATH 中可用
        - pip 包名会自动标准化：转小写并将下划线/连字符统一为连字符
        - scoop 全局安装（-GlobalInstall）通常需要管理员权限
        - 已安装的包会自动跳过，不会重复安装
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('scoop', 'pip', 'vscode')]
        [string]$PackageManager,

        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]$Packages,

        [Parameter()]
        [switch]$GlobalInstall
    )

    # 验证包管理器是否可用
    $managerCommand = switch ($PackageManager) {
        'scoop' { 'scoop' }
        'pip' { 'pip' }
        'vscode' { 'code' }
    }

    if (-not (Get-Command $managerCommand -ErrorAction SilentlyContinue)) {
        throw "$PackageManager is not available. Please install $managerCommand first."
    }

    # 初始化摘要对象
    $summary = [PSCustomObject]@{
        PackageManager = $PackageManager
        Total          = $Packages.Count
        Installed      = 0
        Failed         = 0
        Skipped        = 0
        Results        = @()
    }

    # 获取已安装包列表
    Write-Verbose "Retrieving installed packages for $PackageManager..."
    $installedPackages = Get-InstalledPackages -PackageManager $PackageManager
    $normalizeFunc = Get-NormalizeFunction -PackageManager $PackageManager

    # 标准化已安装包列表（用于比较）
    $normalizedInstalled = $installedPackages | ForEach-Object { & $normalizeFunc $_ }

    Write-Host "`nInstalling $($Packages.Count) package(s) using $PackageManager..." -ForegroundColor Cyan
    if ($GlobalInstall -and $PackageManager -eq 'scoop') {
        Write-Host "(Global installation enabled)" -ForegroundColor Yellow
    }

    foreach ($package in $Packages) {
        $result = [PSCustomObject]@{
            Package = $package
            Status  = ""
            Error   = $null
        }

        # 检查是否已安装（标准化后比较）
        $normalizedPackage = & $normalizeFunc $package
        $isInstalled = $normalizedPackage -in $normalizedInstalled

        if ($isInstalled) {
            $result.Status = "AlreadyInstalled"
            $summary.Skipped++
            Write-Host "  $package" -NoNewline -ForegroundColor DarkGray
            Write-Host " (already installed)" -ForegroundColor DarkGray
        }
        elseif ($PSCmdlet.ShouldProcess($package, "Install using $PackageManager")) {
            Write-Host "  Installing $package..." -NoNewline -ForegroundColor Green

            $installParams = @{
                PackageManager = $PackageManager
                PackageName    = $package
            }
            if ($GlobalInstall) {
                $installParams['GlobalInstall'] = $true
            }

            $installSuccess = Invoke-PackageInstall @installParams

            if ($installSuccess) {
                $result.Status = "Installed"
                $summary.Installed++
                Write-Host " OK" -ForegroundColor Green
            }
            else {
                $result.Status = "Failed"
                $result.Error = "Installation command exited with code $LASTEXITCODE"
                $summary.Failed++
                Write-Host " FAILED" -ForegroundColor Red
                Write-Verbose "Error: Installation command returned exit code $LASTEXITCODE"
            }
        }
        else {
            # WhatIf mode
            $result.Status = "WhatIf"
            $summary.Skipped++
            Write-Host "  Would install: $package" -ForegroundColor Yellow
        }

        $summary.Results += $result
    }

    # 输出摘要
    Write-Host "`n=== Installation Summary ===" -ForegroundColor Cyan
    Write-Host "Package Manager: $PackageManager" -ForegroundColor White
    Write-Host "Total: $($summary.Total)" -ForegroundColor White
    Write-Host "Installed: $($summary.Installed)" -ForegroundColor Green
    Write-Host "Failed: $($summary.Failed)" -ForegroundColor Red
    Write-Host "Skipped: $($summary.Skipped)" -ForegroundColor Yellow

    return $summary
}

# 导出公共函数
Export-ModuleMember -Function Install-Packages
