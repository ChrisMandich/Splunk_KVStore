function Clear-KVStoreData {
    <#
    .SYNOPSIS
        This function can be used to clear all data from the specified KVSTORE

    .DESCRIPTION
        Performs a REST request with the HTTP Method of Delete to the specified Splunk Server and clears the data for a defined KVSTORE

    .PARAMETER Credential
        Specifies a user account that has permission to send the request. Type is a PSCredential Object

    .PARAMETER Uri
        URI in the form of https://sh.splunk.com:8089

    .PARAMETER SplunkApp
        Splunk App where the KVStoreData is stored

    .PARAMETER SplunkAppOwner
        Splunk App Owner

    .PARAMETER KVStoreName
        Splunk KVStoreName (Get-KVStoreList can be used to find KVStore Names)

    .PARAMETER SkipCertificateCheck
        Allows SkipCertificateCheck Certificates to be used

    .EXAMPLE
        Clear-KVStoreData -Credential $cred -Uri $uri -SplunkApp "search" -KVStoreName "kv_Store_name"

    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.Management.Automation.PSCredential]$Credential,
        [Uri] $Uri = $(Throw "Please provide a URI as a parameter"),
        [String] $SplunkApp = $(Throw "Please provide a SplunkApp as a parameter"),
        [String] $SplunkAppOwner = "nobody",
        [String] $KVStoreName = $(Throw "Please provide a KVStoreName as a parameter"),
        [Switch] $SkipCertificateCheck = $False
    )
    Begin{
        # Provide Entrance Context
    }
    process {
        $Params = @{
            #Sets the HTTP Method to Delete, this requests deletes the data from the KVStore
            'Method' = "Delete"
            # Add additional required Parameters
        }
        if ($SkipCertificateCheck -eq $true){
            # TODO
            $params.add('SkipCertificateCheck',$true)
        }

        if ($PSBoundParameters.ContainsKey('Credential')){
            $params.Add('Credential',$Credential)
        }
        else{
            # Provide Error Output
            Write-Error "Credential not provided"
        }

        if ($PSBoundParameters.ContainsKey('SplunkApp') -And $PSBoundParameters.ContainsKey('Uri') -And $PSBoundParameters.ContainsKey('KVStoreName')){
            # Specified Splunk App
            # https://localhost:8089/servicesNS/nobody/kvstoretest/storage/collections/data/kvstorecoll
            [Uri] $SplunkAppUri = $Uri.AbsoluteUri + "servicesNS/" + $SplunkAppOwner + "/" + $SplunkApp + "/storage/collections/data/" + $KVStoreName
            $params.Add('Uri',$SplunkAppUri)
        }
        else{
            # Provide Error Output
            Write-Error "Error creating URI"
        }

        # Invoke Rest Method
        try{
            Invoke-RestMethod @Params
        }
        catch{
            Write-Error "Failed to Invoke Restmethod"
        }
    }
    End{
        # Provide exit context
    }
}
