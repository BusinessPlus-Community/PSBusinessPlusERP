# PowerShell Unit Tests: ReportFetch.Tests.ps1

BeforeAll {
    # Import the classes directly for testing
    $classPath = Join-Path $PSScriptRoot "..\BPC.Admin\Classes\ReportFetch\ReportFetch.ps1"
    if (Test-Path $classPath) {
        . $classPath
    } else {
        # If running from Output directory, try to load the built module
        $modulePath = Get-ChildItem "$PSScriptRoot\..\Output\BPC.Admin\*\BPC.Admin.psd1" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($modulePath) {
            Import-Module $modulePath.FullName -Force
        }
    }
}

Describe 'ReportFetchJoinParam' {
    It 'Should create an instance with correct properties' {
        $param = [ReportFetchJoinParam]::new('TestBT20', 'TestFromID', 'TestToID')
        $param.bt20Name | Should -Be 'TestBT20'
        $param.fromID | Should -Be 'TestFromID'
        $param.toID | Should -Be 'TestToID'
    }

    It 'Should generate correct XML' {
        $param = [ReportFetchJoinParam]::new('TestBT20', 'TestFromID', 'TestToID')
        $param.GetRequestXML() | Should -Be "<JoinProp BT20OBJ='TestBT20' From='TestFromID' To='TestToID'/>"
    }

    It 'Should handle empty properties correctly' {
        $param = [ReportFetchJoinParam]::new('', '', '')
        $param.GetRequestXML() | Should -Be "<JoinProp BT20OBJ='' From='' To=''/>"
    }
}

Describe 'ReportFetchJoinClause' {
    It 'Should create an instance with an empty joinParams list' {
        $clause = [ReportFetchJoinClause]::new()
        $clause.joinParams.Count | Should -Be 0
    }

    It 'Should add join parameters correctly' {
        $clause = [ReportFetchJoinClause]::new()
        $clause.AddJoin('TestBT20', 'TestFromID', 'TestToID')
        $clause.joinParams.Count | Should -Be 1
        $clause.joinParams[0].bt20Name | Should -Be 'TestBT20'
    }

    It 'Should generate correct XML' {
        $clause = [ReportFetchJoinClause]::new()
        $clause.AddJoin('TestBT20', 'TestFromID', 'TestToID')
        $clause.GetRequestXML() | Should -Be "<Join><JoinProp BT20OBJ='TestBT20' From='TestFromID' To='TestToID'/></Join>"
    }

    It 'Should handle no join parameters correctly' {
        $clause = [ReportFetchJoinClause]::new()
        $clause.GetRequestXML() | Should -Be ""
    }
}

Describe 'ReportFetchProperty' {
    It 'Should create an instance with correct properties' {
        $property = [ReportFetchProperty]::new('TestBT20', 'TestProp', 'TestAlias')
        $property.bt20Name | Should -Be 'TestBT20'
        $property.propName | Should -Be 'TestProp'
        $property.alias | Should -Be 'TestAlias'
    }

    It 'Should generate correct XML with alias' {
        $property = [ReportFetchProperty]::new('TestBT20', 'TestProp', 'TestAlias')
        $property.GetRequestXML() | Should -Be "<Detail BT20OBJ='TestBT20' Prop='TestProp' Name='TestAlias'/>"
    }

    It 'Should generate correct XML without alias' {
        $property = [ReportFetchProperty]::new('TestBT20', 'TestProp', '')
        $property.GetRequestXML() | Should -Be "<Detail BT20OBJ='TestBT20' Prop='TestProp'/>"
    }

    It 'Should handle empty properties correctly' {
        $property = [ReportFetchProperty]::new('', '', '')
        $property.GetRequestXML() | Should -Be "<Detail BT20OBJ='' Prop=''/>"
    }
}

