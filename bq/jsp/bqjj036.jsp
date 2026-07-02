<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ036"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0361_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0361.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0361Tab"  style="height:100%">
<iframe name="bqjj0361_<%=sessionId%>" id="bqjj0361Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/4850ccf4-8a75-4bad-88d5-61c2d3d3c0b9/e69697-e4b880-e688b0-e68385-e5aea4?orgId=1&from=now-90d&to=now&timezone=browser&kiosk">
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
