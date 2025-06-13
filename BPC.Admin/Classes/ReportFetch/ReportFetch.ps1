# PowerShell Module: ReportFetch.psm1

<#
.SYNOPSIS
    ReportFetch module for constructing XML requests and handling responses.

.DESCRIPTION
    This module provides classes for building XML requests for report fetching, including
    join, where, and order-by clauses, and handles the response from a server.
#>

# Default Global Variables
$script:eEqualComp = 'eq'
$script:eLikeComp = 'like'
$script:eNotLikeComp = 'not like'
$script:eLTComp = 'lt'
$script:eLTEComp = 'lte'
$script:eGTComp = 'gt'
$script:eGTEComp = 'gte'
$script:eNotEqualComp = 'ne'
$script:eINComp = 'in'
$script:eNullComp = 'null'
$script:eNotNullComp = 'notnull'

# Export Global Variables
Export-ModuleMember -Variable eEqualComp, eLikeComp, eNotLikeComp, eLTComp, eLTEComp, eGTComp, eGTEComp, eNotEqualComp, eINComp, eNullComp, eNotNullComp

<#
.SYNOPSIS
    Class representing a join parameter.

.DESCRIPTION
    This class is used to define a join parameter for report fetching.

.PARAMETER bt20Name
    The BT20 object name.

.PARAMETER fromID
    The ID of the from object.

.PARAMETER toID
    The ID of the to object.
#>
class ReportFetchJoinParam {
    [string]$bt20Name
    [string]$fromID
    [string]$toID

    ReportFetchJoinParam([string]$bt20Name, [string]$fromID, [string]$toID) {
        $this.bt20Name = $bt20Name
        $this.fromID = $fromID
        $this.toID = $toID
    }

    [string]GetRequestXML() {
        return "<JoinProp BT20OBJ='$($this.bt20Name)' From='$($this.fromID)' To='$($this.toID)'/>"
    }
}

<#
.SYNOPSIS
    Class representing a join clause.

.DESCRIPTION
    This class is used to define a join clause for report fetching.
#>
class ReportFetchJoinClause {
    [System.Collections.Generic.List[ReportFetchJoinParam]]$joinParams

    ReportFetchJoinClause() {
        $this.joinParams = [System.Collections.Generic.List[ReportFetchJoinParam]]::new()
    }

    [void]AddJoin([string]$bt20Name, [string]$fromID, [string]$toID) {
        $param = [ReportFetchJoinParam]::new($bt20Name, $fromID, $toID)
        $this.joinParams.Add($param)
    }

    [string]GetRequestXML() {
        $out = ""
        if ($this.joinParams.Count -gt 0) {
            $out += "<Join>"
            foreach ($param in $this.joinParams) {
                $out += $param.GetRequestXML()
            }
            $out += "</Join>"
        }
        return $out
    }
}

<#
.SYNOPSIS
    Class representing a property.

.DESCRIPTION
    This class is used to define a property for report fetching.

.PARAMETER bt20Name
    The BT20 object name.

.PARAMETER propName
    The property name.

.PARAMETER alias
    The alias name (optional).
#>
class ReportFetchProperty {
    [string]$bt20Name
    [string]$propName
    [string]$alias

    ReportFetchProperty([string]$bt20Name, [string]$propName, [string]$alias = '') {
        $this.bt20Name = $bt20Name
        $this.propName = $propName
        $this.alias = $alias
    }

    [string]GetRequestXML() {
        $out = "<Detail BT20OBJ='$($this.bt20Name)' Prop='$($this.propName)'"
        if ($this.alias.Length -gt 0) { $out += " Name='$($this.alias)'" }
        $out += "/>"
        return $out
    }
}

<#
.SYNOPSIS
    Class representing a where parameter.

.DESCRIPTION
    This class is used to define a where parameter for report fetching.

.PARAMETER propName
    The property name.

.PARAMETER value
    The value to compare.

.PARAMETER comparison
    The comparison operator (optional).
#>
class ReportFetchWhereParam {
    [string]$propName
    [string]$value
    [string]$comparison

    ReportFetchWhereParam([string]$propName, [string]$value, [string]$comparison = '') {
        $this.propName = $propName
        $this.value = $value
        $this.comparison = $comparison
    }

    [string]GetRequestXML() {
        $out = "<WhereParam Prop='$($this.propName)' Value='$($this.value)'"
        if ($this.comparison.Length -gt 0) { $out += " Comparison='$($this.comparison)'" }
        $out += "/>"
        return $out
    }
}

