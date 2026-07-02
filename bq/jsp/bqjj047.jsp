<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ047"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0471_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0471.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0471Tab"  style="height:100%">
<iframe name="bqjj0471_<%=sessionId%>" id="bqjj0471Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/1cbecf2d-9ccc-4796-8955-2f7746f14307/a0253a0?orgId=1&from=now-30d&to=now&timezone=browser&var-Factory=%E6%96%97%E4%BA%8C&timezone=browser&kiosk">

	
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
