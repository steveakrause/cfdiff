<cfcomponent displayname="DiffTest" name="DiffTest" extends="net.sourceforge.cfunit.framework.TestCase">
	<!--- 
	DiffTest.cfc
	CFUnit Tests for diff.cfc - http://cfunit.sourceforge.net/
	Original Coding by Rick Osborne

	License: Mozilla Public License (MPL) version 1.1 - http://www.mozilla.org/MPL/
	READ THE LICENSE BEFORE YOU USE OR MODIFY THIS CODE
	--->

	<cfproperty name="tempCFC" type="diff">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfset VARIABLES.tempCFC=CreateObject("component","diff")>
	</cffunction>
	
	<cffunction name="testAddDifferenceInsert" returntype="void" access="public">
		<cfset var Q=QueryNew(VARIABLES.tempCFC.ResultColumnList())>
		<cfset VARIABLES.tempCFC.AddDifference(Q,VARIABLES.tempCFC.OPERATION_INSERT,1,2,3)>
		<cfset assertEquals("RecordCount doesn't match",1,Q.RecordCount)>
		<cfset assertEquals("Operation doesn't match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("Left position doesn't match",1,Q.AtFirst[1])>
		<cfset assertEquals("Right position doesn't match",2,Q.AtSecond[1])>
		<cfset assertEquals("Count doesn't match",3,Q.Count[1])>
	</cffunction>
 
	<cffunction name="testAddDifferenceDelete" returntype="void" access="public">
		<cfset var Q=QueryNew(VARIABLES.tempCFC.ResultColumnList())>
		<cfset VARIABLES.tempCFC.AddDifference(Q,VARIABLES.tempCFC.OPERATION_DELETE,4,3,2)>
		<cfset assertEquals("RecordCount doesn't match",1,Q.RecordCount)>
		<cfset assertEquals("Operation doesn't match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Left position doesn't match",4,Q.AtFirst[1])>
		<cfset assertEquals("Right position doesn't match",3,Q.AtSecond[1])>
		<cfset assertEquals("Count doesn't match",2,Q.Count[1])>
	</cffunction>
	<cffunction name="testAddDifferenceUpdateManual" returntype="void" access="public">
		<cfset var Q=QueryNew(VARIABLES.tempCFC.ResultColumnList())>
		<cfset VARIABLES.tempCFC.AddDifference(Q,VARIABLES.tempCFC.OPERATION_UPDATE,5,4,3)>
		<cfset assertEquals("RecordCount doesn't match",1,Q.RecordCount)>
		<cfset assertEquals("Operation doesn't match",VARIABLES.tempCFC.OPERATION_UPDATE,Q.Operation[1])>
		<cfset assertEquals("Left position doesn't match",5,Q.AtFirst[1])>
		<cfset assertEquals("Right position doesn't match",4,Q.AtSecond[1])>
		<cfset assertEquals("Count doesn't match",3,Q.Count[1])>
	</cffunction>
	<cffunction name="testAddDifferenceUpdateAutomagic" returntype="void" access="public">
		<cfset var Q=QueryNew(VARIABLES.tempCFC.ResultColumnList())>
		<cfset VARIABLES.tempCFC.AddDifference(Q,VARIABLES.tempCFC.OPERATION_DELETE,5,5,1)>
		<cfset assertEquals("Post-Delete RecordCount doesn't match",1,Q.RecordCount)>
		<cfset assertEquals("Post-Delete Operation doesn't match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Post-Delete Left position doesn't match",5,Q.AtFirst[1])>
		<cfset assertEquals("Post-Delete Right position doesn't match",5,Q.AtSecond[1])>
		<cfset assertEquals("Post-Delete Count doesn't match",1,Q.Count[1])>
		<cfset VARIABLES.tempCFC.AddDifference(Q,VARIABLES.tempCFC.OPERATION_INSERT,6,5,1)>
		<cfset assertEquals("Post-Insert RecordCount doesn't match",1,Q.RecordCount)>
		<cfset assertEquals("Post-Insert Operation doesn't match",VARIABLES.tempCFC.OPERATION_UPDATE,Q.Operation[1])>
		<cfset assertEquals("Post-Insert Left position doesn't match",5,Q.AtFirst[1])>
		<cfset assertEquals("Post-Insert Right position doesn't match",5,Q.AtSecond[1])>
		<cfset assertEquals("Post-Insert Count doesn't match",1,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysDeleteOneMiddle" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("1,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",2,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",2,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",1,Q.Count[1])>
	</cffunction>

	<cffunction name="testDiffArraysDeleteOneBeginning" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("2,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",1,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysDeleteOneEnd" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("1,2,3,4")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",5,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",5,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",1,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysDeleteThreeMiddle" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("1,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",2,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",2,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",3,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysDeleteThreeBeginning" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",3,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysDeleteBeginningEnd" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("2,3,4")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",2,Q.RecordCount)>
		<cfset assertEquals("First Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("First Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("First Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("First Count does not match",1,Q.Count[1])>
		<cfset assertEquals("Second Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[2])>
		<cfset assertEquals("Second Left index does not match",5,Q.AtFirst[2])>
		<cfset assertEquals("Second Right index does not match",4,Q.AtSecond[2])>
		<cfset assertEquals("Second Count does not match",1,Q.Count[2])>
	</cffunction>
	<cffunction name="testDiffArraysDeleteAll" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ArrayNew(1)>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_DELETE,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",5,Q.Count[1])>
	</cffunction>

	<cffunction name="testDiffArraysNoChange" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("1,2,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",0,Q.RecordCount)>
	</cffunction>
	<cffunction name="testDiffArraysInsertOneMiddle" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("1,2,6,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",3,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",3,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",1,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysInsertOneBeginning" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("6,1,2,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",1,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysInsertOneEnd" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("1,2,3,4,5,6")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",6,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",6,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",1,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysInsertThreeMiddle" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("1,2,6,7,8,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",3,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",3,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",3,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysInsertThreeBeginning" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("6,7,8,1,2,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",3,Q.Count[1])>
	</cffunction>
	<cffunction name="testDiffArraysInsertBeginningEnd" returntype="void" access="public">
		<cfset var L=ListToArray("1,2,3,4,5")>
		<cfset var R=ListToArray("6,1,2,3,4,5,7")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",2,Q.RecordCount)>
		<cfset assertEquals("First Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("First Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("First Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("First Count does not match",1,Q.Count[1])>
		<cfset assertEquals("Second Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[2])>
		<cfset assertEquals("Second Left index does not match",6,Q.AtFirst[2])>
		<cfset assertEquals("Second Right index does not match",7,Q.AtSecond[2])>
		<cfset assertEquals("Second Count does not match",1,Q.Count[2])>
	</cffunction>
	<cffunction name="testDiffArraysInsertAll" returntype="void" access="public">
		<cfset var L=ArrayNew(1)>
		<cfset var R=ListToArray("1,2,3,4,5")>
		<cfset var Q=VARIABLES.tempCFC.DiffArrays(L,R)>
		<cfset assertEquals("Recordcount does not match",1,Q.RecordCount)>
		<cfset assertEquals("Operation does not match",VARIABLES.tempCFC.OPERATION_INSERT,Q.Operation[1])>
		<cfset assertEquals("Left index does not match",1,Q.AtFirst[1])>
		<cfset assertEquals("Right index does not match",1,Q.AtSecond[1])>
		<cfset assertEquals("Count does not match",5,Q.Count[1])>
	</cffunction>

</cfcomponent>