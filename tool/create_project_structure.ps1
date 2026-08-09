# =============================================================================
# Talbatiyk Project Structure Builder
# =============================================================================
#
# Purpose:
# - Keep the existing project architecture.
# - Create only missing directories.
# - Never overwrite existing files.
# - Never create placeholder PHP or Dart files.
# - Never create future Models or Migrations.
#
# =============================================================================

$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path

if (-not (Test-Path (Join-Path $Root "pubspec.yaml"))) {
    throw "Run this script from the Talbatiyk project root."
}

if (-not (Test-Path (Join-Path $Root "server\artisan"))) {
    throw "Laravel server\artisan was not found."
}

$CreatedDirectories = 0
$ExistingDirectories = 0


function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $FullPath = Join-Path $Root $RelativePath

    if (Test-Path $FullPath -PathType Container) {
        $script:ExistingDirectories++
        Write-Host "[EXISTS] $RelativePath"
        return
    }

    New-Item `
        -ItemType Directory `
        -Path $FullPath `
        -Force | Out-Null

    $script:CreatedDirectories++

    Write-Host "[CREATE] $RelativePath"
}


# =============================================================================
# Flutter Core
# =============================================================================

$FlutterCoreDirectories = @(
    "lib\core\config",

    "lib\core\database",
    "lib\core\database\daos",
    "lib\core\database\tables",
    "lib\core\database\migrations",

    "lib\core\di",

    "lib\core\network",
    "lib\core\network\clients",
    "lib\core\network\interceptors",
    "lib\core\network\generated",

    "lib\core\router",

    "lib\core\storage",

    "lib\core\sync",
    "lib\core\sync\queue",
    "lib\core\sync\workers",
    "lib\core\sync\conflict",
    "lib\core\sync\models",

    "lib\core\errors",
    "lib\core\logging",
    "lib\core\theme",
    "lib\core\utils"
)

foreach ($Directory in $FlutterCoreDirectories) {
    Ensure-Directory $Directory
}


# =============================================================================
# Flutter Features
# =============================================================================

$FlutterFeatures = @(
    "auth",
    "businesses",
    "verification",
    "follows",
    "products",
    "cart",
    "orders",
    "account",
    "notifications",
    "home",
    "navigation"
)

$FlutterFeatureDirectories = @(
    "data",
    "data\datasources",
    "data\datasources\local",
    "data\datasources\remote",
    "data\models",
    "data\repositories",

    "domain",
    "domain\entities",
    "domain\repositories",
    "domain\usecases",

    "presentation",
    "presentation\controllers",
    "presentation\providers",
    "presentation\pages",
    "presentation\widgets"
)

foreach ($Feature in $FlutterFeatures) {
    foreach ($Directory in $FlutterFeatureDirectories) {
        Ensure-Directory "lib\features\$Feature\$Directory"
    }
}


# =============================================================================
# Laravel Controllers
# =============================================================================

$LaravelControllerModules = @(
    "Auth",
    "Business",
    "Verification",
    "Follow",
    "Product",
    "Order"
)

foreach ($Module in $LaravelControllerModules) {
    Ensure-Directory "server\app\Http\Controllers\Api\V1\$Module"
}


# =============================================================================
# Laravel Requests
# =============================================================================

$LaravelRequestModules = @(
    "Auth",
    "Business",
    "Verification",
    "Follow",
    "Product",
    "Order"
)

foreach ($Module in $LaravelRequestModules) {
    Ensure-Directory "server\app\Http\Requests\Api\V1\$Module"
}


# =============================================================================
# Laravel Resources and Middleware
# =============================================================================

Ensure-Directory "server\app\Http\Resources\Api\V1"
Ensure-Directory "server\app\Http\Middleware"


# =============================================================================
# Laravel Services
# =============================================================================

$LaravelServiceModules = @(
    "Auth",
    "Authorization",
    "Business",
    "Verification",
    "Follow",
    "Product",
    "Order",
    "Sync"
)

foreach ($Module in $LaravelServiceModules) {
    Ensure-Directory "server\app\Services\$Module"
}


# =============================================================================
# Laravel Application Structure
# =============================================================================

Ensure-Directory "server\app\Models"
Ensure-Directory "server\app\Support"
Ensure-Directory "server\app\Policies"
Ensure-Directory "server\app\Enums"
Ensure-Directory "server\app\Jobs"
Ensure-Directory "server\app\Notifications"


# =============================================================================
# Laravel Database
# =============================================================================

Ensure-Directory "server\database\migrations"
Ensure-Directory "server\database\factories"
Ensure-Directory "server\database\seeders"


# =============================================================================
# Laravel Feature Tests
# =============================================================================

$LaravelFeatureTestModules = @(
    "Auth",
    "Business",
    "Verification",
    "Follow",
    "Product",
    "Order",
    "Middleware"
)

foreach ($Module in $LaravelFeatureTestModules) {
    Ensure-Directory "server\tests\Feature\Api\V1\$Module"
}


# =============================================================================
# Laravel Unit Tests
# =============================================================================

$LaravelUnitTestModules = @(
    "Auth",
    "Business",
    "Verification",
    "Follow",
    "Product",
    "Order",
    "Sync"
)

foreach ($Module in $LaravelUnitTestModules) {
    Ensure-Directory "server\tests\Unit\Services\$Module"
}

Ensure-Directory "server\tests\Unit\Policies"
Ensure-Directory "server\tests\Unit\Support"


# =============================================================================
# Flutter Tests
# =============================================================================

$FlutterTestFeatures = @(
    "auth",
    "businesses",
    "verification",
    "follows",
    "products",
    "cart",
    "orders"
)

foreach ($Feature in $FlutterTestFeatures) {
    Ensure-Directory "test\features\$Feature"
}

Ensure-Directory "test\core\database"
Ensure-Directory "test\core\network"
Ensure-Directory "test\core\sync"


# =============================================================================
# Integration Tests
# =============================================================================

Ensure-Directory "integration_test"
Ensure-Directory "integration_test\auth_business_flow"
Ensure-Directory "integration_test\product_order_flow"
Ensure-Directory "integration_test\offline_sync_flow"


# =============================================================================
# OpenAPI Contract
# =============================================================================

Ensure-Directory "contracts"
Ensure-Directory "contracts\openapi"


# =============================================================================
# Documentation
# =============================================================================

Ensure-Directory "docs\architecture"
Ensure-Directory "docs\api"
Ensure-Directory "docs\database"
Ensure-Directory "docs\sync"
Ensure-Directory "docs\decisions"


# =============================================================================
# Tooling
# =============================================================================

Ensure-Directory "tool"


# =============================================================================
# Summary
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "Talbatiyk project structure completed successfully."
Write-Host "============================================================"
Write-Host ""
Write-Host "Created directories : $CreatedDirectories"
Write-Host "Existing directories: $ExistingDirectories"
Write-Host ""
Write-Host "No existing files were modified."
Write-Host "No placeholder files were created."
Write-Host "No Laravel Models were created."
Write-Host "No Migrations were created."
Write-Host ""