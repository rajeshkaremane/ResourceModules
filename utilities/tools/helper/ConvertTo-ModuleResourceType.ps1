﻿<#
.SYNOPSIS
Try to find the actual provider namespace and resource type for a given resource identifier.

.DESCRIPTION
Try to find the actual provider namespace and resource type for a given resource identifier.
For example, for 'virtual-machine-images/image-template' it we want to find 'Microsoft.VirtualMachineImages/imageTemplates'.

.PARAMETER ResourceIdentifier
Mandatory. The resource identifier to search for.

.PARAMETER SpecsFilePath
Optional. The path to the specs file that contains all available provider namespaces & resource types. Defaults to 'utilities/src/apiSpecsList.json'.

.EXAMPLE
ConvertTo-ModuleResourceType -ResourceIdentifier 'storage/storage-account/blob-service/container/immutability-policy'.

Returns 'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies'.
#>
function ConvertTo-ModuleResourceType {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ResourceIdentifier
    )

    . (Join-Path $PSScriptRoot 'Get-SpecsAlignedResourceName.ps1')

    $provider, $parentType, $childTypeString = $ResourceIdentifier -split '/', 3
    $parentResourceIdentifier = $provider, $parentType -join '/'

    $fullParentResourceType = Get-SpecsAlignedResourceName -ResourceIdentifier $parentResourceIdentifier

    if (-not $childTypeString) {
        $fullResourceType = $fullParentResourceType
    } else {
        $childTypeArray = $childTypeString.Split('/')

        $innerResourceType = $fullParentResourceType
        foreach ($childType in $childTypeArray) {
            $innerResourceType = $innerResourceType.Replace('Microsoft.', ''), $childType -join '/'
            $fullResourceType = Get-SpecsAlignedResourceName -ResourceIdentifier $innerResourceType
            $innerResourceType = $fullResourceType
        }
    }

    return $fullResourceType
}
