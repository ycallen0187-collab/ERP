<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.ag.dao.agjcbdT1DAO"%>
<%@page import="com.icsc.ig.igf.util.igfcuGetMapValue"%>
<%! public static final String _AppId = "BQJJ006"; %>
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
	    String matNo = aaTool.getStr(request.getParameter("matNo_qry"));
	    String begDate = aaTool.getStr(request.getParameter("begDate_qry").replaceAll("/",""));
	    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));   
	    String isBoned = aaTool.getStr(request.getParameter("isBoned_qry"));
	    String report = aaTool.getStr(request.getParameter("report_qry"));
	    String purpCode =""; 
	    
	    if(isBoned.equals("Y")){
	    	purpCode =" 'B' ";
	    }else if(isBoned.equals("D")){
	    	purpCode =" 'D' ";
	    }else {
	    	purpCode =" 'B','D' ";
	    }
		
		long startTime = System.currentTimeMillis();
		new agjcbdT1DAO(dsCom, con).qryDatas_Y(matNo, begDate, endDate,purpCode);
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
				 " FROM DB.TBDE23 WHERE TABID ='BONDEDYEAR' " +
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
    String matNo = aaTool.getStr(request.getParameter("matNo_qry"));
    String begDate = aaTool.getStr(request.getParameter("begDate_qry").replaceAll("/",""));
    String endDate = aaTool.getStr(request.getParameter("endDate_qry").replaceAll("/",""));   
    String report = aaTool.getStr(request.getParameter("report_qry"));
    action(_dsCom, request);
    
    
	//取得保稅年度 (累計使用)
    
	Map bondYear= getBondYear(begDate,_dsCom);
	String bondeb_bDate = igfcuGetMapValue.getStringOrSpaceValue(bondYear,"BEGDATE");
	String bondeb_eDate = igfcuGetMapValue.getStringOrSpaceValue(bondYear,"ENDDATE");
    String purpCode = aaTool.getStr(request.getParameter("isBoned_qry"));
    
    if(purpCode.equals("Y")){
    	purpCode = " AND B.PURPCODE IN ('B') ";
    }else if(purpCode.equals("D")){
    	purpCode = " AND B.PURPCODE IN ('D') ";
    }else if(purpCode.equals("")){
    	purpCode = " AND B.PURPCODE IN ('B','D') ";
    }
	
    
    //網域    
	String domain = "http://bi/ReportServer/Pages/ReportViewer.aspx?/";
    
	Map rptRSUrl = new HashMap();
	rptRSUrl.put("A", "MP002/BQJJ002Y");
	rptRSUrl.put("B", "MP002/BQJJ002YG");
	rptUrl.append(domain + rptRSUrl.get(report));
    
    
	//rptUrl.append(domain + "MP002/BQJJ002Y");
	//本月期末，改抓下月期初，因為科目借貸方不同，不好計算
	
	rptUrl.append("&bondeb_bDate=" + bondeb_bDate);
	rptUrl.append("&endDate=" + endDate);
	rptUrl.append("&purpCode=" + purpCode);
	rptUrl.append("&begDate=" + begDate);
	rptUrl.append("&rc:Stylesheet=myStyle");
	//本月期末，改抓下月期初，因為科目借貸方不同，不好計算
    //rptUrl.append("&matNo=" + matNo);
	
	 
	
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
