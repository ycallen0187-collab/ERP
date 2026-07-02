<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ038"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0381_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0381.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0381Tab"  style="height:100%">
<iframe name="bqjj0381_<%=sessionId%>" id="bqjj0381Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/d5f3af8c-23a9-4116-9f66-fb7b4ea16c4e/n1-e587ba-e8b2a8-e7b5b1-e8a888?orgId=1&from=now-6h&to=now&timezone=browser&kiosk">


	
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
