<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ043"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0431_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0431.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0431Tab"  style="height:100%">
<iframe name="bqjj0431_<%=sessionId%>" id="bqjj0431Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/6f3eab69-c9fd-4cd9-ab99-bf971b980a44/iwzpc6-e6a99f-e58fb0-e8b2a0-e88db7-e6988e-e7b4b0?orgId=1&from=now-6h&to=now&timezone=browser&var-Factory=%E6%96%97%E4%BA%8C&var-Utility=80&refresh=5m&timezone=browser&kiosk">

	
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
