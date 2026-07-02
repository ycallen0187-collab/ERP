<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ026"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj026_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj026List.jsp?_sessionId="+sessionId ;
	
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >
<table width="100%" class="function-bar" >
<de:form action="<%=formAction%>" target="<%=formTarget%>">
	<tr>
		<td class="subsys-title" width="8%">廠別</td>
		<td width="10%" class="light-bg-left">
			<de:select name="LOCA" src="de.Option" option="D=斗六二廠" defaultValue="D" hideValue="true" />
		</td>
		<td class="subsys-title" width="8%">倉別</td>
		<td width="10%" class="light-bg-left">
			<de:select name="LOCNAME" src="de.Option" option="原料區=原料區;成品倉=成品倉;" hideValue="true" defaultValue="原料區" />
		</td>
        <td class="subsys-title" width="10%">功能 </td>
		<td class="function-bar-left">
            <input type="button" name="btn" id="btn" value="查詢" onclick="query()">
        </td>
	</tr>
</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="xlssql"/>

<div id="bqjj026Tab"  style="height:100%">
<iframe name="bqjj026_<%=sessionId%>" id="bqjj026Id" width="100%" height="90%" frameborder=0 src="/erp/bq/jsp/bqjj026List.jsp"></iframe>	
</div>
</de:form>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;

//查詢
function query() {
	if ( !deValidateInputData() ) { 
		return false ; 
	}else{
		form1._action.value="I";
		//ff.tabTable.show(document.all.bqjj026Tab);
		form1.submit() ;
	}
}

</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
