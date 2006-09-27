<cfsetting showdebugoutput="false">

<cfinvoke component="net.sourceforge.cfunit.framework.TestSuite" method="init" classes="cfdiff.difftest" returnvariable="testSuite" />

<cfinvoke component="net.sourceforge.cfunit.framework.TestRunner" method="run">
	<cfinvokeargument name="test" value="#testSuite#">
	<cfinvokeargument name="name" value="">
</cfinvoke>

<!---
<cfset Path="c:/www/root/cfdiff">
<cfset L="">
<cfset R="">
<cfset Q="">
<cfset P="">
<cfset OC=CreateObject("component","cfdiff.diff-old")>
<cfset NC=CreateObject("component","cfdiff.diff")>
<cffile action="read" file="#Path#/diff-old.cfc" variable="L">
<cffile action="read" file="#Path#/diff.cfc" variable="R">
<cfset L=ListToArray(L,Chr(10))>
<cfset R=ListToArray(R,Chr(10))>
<cfset Times=QueryNew("Lines_Old,Lines_New,Old_n_Busted,New_Hawtness,x_Factor")>
<cfloop from="1" to="5" index="i">
	<cfset StartTime=GetTickCount()>
	<cfset Q=OC.DiffArrays(L,R)>
	<cfset t1=GetTickCount()-StartTime>
	<cfset StartTime=GetTickCount()>
	<cfset Q=NC.DiffArrays(L,R)>
	<cfset t2=GetTickCount()-StartTime>
	<cfset QueryAddRow(Times)>
	<cfset Times.Old_n_Busted[i]=NumberFormat(t1)&"ms">
	<cfset Times.New_Hawtness[i]=NumberFormat(t2)&"ms">
	<cfset Times.x_Factor[i]=Round(t1/t2)&"x">
	<cfset Times.Lines_Old[i]=ArrayLen(L)>
	<cfset Times.Lines_New[i]=ArrayLen(R)>
</cfloop>
<cfdump var="#Times#" label="Diff Times">
<cfset P=NC.Parallelize(Q,L,R)>
<cfset OpClasses=StructNew()>
<cfset OpClasses["+"]="ins">
<cfset OpClasses["-"]="del">
<cfset OpClasses["!"]="upd">
<cfset OpClasses[""]="">
<cfoutput>
<br clear="all" />
<style type="text/css">
table.diff { width: 100%; }
.diff tr, table.diff { margin: 0px; padding: 0px; }
.diff td { margin: 0px; padding: 3px; border-collapse: collapse; font-family:  'Bitstream Vera Sans Mono', 'Bitstream Vera Mono', 'Lucida Console', 'Lucida Typewriter', 'Courier New', monspace, fixed, fixed-width; font-size: 12px; vertical-align: top; }
.diff td.linenum { background-color: ##e0e0e0; color: ##666666; border-right: 1px solid ##d0d0d0; border-left: 1px solid ##c0c0c0; text-align: right; }
.diff .code div { line-height: 1.2em; height: 1.2em; overflow: hidden; }
.diff tr:hover .code div { height: auto; overflow: auto; }
.diff .ins { background-color: ##afa; }
.diff .del { background-color: ##faa; }
.diff .upd { background-color: ##aaf; }
</style>
<table class="diff" cellspacing="0">
<cfloop query="P">
	<tr>
		<td class="linenum"><cfif IsNumeric(AtFirst)>#NumberFormat(AtFirst)#<cfelse>&nbsp;</cfif></td>
		<td class="code<cfif Operation NEQ '+'> #OpClasses[Operation]#</cfif>"><div>#Replace(HTMLEditFormat(ValueFirst),Chr(9),"&nbsp;&nbsp;&nbsp;","ALL")#</div></td>
		<td class="linenum"><cfif IsNumeric(AtSecond)>#NumberFormat(AtSecond)#<cfelse>&nbsp;</cfif></td>
		<td class="code<cfif Operation NEQ '-'> #OpClasses[Operation]#</cfif>"><div>#Replace(HTMLEditFormat(ValueSecond),Chr(9),"&nbsp;&nbsp;&nbsp;","ALL")#</div></td>
	</tr>
</cfloop>
</table>
</cfoutput>
--->