<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.dejcQueryDAO"%>
<%@ page import="java.util.*" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool"%>
<%! public static final String _AppId = "BQJJ026"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<%

	aajcYCATool aaTool = new aajcYCATool();
	//pqjj026List.jsp的簡化版
	String sessionId = request.getParameter("_sessionId") ;
	String action = request.getParameter("_action");
	//查詢條件
	String locA = aaTool.getStr(request.getParameter("LOCA")).equals("")?"D" : aaTool.getStr(request.getParameter("LOCA"));
	String locName = "";
	request.setAttribute("locA", locA);
	request.setAttribute("locName", locName);
	
	//查詢條件
	//查出棟
	Map[] Blocks = getBlock(_dsCom, request);
	
	//查出儲區的位置以及庫存數量
	Map locXY = new HashMap();
	Map[] locXYs = getPipeLocXY(_dsCom, request);	
	for (int i = 0; i < locXYs.length; i++) {
		Map row = locXYs[i];
		String key = aaTool.getStr(row.get("ID"));				//棟
		locXY.put(key, row);
	}
	
	//查出庫存
	Map[] raw = new Map[0];
	if("D".equals(locA))
		raw = getPipe(_dsCom, request);
	else
		raw = getCoil(_dsCom, request);
	
	//組合大MAP，以便顯示--給script用
	Map ihx = new HashMap();
	for (int i = 0; i < raw.length; i++) {
		Map row = raw[i];
		String key = aaTool.getStr(row.get("LOCY"));				//該位置上的內容
 		String key2 = aaTool.getStr(row.get("LOC"));  //料架
		// ihx--依據位置抓庫存，沒庫存就跳過
 		Map locMap = (Map)ihx.get(key);//LOCY ihx map裡面再包一層 LOC料架map
		if(locMap == null){
			locMap = new HashMap();
			ihx.put(key,locMap);
		}
 		List stockList = (List) locMap.get(key2);
		if (stockList == null) {
			stockList = new ArrayList();
			locMap.put(key2, stockList);
		}
		if(row.get("ID") != null){
			stockList.add(row);	 
		}
	}

	//放入 request 中，供後面模板使用
	request.setAttribute("Blocks", Blocks);
	request.setAttribute("locXY", locXY);
	request.setAttribute("ihx", ihx);
%>

<%if(false){ %>
	<%="Blocks" + Blocks %>
	<br>
	<%="locXY" + locXY %>
	<br>
<%}%>
	<jsp:include page="../../bq/jsp/bqjj027List_01.jsp" />
	
<%! 
//取得所有的棟
public Map[] getBlock(dsjccom dsCom, HttpServletRequest request) {
	try {
		aajcYCATool aaTool = new aajcYCATool();

		//查詢條件
		String locA = aaTool.getStr(request.getParameter("locA"));
		//TEST
		locA = aaTool.getStr(request.getAttribute("locA"));
		
		StringBuffer sqlB = new StringBuffer("SELECT DISTINCT a.LOCNAME AS BLOCK FROM DB.TBIGFB12 a WHERE a.COMPID='yc' ");
		sqlB = aaTool.sqlStrFieldExpEmp("a.STOCKID", locA, sqlB);
		sqlB.append(" ORDER BY a.LOCNAME WITH UR");
		System.out.println("B:" + sqlB.toString());

		return new dejcQueryDAO(dsCom).getDatas(sqlB.toString());
	} catch (Exception ex) {
		ex.printStackTrace();
	}
	return new Map[0];
}
%>


