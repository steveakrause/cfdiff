<cfsetting enablecfoutputonly="Yes">
<!---
	svn browser
	Original Code by Rick Osborne

	License: Mozilla Public License (MPL) version 1.1 - http://www.mozilla.org/MPL/
	READ THE LICENSE BEFORE YOU USE OR MODIFY THIS CODE
	
	Yes, yes, I know.  Horrific caffeine code.  I bow down.  I'm so ashamed.
--->

<!---
===============================================================
  BEGIN SITE-SPECIFIC SETTINGS
===============================================================
--->

<cfset RepositoryURL="http://cfdiff.googlecode.com/svn/trunk/">
<!--- Most of the time, you won't need a username/password for read-only access --->
<cfset RepositoryUsername="">
<cfset RepositoryPassword="">
<cfset PageTitle="cfdiff Subversion Browser">
<cfset StyleSheet="cfdiff.css">
<cfset DiffGraphic='<img src="diff.png" width="16" width="16" alt="View the difference between this file and the previous version" border="0" />'>
<!--- We don't want to provide the ability to diff everything, just certain file types --->
<cfset Diffable="cfc,cfm,cfml,txt,plx,php,php4,php5,asp,aspx,xml,html,htm,sql,css,js">

<!---
===============================================================
  END SITE-SPECIFIC SETTINGS
===============================================================
--->
<!--- You *probably* won't have to edit anything below this line --->

<cflock scope="APPLICATION" type="EXCLUSIVE" timeout="30">
	<cfif NOT StructKeyExists(Application,"SVNBrowser")>
		<cfset Application.SVNBrowser=CreateObject("component","svnbrowser").init(RepositoryURL,RepositoryUsername,RepositoryPassword)>
	</cfif>
	<cfset sb=Application.SVNBrowser>
</cflock>
<cfset Version="">
<cfset PrevVersion="">
<cfset FullDiff=false>
<!--- Request URLs will look like: /svn.cfm/org/rickosborne/diff.cfc:12:25 --->
<cfset FilePath=REReplace(REReplace(CGI.PATH_INFO,"[.][.]+",".","ALL"),"[/][/]+","/","ALL")>
<cfif FilePath CONTAINS ":">
	<!--- There is at least one revision number given --->
	<cfset Version=ListRest(FilePath,":")>
	<cfif Version CONTAINS ":">
		<!--- There's a left/right pair of revision numbers --->
		<cfset PrevVersion=ListFirst(Version,":")>
		<cfset Version=ListRest(Version,":")>
		<cfif Right(Version,1) EQ "f">
			<cfset FullDiff=true>
			<cfset Version=Val(Version)>
		</cfif>
	</cfif>
	<cfset FilePath=ListFirst(FilePath,":")>
</cfif>
<cfset IsDir=False>
<cfif FilePath EQ "">
	<cfset FilePath="/">
</cfif>
<cfif Right(FilePath,1) EQ "/">
	<cfset IsDir=True>
</cfif>
<cfset TotalBytes=0>
<cfset TotalFiles=0>
<cfset TotalDirs=0>
<cfset EvenOdd=ListToArray("even,odd")>
<cfset IsDiff=false>
<cfif IsDir>
	<!--- Get a directory listing --->
	<cfset f=sb.List(FilePath)>
<cfelseif IsNumeric(PrevVersion) AND IsNumeric(Version)>
	<!--- If we have two revision numbers, make a diff --->
	<cfset LeftQ=sb.FileVersion(FilePath,PrevVersion)>
	<cfset RightQ=sb.FileVersion(FilePath,Version)>
	<cfset Differ=CreateObject("component","diff")>
	<cfif IsQuery(LeftQ) AND IsQuery(RightQ) AND (LeftQ.RecordCount EQ 1) AND (RightQ.RecordCount EQ 1) AND IsBinary(LeftQ.Content[1]) AND IsBinary(RightQ.Content[1])>
		<!--- We got two files, build a diff --->
		<cfset LeftFile=ListToArray(ToString(LeftQ.Content[1]),Chr(10))>
		<cfset RightFile=ListToArray(ToString(RightQ.Content[1]),Chr(10))>
		<cfif FullDiff>
			<cfset f=Differ.Parallelize(Differ.DiffArrays(LeftFile,RightFile),LeftFile,RightFile)>
		<cfelse>
			<cfset f=Differ.UnifiedDiffArrays(Differ.DiffArrays(LeftFile,RightFile),LeftFile,RightFile)>
		</cfif>
	<cfelse>
		<!--- Yeah, we should probably show an error message or something --->
		<cfset LeftFile="">
		<cfset RightFile="">
		<cfset f=QueryNew(Differ.ResultColumnList)>
	</cfif>
	<cfset IsDiff=true>
