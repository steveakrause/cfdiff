<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<!--- 
Original code by Rick Osborne, 2007
  http://cfdiff.googlecode.com/
... released under the Mozilla Public License v1.1
  http://www.mozilla.org/MPL/

  READ THE LICENSE BEFORE YOU USE OR MODIFY THIS CODE
--->

<cfset ThisPage=CGI.SCRIPT_NAME>
<cfset PageAction=CGI.PATH_INFO>
<!--- Some web servers prepend the SCRIPT_NAME to the PATH_INFO --->
<cfif Left(PageAction,Len(ThisPage)) EQ ThisPage><cfset PageAction=Mid(PageAction,Len(ThisPage),Len(PageAction))></cfif>

<!--- <cfif NOT StructKeyExists(URL,"cfid")>
	<cflocation addtoken="true" url="#ThisPage##PageAction#">
</cfif> --->

<cflock scope="Application" type="exclusive" timeout="5">
	<cfif NOT StructKeyExists(Application,"ChatLog")>
		<cfset Application.ChatLog=QueryNew("id,ts,Type,UID,Msg","integer,date,varchar,integer,varchar")>
	</cfif>
	<cfif NOT StructKeyExists(Application,"ChatUsers")>
		<cfset Application.ChatUsers=StructNew()>
	</cfif>
	<cfif NOT StructKeyExists(Application,"ChatPointers")>
		<cfset Application.ChatPointers=StructNew()>
	</cfif>
	<cfif NOT StructKeyExists(Application,"ChatUserCount")>
		<cfset Application.ChatUserCount=0>
	</cfif>
	<cfif NOT StructKeyExists(Application,"ChatEvents")>
		<cfset Application.ChatEvents=0>
	</cfif>
	<cfif NOT StructKeyExists(Application,"ChatTopic")>
		<cfset Application.ChatTopic="">
	</cfif>
	<cfif NOT StructKeyExists(Application,"ChatTopicBy")>
		<cfset Application.ChatTopicBy=0>
	</cfif>
	<cfif NOT StructKeyExists(Application,"Welcome")>
		<cfset Application.Welcome="Welcome to ColdFusion SyncChat.  To change your nick, type: /nick YourNewNick">
	</cfif>
	<!--- <cfif NOT StructKeyExists(Application,"ChatEvent")> --->
		<cffunction name="ChatEvent" returntype="void" output="false">
			<cfargument name="Type" type="string" required="true">
			<cfargument name="Msg" type="string" required="true">
			<cfset var MinPointer=0>
			<cfset var UID="">
			<cfif Application.ChatLog.RecordCount GT 100>
				<cfquery dbtype="query" name="Application.ChatLog">
				SELECT #Application.ChatLog.ColumnList#
				FROM Application.ChatLog
				WHERE (id > <cfqueryparam cfsqltype="cf_sql_integer" value="#Application.ChatLog.id[50]#">)
				ORDER BY ts
				</cfquery>
				<cfset MinPointer=Application.ChatLog.id[1]>
				<cfloop collection="#Application.ChatPointers#" item="UID">
					<cfset Application.ChatPointers[UID]=Max(Application.ChatPointers[UID],MinPointer)>
				</cfloop>
			</cfif>
			<cfset Application.ChatEvents=Application.ChatEvents+1>
			<cfset QueryAddRow(Application.ChatLog)>
			<cfset QuerySetCell(Application.ChatLog,"ID",Application.ChatEvents,Application.ChatLog.RecordCount)>
			<cfset QuerySetCell(Application.ChatLog,"TS",Now(),Application.ChatLog.RecordCount)>
			<cfset QuerySetCell(Application.ChatLog,"Type",Arguments.Type,Application.ChatLog.RecordCount)>
			<cfset QuerySetCell(Application.ChatLog,"UID",Session.ChatUserID,Application.ChatLog.RecordCount)>
			<cfset QuerySetCell(Application.ChatLog,"Msg",Arguments.Msg,Application.ChatLog.RecordCount)>
		</cffunction>
		<cfset Application.ChatEvent=ChatEvent>
	<!--- </cfif> --->
	<cfif NOT StructKeyExists(Application,"RecentEvents")>
		<cffunction name="RecentEvents" returntype="query" output="false">
			<cfset var MyEvents="">
			<cfset var MyLast=0>
			<cflock scope="Session" type="exclusive" timeout="5">
				<cfif NOT StructKeyExists(Application.ChatPointers,Session.ChatUserID)>
					<cfset Application.ChatPointers[Session.ChatUserID]=Application.ChatEvents>
				</cfif>
			</cflock>
			<cflock scope="Application" type="exclusive" timeout="5">
				<cfquery dbtype="query" name="MyEvents">
				SELECT #Application.ChatLog.ColumnList#
				FROM Application.ChatLog
				WHERE (id > #MyLast#)
				</cfquery>
			</cflock>
			<cflock scope="Session" type="exclusive" timeout="5">
				<cfset Application.ChatPointers[Session.ChatUserID]=Application.ChatEvents>
			</cflock>
			<cfreturn MyEvents>
		</cffunction>
		<cfset Application.RecentEvents=RecentEvents>
	</cfif>
</cflock>

<cfswitch expression="#PageAction#">

<cfcase value="/debug">
	<cfdump var="#Application#">
	<cfdump var="#Session#">
</cfcase>

<cfcase value="/chat">
	<cfset writer=getPageContext().getResponse().getResponse().getWriter()>
	<cfset thread=CreateObject("java", "java.lang.Thread")>
	<cfset boundary=CreateUUID()>
	<cfcontent reset="true" type="multipart/x-mixed-replace;boundary=#Boundary#">
	<cfflush>
	<cfset CrLf=Chr(13)&Chr(10)>
	<cfset boundary="--#boundary##CrLf#Content-type: text/xml#CrLf##CrLf#">
	<cfset spacer=RepeatString("          " & CrLf,103)>
	<cfoutput>#boundary#<stream><message from="0" ts="#DateFormat(Now(),'yyyy-mm-dd')# #TimeFormat(Now(),'HH:mm:ss')#" id="#Application.ChatEvents#">#XMLFormat(Application.Welcome)#</message><subject from="#Application.ChatTopicBy#">#XMLFormat(Application.ChatTopic)#</subject></stream>#spacer#</cfoutput>
	<cfset OutCold=0>
	<cfset SleepTimer=333>
	<cfloop condition="(NOT writer.checkError())">
		<cfset MyEvents=Application.RecentEvents()>
		<cfif (OutCold GT 2000) OR (MyEvents.RecordCount GT 0)>
			<cfset OutCold=0>
			<cfoutput>#boundary#<stream></cfoutput>
			<cfloop query="MyEvents">
				<cfswitch expression="#Type#">
					<cfcase value="ME">
						<cfoutput><action from="#UID#" ts="#DateFormat(ts,'yyyy-mm-dd')# #TimeFormat(ts,'HH:mm:ss')#" id="#id#">#XMLFormat(Msg)#</action></cfoutput>
					</cfcase>
					<cfcase value="TOPIC">
						<cfoutput><subject from="#UID#" ts="#DateFormat(ts,'yyyy-mm-dd')# #TimeFormat(ts,'HH:mm:ss')#" id="#id#">#XMLFormat(Msg)#</subject></cfoutput>
					</cfcase>
					<cfcase value="SAY">
						<cfoutput><message from="#UID#" ts="#DateFormat(ts,'yyyy-mm-dd')# #TimeFormat(ts,'HH:mm:ss')#" id="#id#">#XMLFormat(Msg)#</message></cfoutput>
					</cfcase>
					<cfcase value="NICK,JOIN,PART">
						<cfoutput><presence id="#UID#" ts="#DateFormat(ts,'yyyy-mm-dd')# #TimeFormat(ts,'HH:mm:ss')#" subscription="<cfif Type EQ 'JOIN'>subscribe<cfelseif Type EQ 'PART'>remove<cfelse>both</cfif>">#XMLFormat(Msg)#</presence></cfoutput>
					</cfcase>
				</cfswitch>
			</cfloop>
			<cfoutput></stream>#CrLf#</cfoutput>
			<cfset SleepTimer=333>
		<cfelse>
			<cfset SleepTimer=Int(Min(SleepTimer*1.1,1500))>
			<cfset OutCold=OutCold+SleepTimer>
		</cfif>
		<cfflush>
		<cfset thread.sleep(JavaCast("int",SleepTimer))>
	</cfloop>
	<cfabort>
</cfcase>
	
<cfcase value="/say">
	<cfcontent type="text/xml">
	<cflock scope="Session" type="exclusive" timeout="5">
		<cfif StructKeyExists(Form,"msg") AND StructKeyExists(Session,"ChatUserID")>
			<cfif Left(Form.msg,1) EQ "/">
				<cfset Command=UCase(Mid(ListFirst(Form.msg," "),2,99))>
				<cfset Form.msg=ListRest(Form.msg," ")>
				<cfswitch expression="#Command#">
					<cfcase value="TOPIC">
						<cflock scope="Application" type="exclusive" timeout="5">
							<cfset Application.ChatTopic=Form.msg>
						</cflock>
					</cfcase>
					<cfcase value="ME">
					</cfcase>
					<cfcase value="NICK">
						<cfset Session.ChatNick=REReplaceNoCase(Trim(Form.msg),"[^ 0-9a-zA-Z_-]+","","ALL")>
						<cflock scope="Application" type="exclusive" timeout="5">
							<cfset Application.ChatUsers[Session.ChatUserID]=Session.ChatNick>
						</cflock>
					</cfcase>
					<cfdefaultcase>
						<cfset Command="SAY">
					</cfdefaultcase>
				</cfswitch>
			<cfelse>
				<cfset Command="SAY">
			</cfif>
			<cflock scope="Application" type="exclusive" timeout="5">
				<cfset Application.ChatEvent(Command,Form.msg)>
			</cflock>
		<cfelse>
			<cfoutput><nope/></cfoutput>
			<cfabort>
		</cfif>
	</cflock>
	<!--- <cfheader statuscode="204" statustext="If you say so"> --->
	<cfoutput><ok/></cfoutput>
	<cfabort>
</cfcase>

<cfcase value="/join">
	<cflock scope="Session" type="exclusive" timeout="5">
		<cflock scope="Application" type="exclusive" timeout="5">
			<cfif NOT StructKeyExists(Session,"ChatUserID")>
				<cfset NewID=Application.ChatUserCount+1>
				<cfset Application.ChatUserCount=NewID>
				<cfset Session.ChatUserID=NewID>
				<cfset Session.ChatNick="Guest" & RandRange(10000,99999)>
				<cfset Application.ChatPointers[NewID]=Application.ChatEvents>
			</cfif>
			<cfset Application.ChatUsers[Session.ChatUserID]=Session.ChatNick>
			<cfset Application.ChatEvent("JOIN",Session.ChatNick)>
		</cflock>
	</cflock>
	<!--- <cfheader statuscode="204" statustext="Welcome"> --->
	<cfcontent type="text/xml">
	<cflock scope="Application" type="exclusive" timeout="5">
		<cfoutput><stream><cfloop collection="#Application.ChatUsers#" item="UserID"><presence id="#UserID#" subscription="subscribe">#XMLFormat(Application.ChatUsers[UserID])#</presence></cfloop></stream></cfoutput>
	</cflock>
	<cfabort>
</cfcase>

<cfcase value="/part">
	<cflock scope="Session" type="exclusive" timeout="5">
		<cfif StructKeyExists(Session,"ChatUserID")>
			<cflock scope="Application" type="exclusive" timeout="5">
				<cfset Application.ChatEvent("PART",Nick)>
				<cfset StructDelete(Application.ChatUsers,Session.ChatUserID)>
				<cfset StructDelete(Application.ChatPointers,Session.ChatUserID)>
			</cflock>
			<cfset StructDelete(Session,"ChatPointer",false)>
			<cfset StructDelete(Session,"ChatUserID",false)>
			<cfset StructDelete(Session,"ChatNick",false)>
		</cfif>
	</cflock>
	<!--- <cfheader statuscode="204" statustext="Have a nice day"> --->
	<cfcontent type="text/xml">
	<cfoutput><ok/></cfoutput>
	<cfabort>
</cfcase>

<cfdefaultcase>
	<cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>ColdFusion SyncChat by Rick Osborne</title>
		<style type="text/css">
html, body {
	background-color: white;
	color: black;
	font-size: 1em;
	line-height: 1.1em;
	margin: 0 0 0 0;
	padding: 0 0 0 0;
	font-family: "Bitsream Vera Sans", "Vera Sans", Verdana, Tahoma, Helvetica, sans-serif, sans;
}
body { padding: 1.5em; }
a { color: blue; }
h1 {
	font-size: 1em;
	font-weight: bold;
	background-color: ##8df;
	color: ##124;
	padding: 0.5em;
	border-bottom: 2px solid ##248;
	margin: -1.5em -1.5em 0 -1.5em;
}
##Users {
	position: absolute;
	z-index: 100;
	width: 200px;
	right: 0px;
	top: 2.250em;
	bottom: 0px;
	overflow: auto;
	border-left: 1px solid ##060;
	background-color: ##cfc;
	color: ##060;
}
##Users div { margin: 0.1em 1em 0.1em 1em; }
##Topic {
	position: absolute;
	z-index: 95;
	top: 2.250em;
	left: 0px;
	right: 0px;
	margin-right: 200px;
	border-bottom: 1px solid ##008;
	color: ##007;
	background-color: ##def;
	padding: 0.25em;
	font-size: 0.8em;
}
##Chat {
	position: absolute;
	z-index: 90;
	top: 2.50em;
	left: 0px;
	right: 0px;
	margin-right: 200px;
	bottom: 2.5em;
	border-bottom: 1px solid ##666;
	overflow: auto;
}
##Input {
	position: absolute;
	bottom: 0px;
	left: 0px;
	right: 0px;
	margin-right: 200px;
	height: 2.5em;
	border: none;
	padding: 4px;
	background-color: ##ffc;
}
.ts {
	font-family: "Bitstream Vera Sans Mono", "Lucida Console", "Lucida Typewriter", "Courier New", Courier, fixed-width, fixed;
	color: ##ddd;
	font-size: 0.75em;
}
.nick {
	color: ##660;
}
p {
	margin-bottom: 0em;
	text-indent: -3em;
	margin-left: 3em;
}
.hint {
	background-color: ##ffc;
	color: maroon;
	padding: 1em;
	border-top: 1px solid maroon;
	border-bottom: 1px solid maroon;
	margin-left: 0em;
	text-indent: 3em;
}
.system { color: ##bbb; }
.emote { color: ##970; }
		</style>
		<script language="javascript" type="text/javascript">
//<![CDATA[
var inp = null;
var chat = null;
var users = null;
var topic = null;
var base = '#ThisPage#';
var token = '#Session.UrlToken#';
function removeUser(n) {
	var o = document.getElementById('user'+n);
	if(o != null) { var p = o.parentNode; p.removeChild(o); }
} // removeUser
function updateUser(n,u) {
	if(users == null) { return false; }
	var uid = 'user' + n;
	var o = document.getElementById(uid);
	if(o == null) { 
		o = document.createElement('div');
		o.id = uid;
		users.appendChild(o);
	} // need to create a user
	for(var i = o.childNodes.length - 1; i > -1; i--) { o.removeChild(o.childNodes[i]); }
	o.appendChild(document.createTextNode(u));
} // addUser
function sendLine() {
	if((inp == null) || (inp.value == null)) { return false; }
	var line = inp.value;
	inp.value = '';
	line = line.replace(/^\s+|\s+$/gi,'');
	if(line == '') { return false; }
	sendRequest(base+'/say',function(req){},'msg='+escape(line));
	inp.focus();
	return false;
} // sendLine
function setup() {
	inp = document.getElementById('Input');
	chat = document.getElementById('Chat');
	users = document.getElementById('Users');
	topic = document.getElementById('Topic');
	sendRequest(base+'/chat',handleChat,null,true);
	sendRequest(base+'/join',handleChat,null);
	inp.focus();
} // setup
// XHR stuff ganked from quirksmode.org
function sendRequest(url,callback,postData,multi) {
	var req = createXMLHTTPObject();
	url += (url.indexOf('?') > -1 ? '&' : '?') + token;
	if (!req) return;
	var method = (postData) ? "POST" : "GET";
	if(multi) req.multipart = true;
	req.open(method,url,true);
	req.setRequestHeader('User-Agent','XMLHTTP/1.0');
	if (postData) req.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	req.onreadystatechange = function () {
		if (req.readyState != 4) return;
		if (req.status != 200 && req.status != 304 && req.status != 204) { return; }
		callback(req);
	} // onreadystatechange
	if (req.readyState == 4) return;
	req.send(postData);
} // sendRequest
var XMLHttpFactories = [
	function () {return new XMLHttpRequest()},
	function () {return new ActiveXObject("Msxml2.XMLHTTP")},
	function () {return new ActiveXObject("Msxml3.XMLHTTP")},
	function () {return new ActiveXObject("Microsoft.XMLHTTP")}
];
function createXMLHTTPObject() {
	var xmlhttp = false;
	for (var i=0;i<XMLHttpFactories.length;i++) {
		try { xmlhttp = XMLHttpFactories[i](); }
		catch (e) { continue; }
		break;
	} // for
	return xmlhttp;
} // createXMLHTTPObject
function getNick(uid) {
	var o = document.getElementById('user'+uid);
	if((o != null) && (o.textContent != null)) return o.textContent;
	else return '?????';
} // getNick
function handleChat(resp) {
	var r = resp.responseXML;
	if(r == null) return;
	if((r.childNodes == null) || (r.childNodes.length <= 0)) return;
	r = r.childNodes[0];
	if((r.childNodes == null) || (r.childNodes.length <= 0)) return;
	for(var i = 0; i < r.childNodes.length; i++) {
		var n = node2obj(r.childNodes[i]);
		switch(r.childNodes[i].nodeName) {
			case 'presence': // <presence id="UID" ts="" subscription="both">name</presence>
				if((n.subscription != null) && (n.id != null) && (n.textContent.length > 0)) {
					if(n.subscription == 'remove') {
						if(n.ts != null) addSystemMessage(n.ts,'* Parts: ' + n.textContent);
						removeUser(n.id);
					} else if(n.subscription == 'subscribe') {
						if(n.ts != null) addSystemMessage(n.ts,'* Joins: ' + n.textContent);
						updateUser(n.id,n.textContent);
					} else {
						if(n.ts != null) addSystemMessage(n.ts,'* Nick change: ' + getNick(n.id) + '->' + n.textContent);
						updateUser(n.id,n.textContent);
					}
				}
				break;
			case 'message': // <message from="uid" ts="" id="id">foo bar baz</message>
				if((n.from != null) && (n.textContent.length > 0) && (n.ts != null)) {
					if(n.from == 0) addSystemMessage(n.ts,n.textContent);
					else addChat(n.ts,getNick(n.from),n.textContent);
				} 
				break;
			case 'subject':
				if(n.textContent.length > 0) {
					changeTopic(n.ts,getNick(n.from),n.textContent);
				} 
				break;
			case 'action':
				if((n.textContent.length > 0) && (n.from != null) && (n.ts != null)) {
					emote(n.ts,getNick(n.from),n.textContent);
				} 
				break;
		} // switch tagName
	} // for i
} // handleChat
function makeChatLine(ts) {
	var p = document.createElement('p');
	var tss = document.createElement('span');
	tss.className = "ts"
	tss.appendChild(document.createTextNode(ts.substring(11,19)));
	p.appendChild(tss);
	p.appendChild(document.createTextNode(' '));
	return p;
}
function cleanChat() {
	while((chat.childNodes != null) && (chat.childNodes.length > 100)) {
		chat.removeChild(chat.childNodes[0]);
	}
	chat.scrollTop = chat.scrollHeight;
} // cleanChat
function emote(ts,nick,action) {
	if(chat != null) {
		var p = makeChatLine(ts);
		var em = document.createElement('span');
		em.className = 'emote';
		em.appendChild(document.createTextNode('* ' + nick + ' ' + action));
		p.appendChild(em);
		chat.appendChild(p);
		p.focus();
		cleanChat();
	}
} // emote
function changeTopic(ts,nick,newtopic) {
	if(topic != null) {
		topic.textContent = 'Topic: ' + newtopic;
		if(ts != null) addSystemMessage(ts,'* Topic changed by ' + nick + ' to ' + newtopic);
	}
} // changeTopic
function addSystemMessage(ts,msg) {
	if(chat != null) {
		var p = makeChatLine(ts);
		p.appendChild(document.createTextNode(' ' + msg));
		chat.appendChild(p);
		cleanChat();
	}
} // addSystemMessage
function addChat(ts,nick,msg) {
	if(chat != null) {
		var p = makeChatLine(ts);
		p.appendChild(document.createTextNode(' '));
		var ns = document.createElement('span');
		ns.className = 'nick';
		p.appendChild(document.createTextNode('<' + nick + '>'));
		p.appendChild(ns);
		p.appendChild(document.createTextNode(' ' + msg));
		chat.appendChild(p);
		p.focus();
		cleanChat();
	}
} // addSystemMessage
function node2obj(n) {
	var o = new Object();
	if(n.attributes != null) {
		for(var i = 0; i < n.attributes.length; i++) {
			o[n.attributes[i].nodeName] = n.attributes[i].nodeValue;
		} // for i
	}
	if(n.textContent != null) o.textContent = n.textContent;
	return o;
} // node2obj
//]]>
		</script>
	</head>
	<body onload="setup()">
<h1>ColdFusion SyncChat by Rick Osborne &mdash; <a href="http://rickosborne.org/">rickosborne.org</a></h1>
<div id="Topic">Topic:</div>
<div id="Chat"></div>
<div id="Users"></div>
<form onsubmit="return(sendLine())"><input type="text" id="Input" autocomplete="off"/></form>
	</body>
</html>
	</cfoutput>
</cfdefaultcase>

</cfswitch>