<%! 
//取得儲區中的庫存
public Map[] getCoil(dsjccom dsCom, HttpServletRequest request) {
	try {
		aajcYCATool aaTool = new aajcYCATool();

		//查詢條件
		String locA = aaTool.getStr(request.getParameter("locA"));
		String locB = aaTool.getStr(request.getParameter("locB"));
		String locC = aaTool.getStr(request.getParameter("locC"));
		String locD = aaTool.getStr(request.getParameter("locX"));
		String locName = aaTool.getStr(request.getParameter("locName"));
		//TEST
		locA = aaTool.getStr(request.getAttribute("locA"));
		locName = aaTool.getStr(request.getAttribute("locName"));

		StringBuffer sql = new StringBuffer(
			" SELECT                                                                                         " +
			" 	DISTINCT a.LOC2F AS BLOCK, SUBSTR(a.LOC3F,1,2) AS X, SUBSTR(a.LOC3F,3,2) AS Y,               " +
			" 	b.*                                                                                          " +
			" FROM db.tbigfB11 a                                                                             " +
			" LEFT JOIN (                                                                                    " +
			" 	SELECT a.LOCC || a.LOCX AS LOC, a.ID, b.INSTOCKWGT AS WGT                                    " +
			" 	    , c.QLTY, c.SURFCODE, c.THICK, c.WIDTH                                                   " +
			" 	FROM db.tbihsA001 a                                                                          " +
			" 	JOIN db.tbihsB011 b ON a.ID = b.ID                                                           " +
			" 	JOIN db.tbihsA003 c ON a.ID = c.ID                                                           " +
			" 	WHERE a.COMPID = 'yc' AND b.STTS IN ('A', 'C') AND b.GOODSTYPE1 IN ('R', 'G', 'W')           " +
			" 	AND b.INSTOCKQTY > 0                                                                         " +
			" 	AND a.LOCA = '" + locA + "'                                                                  " +
			" 	ORDER BY A.ID                                                                                " +
			" ) b ON LOC=a.LOC2F||a.LOC3F                                                                    " +
			" WHERE a.COMPID='yc' AND a.LOC3F<>''                                                            ");
			sql = aaTool.sqlStrFieldExpEmp("a.STOCKID", locA, sql);
			if("D".equals(locA) && "成品倉".equals(locName))
				sql = aaTool.sqlStrFieldExpEmp("a.LOCLAYER", "4", sql);			
			else
				sql = aaTool.sqlStrFieldExpEmp("a.LOCNAME", locName, sql);	

		System.out.println("COIL:" + sql.toString());
		return new dejcQueryDAO(dsCom).getDatas(sql.toString());
	} catch (Exception ex) {
		ex.printStackTrace();
	}
	return new Map[0];
}
%>

<%! 
//取得儲區中的庫存
public Map[] getPipeLocXY(dsjccom dsCom, HttpServletRequest request) {
	try {
		aajcYCATool aaTool = new aajcYCATool();

		//查詢條件
		String locA = aaTool.getStr(request.getParameter("locA"));
		//TEST
		locA = aaTool.getStr(request.getAttribute("locA")); 
		
		StringBuffer sql = new StringBuffer(
			"SELECT " +
		    "    a.LOCNAME AS BLOCK, a.LOCNO AS ID, a.LEFT, a.TOP, a.WIDTH, a.HEIGHT," +
		    "    count(DISTINCT b.LOC) AS QTY " +
		    " FROM db.TBIGFB12 a " +
		    " LEFT JOIN ( " +
		    "    SELECT " +
		    "        a.LOCA||'-'||a.LOCB||'-'||a.LOCC||'-'||a.LOCX AS LOC, a.LOCY,  " +
		    "        a.ID, sum(b.INSTOCKWGT) AS WGT " +
		    "    FROM db.tbihpA001 a " +
		    "    JOIN db.tbihpB011 b ON a.ID=b.ID " +
		    "    WHERE a.COMPID='yc' AND b.STTS IN ('A','B','C','D','E','F') AND b.GOODSTYPE1 IN ('P','I','G') AND b.INSTOCKQTY>0 " +
		    "    AND a.LOCA='" + locA + "' AND a.LOCY<>'' " +
		    "    GROUP BY a.LOCA, a.LOCB, a.LOCC, a.LOCX, a.LOCY, a.ID " +
		    "  UNION ALL " +
			"    SELECT " +
			"        a.LOCA||'-'||a.LOCB||'-'||a.LOCC||'-'||a.LOCX AS LOC, a.LOCY,  " +
			"        b.BOXID AS ID, sum(b.WGT) AS WGT " +
			"    FROM db.tbihpB020 a " +
			"    JOIN db.tbihpB021 b ON a.BOXID=b.BOXID " +
			"    WHERE a.COMPID='yc' AND a.STATUS<'40' AND b.QTY>0 " +
			"    AND a.LOCA='" + locA + "' AND a.LOCY<>'' " +
			"    GROUP BY a.LOCA, a.LOCB, a.LOCC, a.LOCX, a.LOCY, b.BOXID " +
		    " ) b ON a.LOCNO = b.LOCY " +
		    " WHERE a.COMPID = 'yc' ");
		sql = aaTool.sqlStrFieldExpEmp("a.STOCKID", locA, sql);
		sql.append(" GROUP BY a.LOCNAME  , a.LOCNO, a.LEFT, a.TOP, a.WIDTH, a.HEIGHT WITH UR"); 
		
		//System.out.println("PIPELOCXY:" + sql.toString());
		return new dejcQueryDAO(dsCom).getDatas(sql.toString());
	} catch (Exception ex) {
		ex.printStackTrace();
	}
	return new Map[0];
}