<cfelseif IsNumeric(Version)>
	<!--- We only have one version number, so show the file --->
	<cfset f=sb.FileVersion(FilePath,Version)>
	<cfif f.RecordCount GT 0>
		<!--- Arcane mojo to return a byte array.  Hella lame. --->
		<cfset PageContext=getPageContext()>
		<cfset PageContext.setFlushOutput(false)>
		<cfset Response=PageContext.getResponse().getResponse()>
		<cfset OutStream=Response.getOutputStream()>
		<cfset MimeType=PageContext.getServletContext().getMimeType(f.Name)>
		<cfif NOT IsDefined("MimeType")>
			<cfset FileExt=LCase(ListLast(f.Name,"."))>
			<cfswitch expression="#FileExt#">
				<cfcase value="cfc,cfm,cfml,js,pl,plx,php,php4,php5,asp,aspx,sql"><cfset MimeType="text/plain"></cfcase>
				<cfcase value="jpg,jpeg,png,gif,ico"><cfset MimeType="image/"&FileExt></cfcase>
				<cfcase value="xml,html,htm"><cfset MimeType="text/"&FileExt></cfcase>
				<cfdefaultcase><cfset MimeType="application/octet-stream"></cfdefaultcase>
			</cfswitch>
		</cfif>
		<cfset Response.setContentType(MimeType)>
		<cfset Response.setContentLength(ArrayLen(f.Content[1]))>
		<cfset OutStream.write(f.Content[1])>
		<cfset OutStream.flush()>
		<cfset Response.reset()>
		<cfset OutStream.close()>
		<cfabort>
	<cfelse>
		<cfabort showerror="No such file or revision">
	</cfif>
	<cfabort>
<cfelse>
	<!--- If all else fails, try to show a history of whatever we're looking at --->
	<cfset f=sb.History(FilePath)>
</cfif>

<cfoutput>
<html>
<head>
<title>#PageTitle#</title>
<base href="http<cfif CGI.SERVER_PORT EQ 443>s</cfif>://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#" />
<cfif StyleSheet NEQ ""><link rel="stylesheet" href="#StyleSheet#" type="text/css" /></cfif>
</head>
<body>
<h1>#PageTitle#</h1>
<h2>Path: #HTMLEditFormat(FilePath)#</h2>
</cfoutput>

<cffunction name="FreshnessRating" returntype="string" output="false">
	<cfargument name="Updated" type="any" required="true">
	<cfset var Age=99>
	<cfif IsDate(Arguments.Updated)>
		<cfset Age=DateDiff("d",Arguments.Updated,Now())>
	</cfif>
	<cfif Age LTE 2><cfreturn "smokin">
	<cfelseif Age LTE 5><cfreturn "hot">
	<cfelseif Age LTE 10><cfreturn "fresh">
	<cfelseif Age LTE 30><cfreturn "fine">
	</cfif>
	<cfreturn "aged">
</cffunction>

<cfif IsDiff>
	<!--- Keep track of line counts, and provide a quick translation for operations to class names --->
	<cfset OpClasses=StructNew()>
	<cfset OpClasses["+"]="ins">
	<cfset OpClasses["-"]="del">
	<cfset OpClasses["!"]="upd">
	<cfset OpClasses[""]="">
	<cfset OpCounts=StructNew()>
	<cfset OpCounts["+"]=0>
	<cfset OpCounts["-"]=0>
	<cfset OpCounts["!"]=0>
	<cfset OpCounts[""]=0>
	<cfset Edge="">
	<cfoutput>
	<p>You may also view the <cfif FullDiff><a href="#CGI.SCRIPT_NAME##Left(CGI.PATH_INFO,Len(CGI.PATH_INFO)-1)#">unified diff</a><cfelse><a href="#CGI.SCRIPT_NAME##CGI.PATH_INFO#f">full diff</a></cfif>.</p>
	<table class="diff" cellspacing="0">
		<tr>
			<th class="linenum" style="border-right:none;border-bottom:none;">&nbsp;</th>
			<th nowrap="nowrap" style="border-left:none;">Revision #NumberFormat(PrevVersion)#</th>
			<th class="linenum" style="border-right:none;border-bottom:none;">&nbsp;</th>
			<th nowrap="nowrap" style="border-left:none;">Revision #NumberFormat(Version)#</th>
		</tr>
	<cfloop query="f">
		<cfset OpCounts[Operation]=OpCounts[Operation]+1>
		<tr class="#Edge#">
			<td class="linenum"><cfif IsNumeric(AtFirst)>#NumberFormat(AtFirst)#<cfelse>&nbsp;</cfif></td>
			<td class="code<cfif Operation NEQ '+'> #OpClasses[Operation]#</cfif>"><div><cfif Len(ValueFirst) GT 0>#Replace(HTMLEditFormat(ValueFirst),Chr(9),"&nbsp;&nbsp;&nbsp;","ALL")#<cfelse>&nbsp;</cfif></div></td>
			<td class="linenum"><cfif IsNumeric(AtSecond)>#NumberFormat(AtSecond)#<cfelse>&nbsp;</cfif></td>
			<td class="code<cfif Operation NEQ '-'> #OpClasses[Operation]#</cfif>"><div><cfif Len(ValueSecond) GT 0>#Replace(HTMLEditFormat(ValueSecond),Chr(9),"&nbsp;&nbsp;&nbsp;","ALL")#<cfelse>&nbsp;</cfif></div></td>
		</tr>
	</cfloop>
	</table>
	<br />
	<h3>Statistics</h3>
	<table class="diff" style="width: auto;">
		<tr><td class="linenum">#NumberFormat(OpCounts[""])#</td><td>Unchanged</td></tr>
		<tr><td class="linenum">#NumberFormat(OpCounts["+"])#</td><td class="ins">Added</td></tr>
		<tr><td class="linenum">#NumberFormat(OpCounts["!"])#</td><td class="upd">Updated</td></tr>
		<tr><td class="linenum">#NumberFormat(OpCounts["-"])#</td><td class="del">Removed</td></tr>
	</table>
	</cfoutput>
