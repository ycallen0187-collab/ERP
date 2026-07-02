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
	//String locA = aaTool.getStr(request.getParameter("locA"));
	//String locB = aaTool.getStr(request.getParameter("locB"));
	//String locC = aaTool.getStr(request.getParameter("locC"));
	//String locD = aaTool.getStr(request.getParameter("locX"));
	//String locName = aaTool.getStr(request.getParameter("locName"));
	
	//測試用
	//request.setAttribute("locA", "D");
	//request.setAttribute("locName", "原料區");
	//request.setAttribute("locName", "成品倉");
	//locA = aaTool.getStr(request.getAttribute("locA"));
	//locName = aaTool.getStr(request.getAttribute("locName"));
	
	String locA = aaTool.getStr(request.getParameter("LOCA")).equals("")?"D" : aaTool.getStr(request.getParameter("LOCA"));
	String locName = aaTool.getStr(request.getParameter("LOCNAME")).equals("")?"原料區" : aaTool.getStr(request.getParameter("LOCNAME"));
	request.setAttribute("locA", locA);
	request.setAttribute("locName", locName);
	
	//查詢條件
	//查出棟
	Map[] Blocks = getBlock(_dsCom, request);
	
	//查出庫存
	Map[] raw = new Map[0];
	if("D".equals(locA) && "成品倉".equals(locName))
		raw = getPipe(_dsCom, request);
	else
		raw = getCoil(_dsCom, request);
	
	//組合大MAP，以便顯示--給script用
	Map ihx = new HashMap();
	Map locXSize = new HashMap();				
	Map locYSize = new HashMap();
	Map locZSize = new HashMap();
	Map stockNum = new HashMap();
	for (int i = 0; i < raw.length; i++) {
		Map row = raw[i];
		String block = aaTool.getStr(row.get("BLOCK"));				//棟
		String x = aaTool.getStr(row.get("X"));						//畫面上的X軸
		String y = aaTool.getStr(row.get("Y"));						//畫面上的Y軸
		String z = aaTool.getStr(row.get("Z"));						//畫面上的Y軸--斗二要依據區塊再細分，沒有區塊的，這個欄位會是空白的
		String blockZ = block;										//Zone的不能合再一起
		block = block + z;											//其餘屬性要依據Zone計算
		String key = block + x + y;									//該位置上的內容

		// X 軸
		List xList = (List) locXSize.get(block);
		if (xList == null) {
			xList = new ArrayList();
			locXSize.put(block, xList);
		}
		if (!xList.contains(x)) xList.add(x);

		// Y 軸
		List yList = (List) locYSize.get(block);
		if (yList == null) {
			yList = new ArrayList();
			locYSize.put(block, yList);
		}
		if (!yList.contains(y)) yList.add(y);

		// Z 軸
		List zList = (List) locZSize.get(blockZ);
		if (zList == null) {
			zList = new ArrayList();
			locZSize.put(blockZ, zList);
		}
		if (!zList.contains(z)) zList.add(z);
		
		// ihx--依據位置抓庫存，沒庫存就跳過
		List stockList = (List) ihx.get(key);
		if (stockList == null) {
			stockList = new ArrayList();
			ihx.put(key, stockList);
		}
		if(row.get("ID") != null){
			stockList.add(row);	
		}
	}

	// 排序
	for (Iterator it = locXSize.keySet().iterator(); it.hasNext(); ) {
		String block = (String) it.next();
		Collections.sort((List) locXSize.get(block));
	}
	for (Iterator it = locYSize.keySet().iterator(); it.hasNext(); ) {
		String block = (String) it.next();
		Collections.sort((List) locYSize.get(block));
	}

	// 計算數量
	for (Iterator it = ihx.keySet().iterator(); it.hasNext(); ) {
		String key = (String) it.next();
		List list = (List) ihx.get(key);
		
		if("D".equals(locA) && "成品倉".equals(locName)){
			//計算料價數量
			Map t = aaTool.mapListToMap(list, "LOC");
			stockNum.put(key, "" + t.size());
		}else
			stockNum.put(key, "" + list.size());
	}
	
	//放入 request 中，供後面模板使用
	request.setAttribute("Blocks", Blocks);
	request.setAttribute("locXSize", locXSize);
	request.setAttribute("locYSize", locYSize);
	request.setAttribute("locZSize", locZSize);
	request.setAttribute("ihx", ihx);
	request.setAttribute("stockNum", stockNum);
%>
<%if(false){ %>
	<%="Blocks" + Blocks %>
	<br>
	<%="locXSize" + locXSize %>
	<br>
	<%="locYSize" + locYSize %>
	<br>
	<%="locZSize" + locZSize %>
	<br>
	<%="stockNum" + stockNum %>
	<br>
<%}%>

<%	if("D".equals(locA) && "成品倉".equals(locName)){ %>
斗2-成品倉
	<jsp:include page="../../bq/jsp/bqjj026List_02.jsp" />
<%}else{%>
原料倉
	<jsp:include page="../../bq/jsp/bqjj026List_01.jsp" />
<%}%>


<%! 
//取得所有的棟
public Map[] getBlock(dsjccom dsCom, HttpServletRequest request) {
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
		
		StringBuffer sqlB = new StringBuffer("SELECT DISTINCT a.LOC2F AS BLOCK FROM db.tbigfB11 a WHERE a.COMPID='yc' ");
		sqlB = aaTool.sqlStrFieldExpEmp("a.STOCKID", locA, sqlB);
		sqlB = aaTool.sqlStrFieldExpEmp("a.LOC1F", locB, sqlB);
		sqlB = aaTool.sqlStrFieldExpEmp("a.LOC2F", locC, sqlB);
		sqlB = aaTool.sqlStrFieldExpEmp("a.LOC3F", locD, sqlB);
		if("D".equals(locA) && "成品倉".equals(locName))
			sqlB = aaTool.sqlStrFieldExpEmp("a.LOCLAYER", "4", sqlB);			
		else
			sqlB = aaTool.sqlStrFieldExpEmp("a.LOCNAME", locName, sqlB);		
		sqlB.append(" ORDER BY a.LOC2F WITH UR");
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
public Map[] getPipe(dsjccom dsCom, HttpServletRequest request) {
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
			"SELECT " +
		    "    DISTINCT a.LOC2F AS BLOCK, a.LOC3F AS Z, SUBSTR (a.LOC4F, 1, 1) AS X, SUBSTR (a.LOC4F, 2, 1) AS Y, " +
		    "    b. * " +
		    " FROM db.tbigfB11 a " +
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
		    " WHERE a.COMPID = 'yc' AND a.LOC3F <> '' ");
		sql = aaTool.sqlStrFieldExpEmp("a.STOCKID", locA, sql);
		if("D".equals(locA) && "成品倉".equals(locName))
			sql = aaTool.sqlStrFieldExpEmp("a.LOCLAYER", "4", sql);			
		else
			sql = aaTool.sqlStrFieldExpEmp("a.LOCNAME", locName, sql);	

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
