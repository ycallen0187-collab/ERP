<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%! public static final String _AppId = "BQJJ008"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

<%
String sessionId = request.getParameter("_sessionId") ;
StringBuffer rptUrl = new StringBuffer();
aajcYCATool aaTool = new aajcYCATool();
try{
    String chkDispNo = aaTool.getStr(request.getParameter("chkDispNo"));
    String BMATNO = aaTool.getStr(request.getParameter("BMATNO"));
    String RAWMATNO = aaTool.getStr(request.getParameter("RAWMATNO"));  
    String report = aaTool.getStr(request.getParameter("report_qry"));
    
    
    String condition= " A.chkDispNo ='"+ chkDispNo +"' ";
    
    if(!"".equals(BMATNO)){
    	condition = condition + " AND C.B_MATNO = '"+ BMATNO +"' ";
    }
    if(!"".equals(RAWMATNO)){
    	condition = condition + " AND B25.RAWMATNO = '"+ RAWMATNO +"' ";
    }
     
    //ºô°ì    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
    
	  
	Map rptRSUrl = new HashMap();
	rptRSUrl.put("A", "F_42_RS_BONED/bqjj008");
	rptRSUrl.put("G", "F_42_RS_BONED/bqjj008_G");
	rptUrl.append(domain + rptRSUrl.get(report));
    //rptUrl.append("&chkDispNo=" + chkDispNo);

    rptUrl.append("&condition=" + condition);
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
