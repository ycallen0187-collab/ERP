<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.ag.dao.agjcbdT1DAO"%>
<%! public static final String _AppId = "BQJJ004"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

<%
String sessionId = request.getParameter("_sessionId") ;
StringBuffer rptUrl = new StringBuffer();
aajcYCATool aaTool = new aajcYCATool();
try{
    String chkDispNo = aaTool.getStr(request.getParameter("chkDispNo"));
    String begDate = aaTool.getStr(request.getParameter("begDate_qry").replaceAll("/",""));
    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));    
    String report = aaTool.getStr(request.getParameter("report_qry"));
     
    //網域    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
 
	Map rptRSUrl = new HashMap();
	rptRSUrl.put("F", "MP002/BQJJ004");
	rptRSUrl.put("G", "MP002/BQJJ004_G");
	rptUrl.append(domain + rptRSUrl.get(report));
	
	
	//本月期末，改抓下月期初，因為科目借貸方不同，不好計算
    rptUrl.append("&chkDispNo=" + chkDispNo);
    rptUrl.append("&begDateYM=" + begDate);
    rptUrl.append("&endDateYM=" + endDate);
    rptUrl.append("&rc:Stylesheet=myStyle");

}catch(Exception e){
	rptUrl = new StringBuffer();
}
if("I".equals(request.getParameter("_action"))){

%>
<iframe width="100%" height="90%" frameborder=0 src="<%= rptUrl.toString()%>"></iframe>		
<%}%>
<de:footer/>
</div>
<%@ include file="../../jsp/dzjjMainFooter.jsp" %>
