<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ044"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0441_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0441.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0441Tab"  style="height:100%">
<iframe name="bqjj0441_<%=sessionId%>" id="bqjj0441Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/84f53773-536b-48c2-8c8b-a7cbaab162c3/lv1-dashboard?orgId=1&from=now-1d%2Fd&to=now-1d%2Fd&timezone=browser&var-Date=202602&var-Datefrom=202601&var-Dateto=202603&timezone=browser&kiosk">

	
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
