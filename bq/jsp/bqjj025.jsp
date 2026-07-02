<%@ page contentType="text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*"%>
<%@ page import="com.icsc.dpms.de.web.*"%>
<%@ page import="com.icsc.dpms.de.structs.web.*"%>
<%@ page import="com.icsc.dpms.de.structs.*"%>
<%@ page import="java.util.*"%>

<%! public static final String _AppId = "BQJJ025"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	String formTarget = "bqjj025_"+sessionId ;
	String formAction = "/erp/bq/jsp/bqjj025List.jsp?_sessionId="+sessionId ;
%>
<%@ include file="../../jsp/dzjjMenuHeader.jsp"%>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container">
	<table width="100%" class="function-bar">
		<de:form action="<%=formAction%>" target="<%=formTarget%>">
			<tr>

				<td class="subsys-title" width="8%">日期</td>
				<td width="20%" class="light-bg-left"><de:text type="dateNew"
						fmt="W" name="endDate_qry" size="10" />
					<input type="button" name="btnP" id="btnP" value="每月月初取得量" onclick="process()"> </td>
				<td class="subsys-title" width="5%">報表</td>
				<td width="8%" class="light-bg-left"><de:select
						name="report_qry" src="de.Option"
						option="A=委外加工清表;B=委外加工清表明細資料;C=調撥明細;D=成品出貨明細;E=廢料明細;F=逾期追蹤表(即時存貨);G=調撥量控管;H=總量控管 "
						hideValue="true" /></td>

				<td class="subsys-title" width="8%">功能</td>
				<td class="function-bar-left">
					
					<input type="button" name="btn"  id="btn" value="查詢" onclick="query()">
				</td>
			</tr>
	</table>
	<%-- HIDDEN的欄位 --%>
	<de:text type="hidden" name="xlssql" />

	<div id="bqjj025Tab" style="height: 100%">
		<iframe name="bqjj025_<%=sessionId%>" id="bqjj025Id" width="100%"
			height="90%" frameborder=0 src="/erp/bq/jsp/bqjj025List.jsp"></iframe>
	</div>
	</de:form>

	<script>
// sessionId 不要亂刪，有用 !! 
var sessionId = "<%=sessionId%>";

		//查詢
		function query() {
			if (!deValidateInputData()) {
				return false;
			}

			form1._action.value = "I";
			form1.submit();
		}

function process() {
	if (!deValidateInputData()) {
				return false;
	}
	alert("請至首頁工作項目等待成功訊息");
	form1._action.value = "P";
	form1.submit();
}
	</script>
	<de:footer />
</div>
<%@ include file="../../jsp/dzjjMenuFooter.jsp"%>
