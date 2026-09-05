<?php

namespace App\OpenApi;

use App\Http\Requests\Api\V1\Order\CreateOrderRequest;
use App\Http\Requests\Api\V1\Order\SubmitSupplierOrderResponseRequest;
use Dedoc\Scramble\Support\Generator\OpenApi;
use Dedoc\Scramble\Support\Generator\Schema;
use Dedoc\Scramble\Support\Generator\Types\ArrayType;
use Dedoc\Scramble\Support\Generator\Types\NumberType;
use Dedoc\Scramble\Support\Generator\Types\ObjectType;
use LogicException;

final class ApplyCommercialInputBounds
{
    public function __invoke(OpenApi $openApi): void
    {
        $this->apply(
            openApi: $openApi,
            requestClass: CreateOrderRequest::class,
            ruleKey: 'items.*.expected_unit_price',
            propertyName: 'expected_unit_price',
        );

        $this->apply(
            openApi: $openApi,
            requestClass:
                SubmitSupplierOrderResponseRequest::class,
            ruleKey: 'items.*.offered_unit_price',
            propertyName: 'offered_unit_price',
        );
    }

    /**
     * @param class-string $requestClass
     */
    private function apply(
        OpenApi $openApi,
        string $requestClass,
        string $ruleKey,
        string $propertyName,
    ): void {
        $exclusiveMaximum =
            $this->exclusiveMaximumFromRules(
                $requestClass,
                $ruleKey,
            );

        $schema =
            $this->resolveSchema(
                $openApi,
                $requestClass,
            );

        if (! $schema->type instanceof ObjectType) {
            throw new LogicException(
                "{$requestClass} must generate an object schema.",
            );
        }

        $items =
            $schema->type->getProperty('items');

        if (! $items instanceof ArrayType) {
            throw new LogicException(
                "{$requestClass}.items must be an array schema.",
            );
        }

        if (! $items->items instanceof ObjectType) {
            throw new LogicException(
                "{$requestClass}.items[] must be an object schema.",
            );
        }

        $current =
            $items->items->getProperty(
                $propertyName,
            );

        if (! $current instanceof NumberType) {
            throw new LogicException(
                "{$requestClass}.{$propertyName} "
                .'must generate a number schema.',
            );
        }

        if (
            $current->min !== 0
            && $current->min !== 0.0
        ) {
            throw new LogicException(
                "{$requestClass}.{$propertyName} "
                .'must retain minimum 0 before '
                .'the exclusive-maximum transform.',
            );
        }

        $replacement =
            new ExclusiveMaximumNumberType(
                $exclusiveMaximum,
            );

        $replacement->addProperties($current);
        $replacement->setMin(0);

        $items->items->addProperty(
            $propertyName,
            $replacement,
        );
    }

    /**
     * @param class-string $requestClass
     */
    private function exclusiveMaximumFromRules(
        string $requestClass,
        string $ruleKey,
    ): int {
        $request = new $requestClass;

        $rules = $request->rules();

        if (! array_key_exists($ruleKey, $rules)) {
            throw new LogicException(
                "Missing validation rule set: {$ruleKey}.",
            );
        }

        foreach ((array) $rules[$ruleKey] as $rule) {
            if (
                ! is_string($rule)
                || ! str_starts_with($rule, 'lt:')
            ) {
                continue;
            }

            $value = substr($rule, 3);

            if (
                $value === ''
                || ! ctype_digit($value)
            ) {
                throw new LogicException(
                    "The {$ruleKey} lt rule must use "
                    .'an integer exclusive ceiling.',
                );
            }

            return (int) $value;
        }

        throw new LogicException(
            "Missing lt rule for {$ruleKey}.",
        );
    }

    /**
     * @param class-string $requestClass
     */
    private function resolveSchema(
        OpenApi $openApi,
        string $requestClass,
    ): Schema {
        if (
            $openApi->components
                ->hasSchema($requestClass)
        ) {
            return $openApi->components
                ->getSchema($requestClass);
        }

        $shortName =
            class_basename($requestClass);

        $matches = [];

        foreach (
            $openApi->components->schemas
            as $name => $schema
        ) {
            if (
                class_basename($name)
                === $shortName
            ) {
                $matches[] = $schema;
            }
        }

        if (count($matches) !== 1) {
            throw new LogicException(
                "Unable to resolve OpenAPI schema "
                ."for {$requestClass}.",
            );
        }

        return $matches[0];
    }
}