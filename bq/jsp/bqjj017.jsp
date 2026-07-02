<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 

<%! public static final String _AppId = "BQJJ017"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj017_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj017List.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >
<table width="100%" class="function-bar" >
<de:form action="<%=formAction%>" target="<%=formTarget%>">
	<tr>

        <td class="subsys-title" width="8%">交易日期</td>
        <td width="18%"  class="light-bg-left">
        	<de:text type="dateNew" fmt="W" name="begDate_qry" size="10" required="true" />~
        	<de:text type="dateNew" fmt="W" name="endDate_qry" size="10" required="true" />
        </td>
		<td class='subsys-title' width="8%">作業項目</td>
		<td class="light-bg-left" width="8%"><de:select name="tallyItem_qry" src="ig.igf.TallyItem"
			first="..." rmClass="ig.igf.ReasonId" child="reasonId_qry"
			hideValue='true' /></td>
		<td class='subsys-title' width="8%">管理用途</td>
		<td class="light-bg-left" ><de:select name="reasonId_qry" hideValue='true' /></td>
	</tr>	 
    <tr>   
           
  		<td width="8%" class='subsys-title'>料別</td>
			<td width="16%" class="light-bg-left"><de:select name='matType_qry' src="ig.igf.MatTypeB"  first="請選擇"/>
		</td>
    
     	<td class="subsys-title" width="8%">保稅料號</td>
        <td  class="light-bg-left"><de:text name="bmatNo_qry" size="20"/></td>
				 
		<td  width="16%" class='subsys-title'>存貨ID</td>
			<td  class="light-bg-left" width="30%"><de:text name='lotId0_qry'  size="18" />~
			<de:text name='lotId1_qry'   size="18"  /> 
		</td>
	</tr>
	<tr>      
	        		
		<td class="subsys-title" width="8%">保品/非保</td>
        <td width="10%" class="light-bg-left">
            <de:select name="isBoned_qry"  de323TableId="BONDEDCODE" de323TextField="2" de323ValueField="1" first="請選擇" />
        </td>		
		<td  width="16%"  class='subsys-title'>進口報單號</td>
			<td class="light-bg-left" colspan="4" ><de:text name='slading0_qry'   />~
			<de:text name='slading1_qry'  /> 
		</td>
		
		
	</tr>	 
    <tr>
        <td class="subsys-title" width="8%">功能 </td>
		<td class="function-bar-left">
            <input type="button" name="btn" id="btn" value="查詢" onclick="query()">
        </td>
	</tr>
</table>
<%-- HIDDEN的欄位 --%>
<de:text type="hidden" name="xlssql"/>

<div id="bqjj017Tab"  style="height:100%">
<iframe name="bqjj017_<%=sessionId%>" id="bqjj017Id" width="100%" height="90%" frameborder=0 src="/erp/bq/jsp/bqjj017List.jsp"></iframe>
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
