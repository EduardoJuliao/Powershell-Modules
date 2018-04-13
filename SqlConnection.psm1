<# 
 .Description
  Creates a new closed connection with the database

 .Parameter SQLServer
  The name or Ip of the SqlServer

 .Parameter SQLDBName
  The databaseName.
#>
function New-SqlConnection {
    [OutputType([System.Data.SqlClient.SqlConnection])]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]$SQLServer,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]$SQLDBName
    )
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection;
    $SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True;";
    return $SqlConnection;
}

<# 
 .Description
  Invoke a script into the database and returns its results.

 .Parameter SqlConnection
  The connection to the database

 .Parameter SqlQuery
  The SqlQuery to be invoked

  .Parameter closeConnection
  Tells the module to close the connection after the execution.
#>
function Invoke-SqlScript {
    [OutputType([System.Data.DataSet])]
    param(
        [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)]
        [System.Data.SqlClient.SqlConnection]$SqlConnection,
        [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 1)]
        [string]$SqlQuery,
        [Parameter(Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 2)]
        [bool]$CloseConnection = $true
    )
    if ($SqlConnection.State -ne "Open") {
        $SqlConnection.Open();
    }
     
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand;
    $SqlCmd.CommandText = $SqlQuery;
    $SqlCmd.Connection = $SqlConnection;
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;
    $SqlAdapter.SelectCommand = $SqlCmd;
    $DataSet = New-Object System.Data.DataSet;
    $SqlAdapter.Fill($DataSet);

    if ($SqlConnection.State -ne "Closed" -and $CloseConnection) {
        $SqlConnection.Close();
    }
    return $DataSet;
}

Export-ModuleMember -Function New-*
Export-ModuleMember -Function Invoke-*