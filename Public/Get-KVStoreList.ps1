function Get-KVStoreList {
    <#
    .SYNOPSIS
        This function can be used to get a list of the available KVSTORES from a spcified SplunkApp

    .DESCRIPTION
        Performs a REST request to the specified Splunk Server and returns the available KVStore for a defined Splunk App

    .PARAMETER Credential
        Specifies a user account that has permission to send the request. Type is a PSCredential Object

    .PARAMETER Uri
        URI in the form of https://sh.splunk.com:8089

    .PARAMETER SplunkApp
        Splunk App where the KVStoreData is stored

    .PARAMETER SplunkAppOwner
        Splunk App Owner

    .PARAMETER SelfSignedCert
        Allows SelfSigned Certificates to be used

    .OUTPUTS
        Output is the content returned from the request

    .EXAMPLE
        Get-KVStoreList -Credential $cred -Uri $uri -SplunkApp "search"

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
        [Switch] $SelfSignedCert = $False
    )
    Begin{
        # Provide Entrance Context
    }
    process {
        $Params = @{
            #'Method' = "Post"
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

        if ($PSBoundParameters.ContainsKey('SplunkApp') -And $PSBoundParameters.ContainsKey('Uri')){
            # Specified Splunk App
            [Uri] $SplunkAppUri = $Uri.AbsoluteUri + "servicesNS/" + $SplunkAppOwner + "/" + $SplunkApp + "/storage/collections/config"
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
