<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ004"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj004_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj004List.jsp?_sessionId="+sessionId ;
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
        <td width="15%" class="light-bg-left">
        	<de:text name="chkDispNo" size="20" value='SCP15060086' required="true"/>
        </td>
        <td class="subsys-title" width="5%">報表</td>
        <td width="8%" class="light-bg-left">
			<de:select name="report_qry" src="de.Option" option="F=明細;G=彙總" hideValue="true"/>
		</td>
		
        <td class="subsys-title" width="8%">功能 </td>
		<td class="function-bar-left">
            <input type="button" name="btn" id="btn" value="查詢" onclick="query()">
        </td>
	</tr>
</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="xlssql"/>

<div id="bqjj004Tab"  style="height:100%">
<iframe name="bqjj004_<%=sessionId%>" id="bqjj004Id" width="100%" height="90%" frameborder=0 src="/erp/bq/jsp/bqjj004List.jsp"></iframe>
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