Describe 'ReportFetchWhereParam' {
    It 'Should create an instance with correct properties' {
        $param = [ReportFetchWhereParam]::new('TestProp', 'TestValue', 'TestComp')
        $param.propName | Should -Be 'TestProp'
        $param.value | Should -Be 'TestValue'
        $param.comparison | Should -Be 'TestComp'
    }

    It 'Should generate correct XML with comparison' {
        $param = [ReportFetchWhereParam]::new('TestProp', 'TestValue', 'TestComp')
        $param.GetRequestXML() | Should -Be "<WhereParam Prop='TestProp' Value='TestValue' Comparison='TestComp'/>"
    }

    It 'Should generate correct XML without comparison' {
        $param = [ReportFetchWhereParam]::new('TestProp', 'TestValue', '')
        $param.GetRequestXML() | Should -Be "<WhereParam Prop='TestProp' Value='TestValue'/>"
    }

    It 'Should handle empty properties correctly' {
        $param = [ReportFetchWhereParam]::new('', '', '')
        $param.GetRequestXML() | Should -Be "<WhereParam Prop='' Value=''/>"
    }
}

Describe 'ReportFetchWhereClause' {
    It 'Should create an instance with an empty whereParams list' {
        $clause = [ReportFetchWhereClause]::new('')
        $clause.whereParams.Count | Should -Be 0
    }

    It 'Should add where parameters correctly' {
        $clause = [ReportFetchWhereClause]::new('')
        $clause.AddParam('TestProp', 'TestValue', 'TestComp')
        $clause.whereParams.Count | Should -Be 1
        $clause.whereParams[0].propName | Should -Be 'TestProp'
    }

    It 'Should generate correct XML with parameters' {
        $clause = [ReportFetchWhereClause]::new('')
        $clause.AddParam('TestProp', 'TestValue', 'TestComp')
        $clause.GetRequestXML() | Should -Be "<WhereClause><WhereParam Prop='TestProp' Value='TestValue' Comparison='TestComp'/></WhereClause>"
    }

    It 'Should handle no where parameters correctly' {
        $clause = [ReportFetchWhereClause]::new('')
        $clause.GetRequestXML() | Should -Be ""
    }
}

Describe 'ReportFetchWhereGroup' {
    It 'Should create an instance with an empty whereClauses list' {
        $group = [ReportFetchWhereGroup]::new('')
        $group.whereClauses.Count | Should -Be 0
    }

    It 'Should add where clauses correctly' {
        $group = [ReportFetchWhereGroup]::new('')
        $group.AddWhere('TestWhereOp')
        $group.whereClauses.Count | Should -Be 1
        $group.whereClauses[0].whereOp | Should -Be 'TestWhereOp'
    }

    It 'Should generate correct XML with where clauses' {
        $group = [ReportFetchWhereGroup]::new('testwhereop')
        $clause = $group.AddWhere('TestWhereOp')
        $clause.AddParam('TestProp', 'TestValue', 'eq')
        $group.GetRequestXML() | Should -Be "<WhereClauseGroup WhereOp='testwhereop'><WhereClause WhereOp='testwhereop'><WhereParam Prop='TestProp' Value='TestValue' Comparison='eq'/></WhereClause></WhereClauseGroup>"
    }

    It 'Should handle no where clauses correctly' {
        $group = [ReportFetchWhereGroup]::new('')
        $group.GetRequestXML() | Should -Be ""
    }
}

Describe 'ReportFetchOrderByParam' {
    It 'Should create an instance with correct properties' {
        $param = [ReportFetchOrderByParam]::new('TestProp', 'TestDir')
        $param.propName | Should -Be 'TestProp'
        $param.dir | Should -Be 'TestDir'
    }

    It 'Should generate correct XML with direction' {
        $param = [ReportFetchOrderByParam]::new('TestProp', 'TestDir')
        $param.GetRequestXML() | Should -Be "<DataProp Prop='TestProp' Dir='TestDir'/>"
    }

    It 'Should generate correct XML without direction' {
        $param = [ReportFetchOrderByParam]::new('TestProp', '')
        $param.GetRequestXML() | Should -Be "<DataProp Prop='TestProp' Dir=''/>"
    }

    It 'Should handle empty properties correctly' {
        $param = [ReportFetchOrderByParam]::new('', '')
        $param.GetRequestXML() | Should -Be "<DataProp Prop='' Dir=''/>"
    }
}