<#
.SYNOPSIS
    Class representing a where clause.

.DESCRIPTION
    This class is used to define a where clause for report fetching.

.PARAMETER whereOp
    The where operator (optional).
#>
class ReportFetchWhereClause {
    [System.Collections.Generic.List[ReportFetchWhereParam]]$whereParams
    [string]$whereOp

    ReportFetchWhereClause([string]$whereOp = '') {
        $this.whereParams = [System.Collections.Generic.List[ReportFetchWhereParam]]::new()
        $this.whereOp = $whereOp
    }

    [void]AddParam([string]$propName, [string]$value, [string]$comparison = '') {
        $param = [ReportFetchWhereParam]::new($propName, $value, $comparison)
        $this.whereParams.Add($param)
    }

    [void]SetWhereOp([string]$whereOp) {
        $this.whereOp = $whereOp.ToLower()
    }

    [string]GetRequestXML() {
        $out = ""
        if ($this.whereParams.Count -gt 0) {
            $out += "<WhereClause"
            if ($this.whereOp.Length -gt 0) { $out += " WhereOp='$($this.whereOp)'" }
            $out += ">"
            foreach ($param in $this.whereParams) {
                $out += $param.GetRequestXML()
            }
            $out += "</WhereClause>"
        }
        return $out
    }
}

<#
.SYNOPSIS
    Class representing a where group.

.DESCRIPTION
    This class is used to define a group of where clauses for report fetching.

.PARAMETER whereOp
    The where operator (optional).
#>
class ReportFetchWhereGroup {
    [System.Collections.Generic.List[ReportFetchWhereClause]]$whereClauses
    [string]$whereOp

    ReportFetchWhereGroup([string]$whereOp = '') {
        $this.whereClauses = [System.Collections.Generic.List[ReportFetchWhereClause]]::new()
        $this.whereOp = $whereOp
    }

    [ReportFetchWhereClause]AddWhere([string]$whereOp) {
        $where = [ReportFetchWhereClause]::new($whereOp)
        $this.whereClauses.Add($where)
        return $where
    }

    [void]SetWhereOp([string]$whereOp) {
        $this.whereOp = $whereOp.ToLower()
    }

    [string]GetRequestXML() {
        $out = ""
        if ($this.whereClauses.Count -gt 0) {
            $out += "<WhereClauseGroup"
            if ($this.whereOp.Length -gt 0) { $out += " WhereOp='$($this.whereOp)'" }
            $out += ">"
            foreach ($clause in $this.whereClauses) {
                $out += $clause.GetRequestXML()
            }
            $out += "</WhereClauseGroup>"
        }
        return $out
    }
}

<#
.SYNOPSIS
    Class representing an order-by parameter.

.DESCRIPTION
    This class is used to define an order-by parameter for report fetching.

.PARAMETER propName
    The property name.

.PARAMETER dir
    The direction of sorting (optional).
#>
class ReportFetchOrderByParam {
    [string]$propName
    [string]$dir

    ReportFetchOrderByParam([string]$propName, [string]$dir = '') {
        $this.propName = $propName
        $this.dir = $dir
    }

    [string]GetRequestXML() {
        $out = "<DataProp Prop='$($this.propName)'"
        if ($this.dir.Length -gt 0) { $out += " Dir='$($this.dir)'" }
        $out += "/>"
        return $out
    }
}

<#
.SYNOPSIS
    Class representing an order-by clause.

.DESCRIPTION
    This class is used to define an order-by clause for report fetching.
#>
class ReportFetchOrderByClause {
    [System.Collections.Generic.List[ReportFetchOrderByParam]]$orderByParams

    ReportFetchOrderByClause() {
        $this.orderByParams = [System.Collections.Generic.List[ReportFetchOrderByParam]]::new()
    }

    [void]AddParam([string]$propName, [string]$dir = '') {
        $param = [ReportFetchOrderByParam]::new($propName, $dir)
        $this.orderByParams.Add($param)
    }

    [string]GetRequestXML() {
        $out = ""
        if ($this.orderByParams.Count -gt 0) {
            $out += "<DataProps>"
            foreach ($param in $this.orderByParams) {
                $out += $param.GetRequestXML()
            }
            $out += "</DataProps>"
        }
        return $out
    }
}

