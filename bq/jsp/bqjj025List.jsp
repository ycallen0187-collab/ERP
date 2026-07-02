<%@page import="com.icsc.ag.core.agjcB10Core"%>
<%@page import="com.icsc.ag.core.agjcB09Core"%>
<%@ page contentType = "text/html;charset=cp950"%>
<%@page import="com.icsc.ig.igf.util.igfcuGetMapValue"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.ag.dao.agjcbdT1PDAO"%>
<%! public static final String _AppId = "BQJJ025"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<link rel="stylesheet" href="/erp/html/dzwcss.css" type="text/css">
<div class="container-fluid icsc-container" >
<%! 
public String action(dsjccom dsCom, HttpServletRequest request)throws Exception{ 
	String result = "";
	dejc301 de301 = new dejc301() ;
	aajcYCATool aaTool = new aajcYCATool();	
	
	try {
	    //建立連線
		Connection con = de301.getConnection(dsCom, "TSET") ;
		// 交易開始
		de301.setAutoCommit(false);
		// <coding>  的邏輯
		// 建議方針：可將以下企業邏輯部分再透過 Entity Class 來提供所有 Service
	    
	    
	    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));   
	    String report = aaTool.getStr(request.getParameter("report_qry"));
	    
	 
	 
	    //保稅成品帳累計部分利用子報表， 因效能差寫在作業IIBAI

	    
		long startTime = System.currentTimeMillis();
  
		 
		new agjcB09Core(dsCom, con).qryDatas_P(endDate);
		 
	    
		long endTime = System.currentTimeMillis();
		System.out.println("執行秒數" + (endTime - startTime)/1000);
		
		
		
		de301.commit();
	}catch (Exception ex) {
		de301.rollback(); 
		
		StackTraceElement[] st = ex.getStackTrace();
		StringBuffer errorMsg = new StringBuffer("");
		errorMsg.append("**********************\n");
		for(int i =1; i < st.length; i++){
			errorMsg.append("\t" + st[i] + "\n");
		}
		result = ex + "\t\n" + errorMsg.toString();
	}finally {
		de301.close() ;
		de301 = null;
	}
	
	return result;
}
%>


<%! 
public String action2(dsjccom dsCom, HttpServletRequest request)throws Exception{ 
	String result = "";
	dejc301 de301 = new dejc301() ;
	aajcYCATool aaTool = new aajcYCATool();	
	
	try {
	    //建立連線
		Connection con = de301.getConnection(dsCom, "TSET") ;
		// 交易開始
		de301.setAutoCommit(false);
		// <coding>  的邏輯
		// 建議方針：可將以下企業邏輯部分再透過 Entity Class 來提供所有 Service

	    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));   
	    String report = aaTool.getStr(request.getParameter("report_qry"));
	    
	  
		long startTime = System.currentTimeMillis();
 
		new agjcB10Core(dsCom, con).qryDatas_P(endDate);
		 
	    
		long endTime = System.currentTimeMillis();
		System.out.println("執行秒數" + (endTime - startTime)/1000);
		
		
		
		de301.commit();
	}catch (Exception ex) {
		de301.rollback(); 
		
		StackTraceElement[] st = ex.getStackTrace();
		StringBuffer errorMsg = new StringBuffer("");
		errorMsg.append("**********************\n");
		for(int i =1; i < st.length; i++){
			errorMsg.append("\t" + st[i] + "\n");
		}
		result = ex + "\t\n" + errorMsg.toString();
	}finally {
		de301.close() ;
		de301 = null;
	}
	
	return result;
}
%>

<%!
private Map getBondYear(String acctPeriod,dsjccom dsCom) throws SQLException, Exception {
	dejcQueryDAO deDao = new dejcQueryDAO(dsCom);
	String sql = " SELECT FIELD2 AS BEGDATE, FIELD3 AS ENDDATE " +
				 " FROM DB.TBDE23 WHERE TABID ='BONDEDYEARP' " +
				 " AND FIELD2 <='"+acctPeriod+"01' AND FIELD3 >='"+acctPeriod+"01'  ";
	Map m = deDao.getData(sql);
	return m; 
}
%>

<%
String sessionId = request.getParameter("_sessionId") ;
StringBuffer rptUrl = new StringBuffer();
aajcYCATool aaTool = new aajcYCATool();
try{
	
	String action = aaTool.getStr(request.getParameter("_action")); 
    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));   
    String report = aaTool.getStr(request.getParameter("report_qry"));
  
    if(action.equals("P")){
    	action(_dsCom, request);
    }
    
    if(report.equals("G")){
    	action2(_dsCom, request);
    }
    
    
    //網域    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
	 
	
	if(report.equals("A")){
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025A");
	}else if(report.equals("B")){	
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025B");
	}else if(report.equals("C")){	
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025C");
	}else if(report.equals("D")){	
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025D");
	}else if(report.equals("E")){	
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025E");
	}else if(report.equals("F")){	
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025F");
	}else if(report.equals("G")){	
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025G");
	}else if(report.equals("H")){	
		rptUrl.append(domain + "F_42_RS_BONED/bqjj025H");
	}
	
	
	rptUrl.append("&rc:Stylesheet=myStyle");
	//本月期末，改抓下月期初，因為科目借貸方不同，不好計算
    rptUrl.append("&endDate=" + endDate.substring(0, 6));
    rptUrl.append("&endDateD=" + endDate);
	
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