Describe 'ReportFetchOrderByClause' {
    It 'Should create an instance with an empty orderByParams list' {
        $clause = [ReportFetchOrderByClause]::new()
        $clause.orderByParams.Count | Should -Be 0
    }

    It 'Should add order-by parameters correctly' {
        $clause = [ReportFetchOrderByClause]::new()
        $clause.AddParam('TestProp', 'TestDir')
        $clause.orderByParams.Count | Should -Be 1
        $clause.orderByParams[0].propName | Should -Be 'TestProp'
    }

    It 'Should generate correct XML with parameters' {
        $clause = [ReportFetchOrderByClause]::new()
        $clause.AddParam('TestProp', 'TestDir')
        $clause.GetRequestXML() | Should -Be "<DataProps><DataProp Prop='TestProp' Dir='TestDir'/></DataProps>"
    }

    It 'Should handle no order-by parameters correctly' {
        $clause = [ReportFetchOrderByClause]::new()
        $clause.GetRequestXML() | Should -Be ""
    }
}

Describe 'ReportFetchDataObject' {
    It 'Should create an instance with correct properties' {
        $dataObject = [ReportFetchDataObject]::new('TestProgID')
        $dataObject.progID | Should -Be 'TestProgID'
    }

    It 'Should add where groups correctly' {
        $dataObject = [ReportFetchDataObject]::new('TestProgID')
        $dataObject.AddWhereGroup('TestWhereOp')
        $dataObject.whereGroups.Count | Should -Be 1
    }

    It 'Should generate correct XML with description' {
        $dataObject = [ReportFetchDataObject]::new('TestProgID')
        $dataObject.SetUseDescription($true)
        $dataObject.GetRequestXML() | Should -Be "<DataObject ProgID='TestProgID' UseDescription='1'></DataObject>"
    }

    It 'Should generate correct XML without description' {
        $dataObject = [ReportFetchDataObject]::new('TestProgID')
        $dataObject.SetUseDescription($false)
        $dataObject.GetRequestXML() | Should -Be "<DataObject ProgID='TestProgID'></DataObject>"
    }

    It 'Should handle no where groups correctly' {
        $dataObject = [ReportFetchDataObject]::new('TestProgID')
        $dataObject.GetRequestXML() | Should -Be "<DataObject ProgID='TestProgID'></DataObject>"
    }
}

Describe 'ReportFetch' {
    It 'Should create an instance with correct properties' {
        $reportFetch = [ReportFetch]::new('TestUserID', 'TestConnect')
        $reportFetch.sUserID | Should -Be 'TestUserID'
        $reportFetch.sConnect | Should -Be 'TestConnect'
    }

    It 'Should add data objects correctly' {
        $reportFetch = [ReportFetch]::new('TestUserID', 'TestConnect')
        $reportFetch.AddDataObject('TestProgID')
        $reportFetch.dataObjects.Count | Should -Be 1
    }

    It 'Should generate correct request XML document' {
        $reportFetch = [ReportFetch]::new('TestUserID', 'TestConnect')
        $xmlDoc = $reportFetch.GetRequestXMLDocument($false)
        $xmlDoc.OuterXml | Should -Match "<Header><UserID>TestUserID</UserID><Connection>TestConnect</Connection></Header>"
    }

    It 'Should handle no data objects correctly' {
        $reportFetch = [ReportFetch]::new('TestUserID', 'TestConnect')
        $xmlDoc = $reportFetch.GetRequestXMLDocument($false)
        $xmlDoc.OuterXml | Should -Match "<ReportFetch></ReportFetch>"
    }

    It 'Should handle distinct flag correctly' {
        $reportFetch = [ReportFetch]::new('TestUserID', 'TestConnect')
        $reportFetch.SetDistinct($true)
        $xmlDoc = $reportFetch.GetRequestXMLDocument($false)
        $xmlDoc.OuterXml | Should -Match '<ReportFetch Distinct="1">'
    }

    It 'Should handle apply security flag correctly' {
        $reportFetch = [ReportFetch]::new('TestUserID', 'TestConnect')
        $reportFetch.SetApplySecurity($true)
        $xmlDoc = $reportFetch.GetRequestXMLDocument($false)
        $xmlDoc.OuterXml | Should -Match '<ReportFetch ApplySecurity="1">'
    }
}
