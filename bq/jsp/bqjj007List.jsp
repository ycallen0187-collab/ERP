<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.ag.dao.agjcbdT1DAO"%>
<%! public static final String _AppId = "BQJJ007"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >
 
<%
String sessionId = request.getParameter("_sessionId") ;
StringBuffer rptUrl = new StringBuffer();
aajcYCATool aaTool = new aajcYCATool();
try{
    String yearMo = aaTool.getStr(request.getParameter("yearMo_qry").replaceAll("/",""));
    String matType = aaTool.getStr(request.getParameter("matType_qry"));
    String bmatNo = aaTool.getStr(request.getParameter("bmatNo_qry"));
    String purpCode = aaTool.getStr(request.getParameter("isBoned_qry"));
    
    if(purpCode.equals("Y")){
    	purpCode = " IN ('B') ";
    }else if(purpCode.equals("D")){
    	purpCode = " IN ('D') ";
    }else if(purpCode.equals("P")){
    	purpCode = " IN ('P') ";
    }else if(purpCode.equals("")){
    	purpCode = " IN ('B','D','P') ";
    }   
 
    String condition="";
    
    if(!"".equals(yearMo)){
    	condition = condition + " AND b.yearMo = '"+yearMo+"' ";
    }
    if(!"".equals(matType)){
    	condition = condition + " AND a.GOODSTYPE = '"+matType+"' ";
    }
    if(!"".equals(bmatNo)){
    	condition = condition + " AND c.B_MATNO = '"+bmatNo+"' ";
    }
    if(!"".equals(purpCode)){
    	condition = condition + " AND c.PURPCODE "+ purpCode ;
    } 
    
    //ºô°ì    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
	rptUrl.append(domain + "MP002/BQJJ007");
	 
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
