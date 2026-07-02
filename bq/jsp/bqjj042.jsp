<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ042"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj042_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj042List.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >
<de:form action="<%=formAction%>" target="<%=formTarget%>">

<div id="bqjj042Tab"  style="height: calc(100vh);overflow: hidden;">
<iframe name="bqjj042_<%=sessionId%>" id="bqjj042Id" width="100%" height="100%" frameborder=0 src="/erp/bq/jsp/bqjj042List.jsp"></iframe>
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