<#
.SYNOPSIS
    Class representing a data object.

.DESCRIPTION
    This class is used to define a data object for report fetching.

.PARAMETER progID
    The program ID.
#>
class ReportFetchDataObject {
    [System.Collections.Generic.List[ReportFetchWhereGroup]]$whereGroups
    [ReportFetchWhereClause]$whereClause
    [ReportFetchJoinClause]$joinClause
    [ReportFetchOrderByClause]$orderByClause
    [bool]$bUseDescription
    [string]$progID

    ReportFetchDataObject([string]$progID) {
        $this.progID = $progID
        $this.whereGroups = [System.Collections.Generic.List[ReportFetchWhereGroup]]::new()
        $this.whereClause = $null
        $this.joinClause = $null
        $this.orderByClause = $null
        $this.bUseDescription = $false
    }

    [ReportFetchWhereGroup]AddWhereGroup([string]$whereOp = '') {
        $whereGroup = [ReportFetchWhereGroup]::new($whereOp)
        $this.whereGroups.Add($whereGroup)
        return $whereGroup
    }

    [ReportFetchWhereClause]GetWhereClause() {
        if ($null -eq $this.whereClause) {
            $this.whereClause = [ReportFetchWhereClause]::new()
        }
        return $this.whereClause
    }

    [ReportFetchJoinClause]GetJoinClause() {
        if ($null -eq $this.joinClause) {
            $this.joinClause = [ReportFetchJoinClause]::new()
        }
        return $this.joinClause
    }

    [ReportFetchOrderByClause]GetOrderByClause() {
        if ($null -eq $this.orderByClause) {
            $this.orderByClause = [ReportFetchOrderByClause]::new()
        }
        return $this.orderByClause
    }

    [string]GetRequestXML() {
        $out = "<DataObject ProgID='$($this.progID)'"
        if ($this.bUseDescription) { $out += " UseDescription='1'" }
        $out += ">"

        foreach ($whereGroup in $this.whereGroups) {
            $out += $whereGroup.GetRequestXML()
        }

        if ($null -ne $this.whereClause) { $out += $this.whereClause.GetRequestXML() }
        if ($null -ne $this.joinClause) { $out += $this.joinClause.GetRequestXML() }
        if ($null -ne $this.orderByClause) { $out += $this.orderByClause.GetRequestXML() }

        $out += "</DataObject>"
        return $out
    }

    [void]SetUseDescription([bool]$bUseDescription) {
        $this.bUseDescription = $bUseDescription
    }
}

<#
.SYNOPSIS
    Class representing the main ReportFetch.

.DESCRIPTION
    This class handles the main operations for report fetching, including creating request XML,
    sending requests, and processing responses.

.PARAMETER sUserID
    The user ID.

.PARAMETER sConnect
    The connection string.
#>
class ReportFetch {
    [string]$sUserID
    [string]$sConnect
    [System.Collections.Generic.List[ReportFetchDataObject]]$dataObjects
    [System.Collections.Generic.List[ReportFetchProperty]]$properties
    [int]$nStatus
    [string]$sStatusText
    [PSCustomObject]$oServerHTTP
    [bool]$bDistinct
    [string]$sRelativePath
    [bool]$bApplySecurity

    ReportFetch([string]$sUserID, [string]$sConnect) {
        $this.sUserID = $sUserID
        $this.sConnect = $sConnect
        $this.dataObjects = [System.Collections.Generic.List[ReportFetchDataObject]]::new()
        $this.properties = [System.Collections.Generic.List[ReportFetchProperty]]::new()
        $this.nStatus = 0
        $this.sStatusText = "Uninitialized"
        $this.bDistinct = $false
        $this.sRelativePath = ""
        $this.bApplySecurity = $false
        $this.oServerHTTP = [PSCustomObject]@{
            headers        = $null
            status         = ""
            statusText     = ""
            type           = ""
            url            = ""
            ResponseXMLDoc = $null
        }
    }

    [string]GetStatusText() {
        if ($null -ne $this.oServerHTTP) {
            if ($this.oServerHTTP.statusText.Length -gt 0) {
                return $this.oServerHTTP.statusText
            }
            return $this.oServerHTTP.statusText
        }
        return $this.sStatusText
    }

    [ReportFetchDataObject]AddDataObject([string]$progID) {
        $dataObject = [ReportFetchDataObject]::new($progID)
        $this.dataObjects.Add($dataObject)
        return $dataObject
    }

