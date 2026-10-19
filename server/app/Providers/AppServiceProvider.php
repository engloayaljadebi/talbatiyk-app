<?php

namespace App\Providers;

use App\Models\User;
use App\OpenApi\ApplyCommercialInputBounds;
use Dedoc\Scramble\Scramble;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::define('reviewSupplierApprovals', static function (User $user): bool {
            // Fresh database check prevents stale in-memory user status.
            $isActive = User::query()
                ->whereKey($user->getKey())
                ->where('status', 'active')
                ->exists();

            if (! $isActive) {
                return false;
            }

            // Business owner/manager roles do not grant platform access.
            return DB::table('platform_role_assignments')
                ->where('user_id', $user->getKey())
                ->where('role_code', 'platform_admin')
                ->whereNull('revoked_at')
                ->exists();
        });

        Scramble::afterOpenApiGenerated(
            new ApplyCommercialInputBounds,
        );
    }
}
