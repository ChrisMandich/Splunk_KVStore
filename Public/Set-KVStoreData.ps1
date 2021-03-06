function Set-KVStoreData {
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

    .PARAMETER SkipCertificateCheck
        Allows SkipCertificateCheck Certificates to be used

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
        [Object] $Body = $(Throw "Please provide a Body as a paremeter"),
        [Switch] $SkipCertificateCheck = $False,
        [Switch] $BatchSave = $False
    )
    Begin{
        # Provide Entrance Context
    }
    process {
        $Params = @{
            #Sets the HTTP Method to Post, this adds the Body to the current KV Store
            'Method' = "Post"
            'ContentType' = "application/json"
            # Add additional required Parameters
        }

        #Allows for self-signed certificates
        if ($SkipCertificateCheck -eq $true){
            $params.Add('SkipCertificateCheck',$true)
        }

        if ($PSBoundParameters.ContainsKey('Credential')){
            $params.Add('Credential',$Credential)
        }
        else{
            # Provide Error Output
            Write-Error "Credential not provided"
        }

        if ($PSBoundParameters.ContainsKey('SplunkApp') -And $PSBoundParameters.ContainsKey('Uri') -And $PSBoundParameters.ContainsKey('KVStoreName')){
            # Check to see if Batch Save flag is specified. Append URI if Batch Save is listed.
            # https://localhost:8089/servicesNS/nobody/kvstoretest/storage/collections/data/kvstorecoll
            if ($BatchSave -eq $True){
                [Uri] $SplunkAppUri = $Uri.AbsoluteUri + "servicesNS/" + $SplunkAppOwner + "/" + $SplunkApp + "/storage/collections/data/" + $KVStoreName + "/batch_save"
            }
            else {
                [Uri] $SplunkAppUri = $Uri.AbsoluteUri + "servicesNS/" + $SplunkAppOwner + "/" + $SplunkApp + "/storage/collections/data/" + $KVStoreName
            }

            $params.Add('Uri',$SplunkAppUri)
        }
        else{
            # Provide Error Output
            Write-Error "Error creating URI"
        }

        if ($PSBoundParameters.ContainsKey('Body')){
            $params.Add('Body',$Body)
        }
        else{
            # Provide Error Output
            Write-Error "Body not provided"
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
