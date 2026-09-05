<?php

namespace App\OpenApi;

use Dedoc\Scramble\Support\Generator\Types\NumberType;

final class ExclusiveMaximumNumberType extends NumberType
{
    public function __construct(
        private readonly int $exclusiveMaximum,
    ) {
        parent::__construct();
    }

    public function toArray()
    {
        return array_merge(
            parent::toArray(),
            [
                'exclusiveMaximum' =>
                    $this->exclusiveMaximum,
            ],
        );
    }
}