public Map[] getPipe(dsjccom dsCom, HttpServletRequest request) {
	try {
		aajcYCATool aaTool = new aajcYCATool();

		//查詢條件
		String locA = aaTool.getStr(request.getParameter("locA"));
		//TEST
		locA = aaTool.getStr(request.getAttribute("locA")); 
		
		StringBuffer sql = new StringBuffer(
			"SELECT " +
		    "    DISTINCT a.LOCNAME AS BLOCK, " +
		    "    b. * " +
		    " FROM db.TBIGFB12 a " +
		    " LEFT JOIN ( " +
		    "    SELECT " +
		    "        a.LOCA||'-'||a.LOCB||'-'||a.LOCC||'-'||a.LOCX AS LOC, a.LOCY,  " +
		    "        a.ID, sum(b.INSTOCKWGT) AS WGT " +
		    "    FROM db.tbihpA001 a " +
		    "    JOIN db.tbihpB011 b ON a.ID=b.ID " +
		    "    WHERE a.COMPID='yc' AND b.STTS IN ('A','B','C','D','E','F') AND b.GOODSTYPE1 IN ('P','I','G') AND b.INSTOCKQTY>0 " +
		    "    AND a.LOCA='" + locA + "' AND a.LOCY<>'' " +
		    "    GROUP BY a.LOCA, a.LOCB, a.LOCC, a.LOCX, a.LOCY, a.ID " +
		    "  UNION ALL " +
			"    SELECT " +
			"        a.LOCA||'-'||a.LOCB||'-'||a.LOCC||'-'||a.LOCX AS LOC, a.LOCY,  " +
			"        b.BOXID AS ID, sum(b.WGT) AS WGT " +
			"    FROM db.tbihpB020 a " +
			"    JOIN db.tbihpB021 b ON a.BOXID=b.BOXID " +
			"    WHERE a.COMPID='yc' AND a.STATUS<'40' AND b.QTY>0 " +
			"    AND a.LOCA='" + locA + "' AND a.LOCY<>'' " +
			"    GROUP BY a.LOCA, a.LOCB, a.LOCC, a.LOCX, a.LOCY, b.BOXID " +
		    " ) b ON a.LOCNO = b.LOCY " +
		    " WHERE a.COMPID = 'yc' ");
		sql = aaTool.sqlStrFieldExpEmp("a.STOCKID", locA, sql);

		System.out.println("PIPE:" + sql.toString());
		return new dejcQueryDAO(dsCom).getDatas(sql.toString());
	} catch (Exception ex) {
		ex.printStackTrace();
	}
	return new Map[0];
}
%>
</body>
</html>
