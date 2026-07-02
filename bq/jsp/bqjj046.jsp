<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ046"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0461_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0461.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0461Tab"  style="height:100%">
<iframe name="bqjj0461_<%=sessionId%>" id="bqjj0461Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/dd00905c-a12f-4a79-88b0-c2a3af466dd3/e8a381-e589aa-e8aab2?orgId=1&from=now%2FM&to=now%2FM&timezone=browser&refresh=30m&timezone=browser&kiosk">

	
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
