<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ011"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj011_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj011List.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >
<table width="100%" class="function-bar" >
<de:form action="<%=formAction%>" target="<%=formTarget%>">
	<tr>
        <td class="subsys-title" width="8%">年月</td>
        <td width="30%" class="light-bg-left">
        	<de:text type="dateYMNew" fmt="W" name="begDate_qry" size="10"/>~
        	<de:text type="dateYMNew" fmt="W" name="endDate_qry" size="10"/>
        </td>
        <td class="subsys-title" width="10%">盤點卡號碼</td>
        <td width="30%" class="light-bg-left">
        	<de:text name="chkDispNo" size="20" value='SCP15060086' required="true"/>
        </td>
        <td class="subsys-title" width="8%">功能 </td>
		<td class="function-bar-left">
            <input type="button" name="btn" id="btn" value="查詢" onclick="query()">
        </td>
	</tr>
</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="xlssql"/>

<div id="bqjj011Tab"  style="height:100%">
<iframe name="bqjj011_<%=sessionId%>" id="bqjj011Id" width="100%" height="90%" frameborder=0 src="/erp/bq/jsp/bqjj011List.jsp"></iframe>
</div>
</de:form>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;

//查詢
function query() {
	if ( !deValidateInputData() ) { 
		return false ; 
	}
	form1._action.value="I";
	form1.submit() ;
}
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
