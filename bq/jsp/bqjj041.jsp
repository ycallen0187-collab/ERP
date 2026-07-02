<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ041"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj0411_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj0411.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="compId_qry" value="yc"/>

<div id="bqjj0411Tab"  style="height:100%">
<iframe name="bqjj0411_<%=sessionId%>" id="bqjj0411Id" width="100%" height="90%" frameborder=0 
	src="http://172.17.0.29:3000/d/df3a2eialv08we/iv1?orgId=1&from=now-30d&to=now&timezone=browser&var-shipYM=$__all&var-Factory=$__all&var-Sales=$__all&var-Location=TW&var-Datefrom=202603&var-Dateto=202603&refresh=5m&timezone=browser&kiosk">

	
</iframe>
</div>

<script>
// sessionId 不要亂刪，有用 !!
var sessionId = "<%=sessionId%>" ;
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
