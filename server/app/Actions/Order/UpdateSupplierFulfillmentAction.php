<?php

namespace App\Actions\Order;

use App\Enums\Order\FulfillmentStatus;
use App\Models\Business;
use App\Models\OrderItemSelection;
use App\Models\OrderRecipient;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;

class UpdateSupplierFulfillmentAction
{
    /**
     * @param array{
     *     expected_version: int,
     *     status: string
     * } $data
     */
    public function execute(
        Business $business,
        string $recipientId,
        User $actor,
        array $data,
    ): OrderRecipient {
        return DB::transaction(function () use (
            $business,
            $recipientId,
            $actor,
            $data,
        ): OrderRecipient {
            $recipient = OrderRecipient::query()
                ->whereKey($recipientId)
                ->where('supplier_id', $business->id)
                ->lockForUpdate()
                ->firstOrFail();

            $currentVersion = (int) $recipient->fulfillment_version;
            $expectedVersion = (int) $data['expected_version'];

            if ($currentVersion !== $expectedVersion) {
                throw new ConflictHttpException(
                    'The fulfillment version is stale. Refresh the received order and retry.',
                );
            }

            $hasSelection = OrderItemSelection::query()
                ->whereHas(
                    'responseItem.recipientItem',
                    static function ($query) use ($recipient): void {
                        $query->where(
                            'order_recipient_id',
                            $recipient->id,
                        );
                    },
                )
                ->exists();

            $currentStatus = $recipient->fulfillment_status;

            if ($currentStatus === null) {
                if (! $hasSelection) {
                    throw new ConflictHttpException(
                        'Supplier fulfillment cannot start before the customer selects this supplier.',
                    );
                }

                $currentStatus = FulfillmentStatus::Confirmed;
            }

            $targetStatus = FulfillmentStatus::from(
                (string) $data['status'],
            );

            $expectedNextStatus = $this->nextStatus($currentStatus);

            if ($expectedNextStatus !== $targetStatus) {
                throw new ConflictHttpException(
                    'The requested fulfillment status transition is not allowed.',
                );
            }

            $recipient->fulfillment_status = $targetStatus;
            $recipient->fulfillment_version = $currentVersion + 1;
            $recipient->save();

            $recipient->fulfillmentHistory()->create([
                'actor_user_id' => $actor->id,
                'from_status' => $currentStatus->value,
                'to_status' => $targetStatus->value,
            ]);

            return $recipient->load([
                'order:id,status,notes,created_at,updated_at',
                'items.orderItem:id,order_id,product_id,product_name,unit_price,quantity,image_url',
                'items.response.selection',
                'response.items',
            ]);
        });
    }

    private function nextStatus(
        FulfillmentStatus $status,
    ): ?FulfillmentStatus {
        return match ($status) {
            FulfillmentStatus::Confirmed => FulfillmentStatus::Preparing,

            FulfillmentStatus::Preparing => FulfillmentStatus::ReadyForDelivery,

            FulfillmentStatus::ReadyForDelivery => FulfillmentStatus::OutForDelivery,

            FulfillmentStatus::OutForDelivery => FulfillmentStatus::Delivered,

            FulfillmentStatus::Delivered => null,
        };
    }
}
