function Remove-KVStoreKey {
    <#
    .SYNOPSIS
        This function can be used to post data to the specified KVSTORE

    .DESCRIPTION
        Performs a REST request with the HTTP Method of Post to the specified Splunk Server and adds the data to a defined KVSTORE

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

    .PARAMETER KVStoreKey
        Splunk KVStore _key to be affected

    .PARAMETER SelfSignedCert
        Allows SelfSigned Certificates to be used

    .PARAMETER BatchSave
        Allows for batch saves, in which multiple JSON elements can be saved at a time when specified in an array.

    .PARAMETER Body
        Specifies the body of the request. The body is the content of the request that follows the headers. Required format is JSON.

    .OUTPUTS
        Output is the _key where the item is stored

    .EXAMPLE
        Set-KVStoreData -Credential $cred -Uri $uri -SplunkApp "search" -KVStoreName "kv_Store_name" -Body $jsonBody

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
        [String] $KVStoreKey = $(Throw "Please provide a KVStoreKey as a a parameter"),
        [Switch] $SelfSignedCert = $False
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
        if ($SelfSignedCert -eq $true){
            # TODO
            # http://huddledmasses.org/blog/validating-self-signed-certificates-properly-from-powershell/
        }

        if ($PSBoundParameters.ContainsKey('Credential')){
            $params.Add('Credential',$Credential)
        }
        else{
            # Provide Error Output
            Throw "Credential not provided"
        }

        if ($PSBoundParameters.ContainsKey('SplunkApp') -And $PSBoundParameters.ContainsKey('Uri') -And $PSBoundParameters.ContainsKey('KVStoreName') -And $PSBoundParameters.ContainsKey('KVStoreKey')){
            # Check to see if Batch Save flag is specified. Append URI if Batch Save is listed.
            # https://localhost:8089/servicesNS/nobody/kvstoretest/storage/collections/data/kvstorecoll/<_key>
            [Uri] $SplunkAppUri = $Uri.AbsoluteUri + "servicesNS/" + $SplunkAppOwner + "/" + $SplunkApp + "/storage/collections/data/" + $KVStoreName + "/" + $KVStoreKey
            $params.Add('Uri',$SplunkAppUri)
        }
        else{
            # Provide Error Output
            Throw "Error creating URI"
        }

        # Invoke Rest Method
        try{
            Invoke-RestMethod @Params
        }
        catch{
            write-host $error[0]
        }
    }
    End{
        # Provide exit context
    }
}