<cfelse>
	<!--- Show our generic file list or history list --->
	<cfoutput>
<table border="0" width="100%" class="list">
	<thead>
	<tr>
	<cfif IsDir><th align="left">Name</th></cfif>
	<th align="right">Revision</th>
	<cfif NOT IsDir><th align="center">Diff</th></cfif>
	<cfif IsDir><th align="right">Size</th></cfif>
	<th align="center">Date</th>
	<th align="left">Author</th>
	<cfif NOT IsDir><th align="left">Message</th></cfif>
	</tr>
	</thead>
	<tbody>
</cfoutput>
<cfoutput query="f">
	<cfif IsNumeric(Size)><cfset TotalBytes=TotalBytes+Size></cfif>
	<cfset FileExt=LCase(ListLast(Name,"."))>
	<cfset CanDiff=false>
	<cfif Kind EQ "file"><cfset TotalFiles=TotalFiles+1><cfif ListFindNoCase(Diffable,FileExt) GT 0><cfset CanDiff=true></cfif><cfelseif Kind EQ "dir"><cfset TotalDirs=TotalDirs+1></cfif>
	<tr class="#EvenOdd[IncrementValue(CurrentRow MOD 2)]#" valign="top">
		<cfif IsDir><td><a href="#CGI.SCRIPT_NAME#/#URL#<cfif Kind EQ 'dir'>/</cfif>">#HTMLEditFormat(Name)#</a></td></cfif>
		<td nowrap="nowrap" class="num"><cfif IsDir>#NumberFormat(Revision)#<cfelse><a href="#CGI.SCRIPT_NAME##Path#:#Revision#">#NumberFormat(Revision)#</a></cfif></td>
		<cfif NOT IsDir><td align="center"><cfif CanDiff AND (CurrentRow LT RecordCount)><a href="#CGI.SCRIPT_NAME##Path#:#f.Revision[IncrementValue(CurrentRow)]#:#Revision#">#DiffGraphic#</a><cfelse>&nbsp;</cfif></td></cfif>
		<cfif IsDir><td nowrap="nowrap" class="num"><cfif (Kind EQ 'file') AND IsNumeric(Size)>#NumberFormat(Size)#</cfif></td></cfif>
		<td class="date<cfif IsDate(Date)> #FreshnessRating(Date)#</cfif>" nowrap="nowrap"><cfif IsDate(Date)>#DateFormat(Date,"yyyy-mm-dd")# #TimeFormat(Date,"HH:mm:ss")#<cfelse>#HTMLEditFormat(Date)#</cfif></td>
		<td>#HTMLEditFormat(Author)#</td>
		<cfif NOT IsDir><td>#HTMLEditFormat(Message)#</td></cfif>
	</tr>
</cfoutput>
<cfoutput>
	</tbody>
	<tfoot>
	<tr>
		<cfif IsDir>
		<td colspan="5">#NumberFormat(TotalBytes)# byte<cfif TotalBytes NEQ 1>s</cfif> in <cfif TotalFiles GT 0>#NumberFormat(TotalFiles)# file<cfif TotalFiles NEQ 1>s</cfif><cfif TotalDirs GT 0> and </cfif></cfif><cfif TotalDirs GT 0>#NumberFormat(TotalDirs)# director<cfif TotalDirs NEQ 1>ies<cfelse>y</cfif></cfif>.</td>
		<cfelse>
		<td colspan="5">#f.RecordCount# revision<cfif f.RecordCount NEQ 1>s</cfif> found.</td>
		</cfif>
	</tr>
	</tfoot>
</table>
</cfoutput>
</cfif>

<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">