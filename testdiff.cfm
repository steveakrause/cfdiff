<cfsetting showdebugoutput="false" enablecfoutputonly="true">

<cfinvoke component="net.sourceforge.cfunit.framework.TestSuite" method="init" classes="cfdiff.difftest" returnvariable="testSuite" />

<cfinvoke component="net.sourceforge.cfunit.framework.TestRunner" method="run">
	<cfinvokeargument name="test" value="#testSuite#">
	<cfinvokeargument name="name" value="">
</cfinvoke>