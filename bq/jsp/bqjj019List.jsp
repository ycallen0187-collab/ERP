<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.ag.dao.agjcbdT1DAO"%>
<%! public static final String _AppId = "BQJJ019"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >

<%
String sessionId = request.getParameter("_sessionId") ;
StringBuffer rptUrl = new StringBuffer();
aajcYCATool aaTool = new aajcYCATool();
try{
    String matNo = aaTool.getStr(request.getParameter("matNo_qry"));
    String begDate = aaTool.getStr(request.getParameter("begDate_qry").replaceAll("/",""));
    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));  
    
    String purpCode = aaTool.getStr(request.getParameter("isBoned_qry"));
    String condition =""; 
    
    if(purpCode.equals("Y")){
    	condition = " AND A.MATNOB LIKE '%B' ";
    }else if(purpCode.equals("D")){
    	condition = "  AND A.MATNOB LIKE '%D' ";
    }else if(purpCode.equals("P")){
    	condition = "  AND A.MATNOB LIKE '%P' ";
    }else if(purpCode.equals("")){
    	condition = "  AND 1=1  ";  //全部的意思 
    }   
     
    //網域    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
	rptUrl.append(domain + "MP002/BQJJ019");
	//本月期末，改抓下月期初，因為科目借貸方不同，不好計算
    rptUrl.append("&begDateYM=" + begDate);
    rptUrl.append("&endDateYM=" + endDate);
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