    [void]AddProperty([string]$bt20Name, [string]$propName, [string]$alias = '') {
        $prop = [ReportFetchProperty]::new($bt20Name, $propName, $alias)
        $this.properties.Add($prop)
    }

    [int]GetStatus() {
        if ($this.nStatus -ne 0) {
            return $this.nStatus
        }

        if ($this.oServerHTTP.status.Length -gt 0) {
            return [int]$this.oServerHTTP.status
        }

        return 400
    }

    [xml]GetResponseXML() {
        return $this.oServerHTTP.ResponseXMLDoc
    }

    [xml]GetRequestXMLDocument([bool]$bRequestDetailsOnly = $false) {
        $sRequestXML = ""

        if (-not $bRequestDetailsOnly) {
            $headerXML = "<Header><UserID>$($this.sUserID)</UserID><Connection>$($this.sConnect)</Connection></Header>"
            $sRequestXML += "<?xml version='1.0' encoding='UTF-8' ?><sbixml><NetSightMessage>$headerXML"
        }

        $sRequestXML += "<Request Type='ReportFetch'>"
        $sRequestXML += "<ReportFetch"

        if ($this.bDistinct) { $sRequestXML += " Distinct='1'" }
        if ($this.bApplySecurity) { $sRequestXML += " ApplySecurity='1'" }

        $sRequestXML += ">"

        foreach ($dataObject in $this.dataObjects) {
            $sRequestXML += $dataObject.GetRequestXML()
        }

        if ($this.properties.Count -gt 0) {
            $sRequestXML += "<ReportFormat>"
            foreach ($prop in $this.properties) {
                $sRequestXML += $prop.GetRequestXML()
            }
            $sRequestXML += "</ReportFormat>"
        }

        $sRequestXML += "</ReportFetch>"
        $sRequestXML += "</Request>"

        if (-not $bRequestDetailsOnly) {
            $sRequestXML += "</NetSightMessage></sbixml>"
        }

        $oSendDoc = [xml](New-Object System.Xml.XmlDocument).LoadXml($sRequestXML)
        if ($oSendDoc.getElementsByTagName("parsererror").Count -gt 0) {
            $this.nStatus = 500
            $this.sStatusText = $oSendDoc.getElementsByTagName("parsererror")[0].innerText
            return $oSendDoc
        }

        return $oSendDoc
    }

    [void]GetRecords() {
        $oRequestXML = $this.GetRequestXMLDocument()
        if ($null -eq $oRequestXML) { return }

        $oResponseXML = Invoke-RestMethod -Uri (Get-BrokerURL) -Method 'POST' -Headers @{
            'accept'        = 'application/xml, text/xml, */*;'
            'cache-control' = 'no-cache'
            'content-type'  = 'application/x-www-form-urlencoded; charset=UTF-8'
            'pragma'        = 'no-cache'
        } -Body ($oRequestXML.OuterXml) -ContentType 'application/xml'

        $this.oServerHTTP.ResponseXMLDoc = $oResponseXML
        $this.oServerHTTP.status = $oResponseXML.StatusCode.ToString()
        $this.oServerHTTP.headers = $oResponseXML.Headers
        $this.oServerHTTP.statusText = $oResponseXML.StatusDescription
        $this.oServerHTTP.url = $oResponseXML.ResponseUri.ToString()
        $this.oServerHTTP.type = $oResponseXML.ResponseType
    }

    [string]GetRecordsAsyc([scriptblock]$fnCallback, [pscustomobject]$sData) {
        return "$($this.sStatusText)`r`nThis function is not enabled`r`n$($fnCallback)`r`n$($sData.PSObject.Properties.Name -join "`r`n")"
    }

    [void]SetDistinct([bool]$bDistinct) {
        $this.bDistinct = $bDistinct
    }

    [void]SetRelativePath([string]$sRelativePath) {
        $this.sRelativePath = $sRelativePath
    }

    [void]SetApplySecurity([bool]$bApplySecurity) {
        $this.bApplySecurity = $bApplySecurity
    }
}

# Export Classes
Export-ModuleMember -Function ReportFetchJoinParam, ReportFetchJoinClause, ReportFetchProperty, ReportFetchWhereParam, ReportFetchWhereClause, ReportFetchWhereGroup, ReportFetchOrderByParam, ReportFetchOrderByClause, ReportFetchDataObject, ReportFetch
