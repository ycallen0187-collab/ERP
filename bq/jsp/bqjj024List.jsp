<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.ag.dao.agjcbdT1DAO"%>
<%! public static final String _AppId = "BQJJ024"; %>
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
    String b_matNo = aaTool.getStr(request.getParameter("bmatNo_qry"));
    String matType = aaTool.getStr(request.getParameter("matType_qry"));
    String tallyItem = aaTool.getStr(request.getParameter("tallyItem_qry"));
    String reasonId = aaTool.getStr(request.getParameter("reasonId_qry"));
    String lotId0  = aaTool.getStr(request.getParameter("lotId0_qry"));
    String lotId1  = aaTool.getStr(request.getParameter("lotId1_qry"));
    String slading0  = aaTool.getStr(request.getParameter("slading0_qry"));
    String slading1  = aaTool.getStr(request.getParameter("slading1_qry"));
    String purpCode = aaTool.getStr(request.getParameter("isBoned_qry"));
    String stockId = aaTool.getStr(request.getParameter("stockId_qry"));
    
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
    
    if(!"".equals(begDate)){
    	condition = condition + " AND A.TRANDATE >= '"+begDate+"' ";
    }
    if(!"".equals(endDate)){
    	condition = condition + " AND A.TRANDATE <='"+endDate+"' ";
    }
    if(!"".equals(b_matNo)){
    	condition = condition + " AND E.B_MATNO = '"+b_matNo+"' ";
    }
    if(!"".equals(matType)){
    	condition = condition + " AND A.MATTYPE ='"+matType+"' ";
    }
    if(!"".equals(tallyItem)){
    	condition = condition + " AND A.TALLYITEM = '"+tallyItem+"' ";
    }
    if(!"".equals(reasonId)){
    	condition = condition + " AND A.REASONID ='"+reasonId+"' ";
    }
    if(!"".equals(lotId0)){
    	condition = condition + " AND B.IGID >='"+lotId0+"' ";
    }
    if(!"".equals(lotId1)){
    	condition = condition + " AND B.IGID <='"+lotId1+"' ";
    }
    if(!"".equals(slading0)){
    	condition = condition + " AND G.SLADINGNO >= '"+slading0+"' ";
    }
    if(!"".equals(slading1)){
    	condition = condition + " AND G.SLADINGNO <= '"+slading1+"' ";
    }
    if(!"".equals(purpCode)){
    	condition = condition + " AND c.PURPCODE "+ purpCode ;
    } 
    if(!"".equals(stockId)){
    	condition = condition + " AND a.stockId = '"+ stockId +"' ";
    } 
    
    //網域    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
	rptUrl.append(domain + "MP002/BQJJ024");
	//本月期末，改抓下月期初，因為科目借貸方不同，不好計算
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
