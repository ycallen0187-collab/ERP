<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ007"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj007_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj007List.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >
<table width="100%" class="function-bar" >
<de:form action="<%=formAction%>" target="<%=formTarget%>">
  
    <tr>   
           
  		<td width="10%" class='subsys-title'> 年月 </td>
	    <td width="10%" class="light-bg-left">
			<de:text name="yearMo_qry" fmt="W" type="dateYMNew" required="true"/>
        </td>  
        <td width="10%" class='subsys-title'> 料別 </td>
	    <td width="10%" class="light-bg-left">
			<de:select name="matType_qry" src="ig.igf.MatTypeB"  hideValue='true' first="請選擇" />
        </td>  
    
     	<td class="subsys-title" width="10%">保稅料號</td>
        <td  width="10%" class="light-bg-left"><de:text name="bmatNo_qry" size="20"/></td>
		<td class="subsys-title" width="8%">保品/非保</td>
        <td width="10%" class="light-bg-left">
            <de:select name="isBoned_qry"  de323TableId="BONDEDCODE" de323TextField="2" de323ValueField="1" first="請選擇" />
        </td>		 
  
        <td class="subsys-title" width="8%">功能 </td>
		<td class="function-bar-left">
            <input type="button" name="btn" id="btn" value="查詢" onclick="query()">
        </td>
	</tr>
</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="xlssql"/>

<div id="bqjj007Tab"  style="height:100%">
<iframe name="bqjj007_<%=sessionId%>" id="bqjj007Id" width="100%" height="90%" frameborder=0 src="/erp/bq/jsp/bqjj007List.jsp"></iframe>
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
	
	if(form1.isBoned_qry.value=="N"){
		alert("無法查詢非保稅資料")
		return false ; 	
	}
	
	form1._action.value="I";
	form1.submit() ;
}
</script>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp" %>
