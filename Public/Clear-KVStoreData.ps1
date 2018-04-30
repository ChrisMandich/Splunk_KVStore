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

    .PARAMETER SelfSignedCert
        Allows SelfSigned Certificates to be used

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
            Add-Type @"
                using System;
                using System.Net;
                using System.Net.Security;
                using System.Security.Cryptography.X509Certificates;
                public class ServerCertificateValidationCallback
                {
                    public static void Ignore()
                    {
                        ServicePointManager.ServerCertificateValidationCallback +=
                            delegate
                            (
                                Object obj,
                                X509Certificate certificate,
                                X509Chain chain,
                                SslPolicyErrors errors
                            )
                            {
                                return true;
                            };
                    }
                }
"@
        }

        if ($PSBoundParameters.ContainsKey('Credential')){
            $params.Add('Credential',$Credential)
        }
        else{
            # Provide Error Output
            Throw "Credential not provided"
        }

        if ($PSBoundParameters.ContainsKey('SplunkApp') -And $PSBoundParameters.ContainsKey('Uri') -And $PSBoundParameters.ContainsKey('KVStoreName')){
            # Specified Splunk App
            # https://localhost:8089/servicesNS/nobody/kvstoretest/storage/collections/data/kvstorecoll
            [Uri] $SplunkAppUri = $Uri.AbsoluteUri + "servicesNS/" + $SplunkAppOwner + "/" + $SplunkApp + "/storage/collections/data/" + $KVStoreName
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
            Throw $error[0]
        }
    }
    End{
        # Provide exit context
    }
}
