<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ037"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0371_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0371.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0371Tab"  style="height:100%">
<iframe name="bqjj0371_<%=sessionId%>" id="bqjj0371Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/c9d14144-94a6-4847-bd93-e4060f3a9434/49b152a?orgId=1&from=now-90d&to=now&timezone=browser&kiosk">
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
