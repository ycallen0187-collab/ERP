<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%! public static final String _AppId = "BQJJ021"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

<%
String sessionId = request.getParameter("_sessionId") ;
StringBuffer rptUrl = new StringBuffer();
aajcYCATool aaTool = new aajcYCATool();
try{
    String begDate = aaTool.getStr(request.getParameter("begDate_qry").replaceAll("/",""));
    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));  
    String BMATNO = aaTool.getStr(request.getParameter("BMATNO"));
    String RAWMATNO = aaTool.getStr(request.getParameter("RAWMATNO"));  
    String report = aaTool.getStr(request.getParameter("report_qry"));
    
    String purpCode = aaTool.getStr(request.getParameter("isBoned_qry"));
    String condition3="";
    
    if(purpCode.equals("Y")){
    	condition3 = "AND b.PURPCODE IN ('B') ";
    }else if(purpCode.equals("D")){
    	condition3 = "AND b.PURPCODE IN ('D') ";
    }else if(purpCode.equals("P")){
        	condition3 = "AND b.PURPCODE IN ('P') ";	
    }else if(purpCode.equals("")){
    	condition3 = "AND b.PURPCODE IN ('B','D','P') ";
    }  
    
    
    String condition= " and a.TRANDATE BETWEEN '"+ begDate +"' AND '"+ endDate +"' ";
    String condition2="";
    
    if(!"".equals(BMATNO)){
    	condition2 = condition2 + " AND b.B_MATNO = '"+ BMATNO +"' ";
    }
    if(!"".equals(RAWMATNO)){
    	condition2 = condition2 + " AND DD.B_MATNO = '"+ RAWMATNO +"' ";
    }
    
    
    
     
    //ºô°ì    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
    
    
	Map rptRSUrl = new HashMap();
	rptRSUrl.put("A", "F_42_RS_BONED/bqjj021_A");
	rptRSUrl.put("B", "F_42_RS_BONED/bqjj021_B");
	rptUrl.append(domain + rptRSUrl.get(report));

    rptUrl.append("&condition=" + condition);
    rptUrl.append("&condition2=" + condition2);
    rptUrl.append("&condition3=" + condition3);
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
