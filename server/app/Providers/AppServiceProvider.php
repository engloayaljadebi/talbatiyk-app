<?php

namespace App\Providers;

use App\Models\User;
use App\OpenApi\ApplyCommercialInputBounds;
use Aws\CommandInterface;
use Aws\Middleware;
use Dedoc\Scramble\Scramble;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
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
        Storage::extend('supabase-s3', static function ($app, array $config) {
            $disk = $app['filesystem']->createS3Driver($config);

            // Supabase manages visibility at the bucket level and does not support object ACLs.
            $disk->getClient()->getHandlerList()->appendInit(
                Middleware::mapCommand(static function (CommandInterface $command): CommandInterface {
                    unset($command['ACL']);

                    return $command;
                }),
                'supabase-storage-acl',
            );

            return $disk;
        });

        $platformAdminAbility = static function (User $user): bool {
            // Always check the current user status in the database.
            $isActive = User::query()
                ->whereKey($user->getKey())
                ->where('status', 'active')
                ->exists();

            if (! $isActive) {
                return false;
            }

            return DB::table('platform_role_assignments')
                ->where('user_id', $user->getKey())
                ->where('role_code', 'platform_admin')
                ->whereNull('revoked_at')
                ->exists();
        };

        Gate::define('reviewSupplierApprovals', $platformAdminAbility);
        Gate::define('manageUsers', $platformAdminAbility);
        Gate::define('manageBusinessCategories', $platformAdminAbility);

        Scramble::afterOpenApiGenerated(
            new ApplyCommercialInputBounds,
        );
    }
}
