/*----------------------------------------------------------------------------*/
/* vcGen Ver 6.1010
/*----------------------------------------------------------------------------*/
/* author : YC13
/* system : IL
/* target : 採購退貨資料處理邏輯
/* create : 2009.01.01
/* update : XXXX.XX.XX
/*----------------------------------------------------------------------------*/
package com.icsc.bq.core;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
//import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
import com.icsc.aa.yc.dao.aajcYCADAO;
import com.icsc.aa.yc.util.aajcYCATool;
import com.icsc.dpms.de.dejc308;
import com.icsc.dpms.de.dejc318;
import com.icsc.dpms.de.dejcQueryDAO;
import com.icsc.dpms.ds.dsjccom;


public class bqjc042105{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjc042105.java,v 1.1 2026/07/01 05:39:51 02587 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc042105(dsjccom dsCom) {
    	super();
        this.dsCom = dsCom;
        de318 = new dejc318(this.dsCom, PROCID);
    }
/*
 * =========================================================================================
 * Public Method
 * =========================================================================================
 */
	
	
	/**
     * 查詢tab溪州 整理成畫面需要的資料
     */
	public Map gettab105DataFromDB(dsjccom dsCom,Connection conCIC,String endDate, String domDate) throws Exception {
	    

	    Map result = new HashMap();
	    aajcYCATool aaTool = new aajcYCATool();
	    dejcQueryDAO dao = new dejcQueryDAO(dsCom, conCIC);
	    String yearmonth =domDate.substring(0, 6);

	    // 製造細項
	    
	    StringBuilder sql = new StringBuilder();
	    
	    sql.append(" SELECT ")
		    .append("     SUM(CASE WHEN B.TABID IS NOT NULL THEN A.成材重量 ELSE 0 END) / 1000.0 AS 光退產量, ")
	        .append("     CAST(SUM(A.原料重量 - A.餘退重量 - A.接頭重量 - A.原料不良重量 - A.廢管重量) * 100.0 / NULLIF(SUM(A.原料重量 - A.餘退重量), 0) AS DECIMAL(18,2)) AS 當月成材率, ")
	        .append("     SUM(A.廢管重量 / 1000.0) AS 廢管重量, ")
	        .append("     SUM(A.成材重量 / 1000.0) AS 當月產量, ")
	        .append("     CAST(SUM(A.良品重量) * 100.0 / NULLIF(SUM(A.原料重量), 0) AS DECIMAL(18,2)) AS 良品率 ")
	        .append(" FROM dbo.IPQ111_製造日報 A ") 
	        .append(" LEFT JOIN dbo.tbde23 B ON A.表面 = B.FIELD1 AND B.TABID = 'TCMILLBRILLIANT' ")
	        .append(" WHERE 廠區名稱 = '105' ")
	        .append("   AND 完工日期 >= '" + domDate + "' ")
	        .append("   AND 完工日期 <= '" + endDate + "' ");
	    de318.logs("製造細項", sql.toString());
	    Map PQ = dao.getData(sql.toString());
	    result.putAll(PQ);
	    java.math.BigDecimal monthlyVol = aaTool.getBigDecimal(result.get("當月產量"));
	    result.put("當月產量",   aaTool.getBigDecimal(result.get("當月產量")).setScale(0, BigDecimal.ROUND_HALF_UP));
	    result.put("光退產量", aaTool.format(aaTool.getBigDecimal(result.get("光退產量")).setScale(1, java.math.BigDecimal.ROUND_HALF_UP), "#,##0.#"));
	    result.put("當月成材率",  aaTool.getBigDecimal(result.get("當月成材率")).setScale(2, BigDecimal.ROUND_HALF_UP));	  
	    result.put("光退占產量",  monthlyVol == null || monthlyVol.compareTo(java.math.BigDecimal.ZERO) == 0 ? "0" : aaTool.format(aaTool.getBigDecimal(result.get("光退產量")).multiply(new java.math.BigDecimal(100)).divide(monthlyVol, 1, java.math.BigDecimal.ROUND_HALF_UP), "#,##0.#"));
	    sql.setLength(0);		    
	    // 加工細項(酸洗)
	     sql.append(" SELECT ")
	     .append("    (SELECT SUM(良品重) / 1000.0 ")
	     .append("     FROM dbo.IPQ121_加工日報 ")
	     .append("     WHERE 廠區名稱 = '105' ")
	     .append("       AND 完工日期 >= '" + domDate + "' ")
	     .append("       AND 完工日期 <= '" + endDate + "'  ")
	     .append("       AND 重工=''  ")
	     .append("       AND 加工站 IN ('PW01','PW02')) AS 自動酸洗, ")
	     .append("    (SELECT SUM(ISNULL([酸洗OK重量], 0)) / 1000.0 ")
	     .append("     FROM dbo.[IPQ111_製造日報]  ")
	     .append("     WHERE 廠區名稱 = '105' ")
	     .append("       AND 完工日期 >= '" + domDate + "' ")
	     .append("       AND 完工日期 <= '" + endDate + "') AS 線上酸洗 ");
	     de318.logs("製造細項", sql.toString());
	     dao = new dejcQueryDAO(dsCom, conCIC);
		 Map pickling =  dao.getData(sql.toString());
		 result.putAll(pickling);
		 result.put("線上酸洗",   aaTool.getBigDecimal(result.get("線上酸洗")).setScale(0, BigDecimal.ROUND_HALF_UP));
		 result.put("自動酸洗",   aaTool.getBigDecimal(result.get("自動酸洗")).setScale(0, BigDecimal.ROUND_HALF_UP));
		 BigDecimal onlinePickling = aaTool.getBigDecimal(result.get("線上酸洗"));
		 BigDecimal autoPickling   = aaTool.getBigDecimal(result.get("自動酸洗"));
		 BigDecimal totalPickling  = onlinePickling.add(autoPickling);
		 result.put("酸洗總量", totalPickling.setScale(0, BigDecimal.ROUND_HALF_UP));
					 
		 
	    sql.setLength(0);
	    // 人力
	    sql.append(" SELECT ")
	       .append("     SUM(CASE WHEN 分類 = '廠務'   AND empno LIKE '%B%' THEN 1 ELSE 0 END) AS 廠務台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '廠務'   AND empno LIKE '%C%'     THEN 1 ELSE 0 END) AS 廠務土籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '生管成品' AND empno  LIKE '%B%' THEN 1 ELSE 0 END) AS 生管成品台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '生管成品' AND empno LIKE '%C%'     THEN 1 ELSE 0 END) AS 生管成品土籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '製造'   AND empno  LIKE '%B%' THEN 1 ELSE 0 END) AS 製造台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '製造'   AND empno LIKE '%C%'     THEN 1 ELSE 0 END) AS 製造土籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '加工'   AND empno  LIKE '%B%' THEN 1 ELSE 0 END) AS 加工台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '加工'   AND empno LIKE '%C%'     THEN 1 ELSE 0 END) AS 加工土籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '設備'   AND empno  LIKE '%B%' THEN 1 ELSE 0 END) AS 設備台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '設備'   AND empno LIKE '%C%'     THEN 1 ELSE 0 END) AS 設備土籍人數, ")
	       .append("     SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備','行政') AND empno LIKE '%B%' THEN 1 ELSE 0 END) AS 其他台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備','行政') AND empno LIKE '%C%'     THEN 1 ELSE 0 END) AS 其他土籍人數 ")
	       .append(" FROM dbo.H01_人力結構 ")
	       .append(" WHERE 服務 = '在職' AND 廠別 = '105'; ");
	    de318.logs("人力結構", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map HUM = dao.getData(sql.toString());
	    if (HUM != null) {
	    	 java.math.BigDecimal mTaiwan  = aaTool.getBigDecimal(HUM.get("製造台籍人數"));
		        java.math.BigDecimal mForeign = aaTool.getBigDecimal(HUM.get("製造土籍人數"));
		        java.math.BigDecimal pTaiwan  = aaTool.getBigDecimal(HUM.get("加工台籍人數"));
		        java.math.BigDecimal pForeign = aaTool.getBigDecimal(HUM.get("加工土籍人數"));
		        java.math.BigDecimal mbTaiwan  = aaTool.getBigDecimal(HUM.get("廠務台籍人數"));
		        java.math.BigDecimal mbForeign = aaTool.getBigDecimal(HUM.get("廠務土籍人數"));
		        java.math.BigDecimal eTaiwan  = aaTool.getBigDecimal(HUM.get("生管成品台籍人數"));
		        java.math.BigDecimal eForeign = aaTool.getBigDecimal(HUM.get("生管成品土籍人數"));
		        java.math.BigDecimal m41Taiwan  = aaTool.getBigDecimal(HUM.get("設備台籍人數"));
		        java.math.BigDecimal m41Foreign = aaTool.getBigDecimal(HUM.get("設備土籍人數"));
		        java.math.BigDecimal elseTaiwan  = aaTool.getBigDecimal(HUM.get("其他台籍人數"));
		        java.math.BigDecimal elseForeign = aaTool.getBigDecimal(HUM.get("其他土籍人數"));
		        
		        java.math.BigDecimal mTotal   = mTaiwan.add(mForeign);
		        java.math.BigDecimal pTotal   = pTaiwan.add(pForeign);
		        java.math.BigDecimal mbTotal   = mbTaiwan.add(mbForeign);
		        java.math.BigDecimal eTotal   = eTaiwan.add(eForeign);
		        java.math.BigDecimal m41Total   = m41Taiwan.add(m41Foreign);
		        java.math.BigDecimal elseTotal   = elseTaiwan.add(elseForeign);

		        HUM.put("製造總人數", mTotal);
		        HUM.put("加工總人數", pTotal);
		        HUM.put("廠務總人數", mbTotal);
		        HUM.put("生管成品總人數", eTotal);
		        HUM.put("設備總人數", m41Total);
		        HUM.put("其他總人數", elseTotal);
		        HUM.put("全廠總人數", mTotal.add(pTotal).add(mbTotal).add(eTotal).add(m41Total).add(elseTotal));
		        HUM.put("台籍總人數", mTaiwan.add(pTaiwan).add(mbTaiwan).add(eTaiwan).add(m41Taiwan).add(elseTaiwan));
		        HUM.put("土籍總人數", mForeign.add(pForeign).add(mbForeign).add(eForeign).add(m41Foreign).add(elseForeign));
	    }
	    result.putAll(HUM);
	    
	    sql.setLength(0);
	    // 日產量 Top5
	    sql.append(" SELECT TOP 5 ")
	       .append("     CONVERT(VARCHAR(10), CAST(完工日期 AS DATE), 120) AS 完工日期, ")
	       .append("     SUM(成材重量) AS 每日成材重量, ")
	       .append("     DENSE_RANK() OVER (ORDER BY SUM(成材重量) DESC) AS 產量名次 ")
	       .append(" FROM dbo.IPQ111_製造日報 ")
	       .append(" WHERE 廠區名稱 = '105' ")
	       .append("   AND 完工日期 >= '" + domDate + "'  ")
	       .append("  AND 完工日期 <= '" + endDate + "' ")
	       .append(" GROUP BY 完工日期 ")
	       .append(" ORDER BY 每日成材重量 DESC ");
	    de318.logs("日產量", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] product = dao.getDatas(sql.toString());
	    result.put("日產量", java.util.Arrays.asList(product));

	    sql.setLength(0);
	    // 廢重機台 Top5
	    sql.append(" SELECT  機台, SUM(廢管重量) AS 廢管 ")
	       .append(" FROM dbo.IPQ111_製造日報 ")
	       .append(" WHERE 廠區名稱 = '105' ")
	       .append("   AND 完工日期 >= '" + domDate + "' ")
	       .append("   AND 完工日期 <= '" + endDate + "' ")
	       .append(" GROUP BY 機台 ORDER BY SUM(廢管重量) DESC ");
	    de318.logs("廢重機台", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] disuse1 = dao.getDatas(sql.toString());
	    result.put("廢重機台", java.util.Arrays.asList(disuse1));

	    sql.setLength(0);
	    // 機故時數 Top5
	    sql.append(" SELECT  機台, ")
	       .append("     (SUM(ISNULL(磨故,0)) + SUM(ISNULL(機故,0)) + SUM(ISNULL(焊故,0))) AS 機故時間 ")
	       .append(" FROM dbo.IPQ116 ")
	       .append(" WHERE 廠區名稱 = '105' ")
	       .append("   AND 年月 >= CONVERT(VARCHAR(6), GETDATE(), 112) ")
	       .append("   AND 年月 <= CONVERT(VARCHAR(8), GETDATE(), 112) ")
	       .append(" GROUP BY 機台 ORDER BY 機故時間 DESC ");
	    de318.logs("機故時數", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] failure = dao.getDatas(sql.toString());
	    result.put("機故時數",  java.util.Arrays.asList(failure));

	    sql.setLength(0);
	    //IWMPH1_機台停機 沒有TR
	    sql.append(" WITH PreparedData AS ( ")
	       .append("     SELECT ")
	       .append("         停機原因, ")
	       .append("         CAST(停機時間 AS DECIMAL(18,4)) AS 停機時間_DEC, ")
	       .append("         CASE WHEN 機台 LIKE 'DF%' OR 機台 LIKE 'DQ%' THEN 1 ")
	       .append("              WHEN 機台 = 'DW01' THEN 2 ")
	       .append("              ELSE 0 END AS 設備型態 ")
	       .append("     FROM dbo.IWMPH1_機台停機 WITH (NOLOCK) ")
	       .append("     WHERE 區域 = 'TW' ")
	       .append("       AND 停機原因 NOT IN (N'人員下班', N'計劃性停機', N'人員用餐') ")
	       .append("       AND 開始日期 >= '" + domDate + "' ")
	       .append("       AND 開始日期 <= CONVERT(VARCHAR(8), EOMONTH(GETDATE()), 112) ")
	       .append(" ) ")
	       .append(" SELECT ")
	       .append("     停機原因, ")
	       .append("     SUM(CASE WHEN 設備型態 = 1 THEN 停機時間_DEC ELSE 0 END) / 60.0 AS 製造_停機時間, ")
	       .append("     CAST(SUM(CASE WHEN 設備型態 = 1 THEN 停機時間_DEC ELSE 0 END) * 100.0 / ")
	       .append("          NULLIF(SUM(SUM(CASE WHEN 設備型態 = 1 THEN 停機時間_DEC ELSE 0 END)) OVER(), 0) AS DECIMAL(18,2)) AS 製造_佔比_百分比, ")
	       .append("     SUM(CASE WHEN 設備型態 = 2 THEN 停機時間_DEC ELSE 0 END) / 60.0 AS 加工_停機時間, ")
	       .append("     CAST(SUM(CASE WHEN 設備型態 = 2 THEN 停機時間_DEC ELSE 0 END) * 100.0 / ")
	       .append("          NULLIF(SUM(SUM(CASE WHEN 設備型態 = 2 THEN 停機時間_DEC ELSE 0 END)) OVER(), 0) AS DECIMAL(18,2)) AS 加工_佔比_百分比 ")
	       .append(" FROM PreparedData ")
	       .append(" WHERE 設備型態 IN (1, 2) ")
	       .append(" GROUP BY 停機原因 ")
	       .append(" HAVING SUM(CASE WHEN 設備型態 = 1 THEN 停機時間_DEC ELSE 0 END) > 0 ")
	       .append("     OR SUM(CASE WHEN 設備型態 = 2 THEN 停機時間_DEC ELSE 0 END) > 0 ");

	    de318.logs("設備停機合併查詢", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] allDowntime = dao.getDatas(sql.toString());

	    java.util.List<Map> makeList = java.util.Arrays.stream(allDowntime)
	        .filter(m -> m.get("製造_停機時間") != null && Double.parseDouble(m.get("製造_停機時間").toString()) > 0)
	        .map(m -> {
	            Map<String, Object> newMap = new java.util.HashMap<>();
	            newMap.put("停機原因", m.get("停機原因"));
	            newMap.put("停機時間", m.get("製造_停機時間"));
	            newMap.put("佔比_百分比", m.get("製造_佔比_百分比"));
	            return newMap;
	        })
	        .sorted((m1, m2) -> Double.compare(Double.parseDouble(m2.get("停機時間").toString()), Double.parseDouble(m1.get("停機時間").toString())))
	        .collect(java.util.stream.Collectors.toList());

	    java.util.List<Map> processList = java.util.Arrays.stream(allDowntime)
	        .filter(m -> m.get("加工_停機時間") != null && Double.parseDouble(m.get("加工_停機時間").toString()) > 0)
	        .filter(m -> !"人員用餐".equals(m.get("停機原因")))
	        .map(m -> {
	            Map<String, Object> newMap = new java.util.HashMap<>();
	            newMap.put("停機原因", m.get("停機原因"));
	            newMap.put("停機時間", m.get("加工_停機時間"));
	            newMap.put("佔比_百分比", m.get("加工_佔比_百分比"));
	            return newMap;
	        })
	        .sorted((m1, m2) -> Double.compare(Double.parseDouble(m2.get("停機時間").toString()), Double.parseDouble(m1.get("停機時間").toString())))
	        .collect(java.util.stream.Collectors.toList());

	    result.put("製造停機", makeList);
	    //result.put("加工停機", processList);

	    sql.setLength(0);
	    //待加工 酸洗
	    sql.append(" SELECT  ")
	       .append(" CONVERT(DATETIME, CAST([日期] AS VARCHAR(8)), 112) AS [time], ")
	       .append(" '酸洗' AS [metric],  ")
	       .append(" SUM([重量] / 1000.0) AS [value]  ")
	       .append(" FROM dbo.[IPQ123_加工未完]   ")
	       .append(" WHERE [廠區名稱] = '105' ")	       
	       .append(" AND [站別名稱] IN ('酸洗', 'Pickling') ")
	       .append(" AND [日期] >= CONVERT(VARCHAR(8), DATEADD(DAY, -31, GETDATE()), 112)  ")
	       .append(" AND [日期] <= CONVERT(VARCHAR(8), GETDATE(), 112) ")
	       .append(" GROUP BY [日期]  ORDER BY  [日期] ASC;  ");
	    de318.logs("加工待處理SQL", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] waitprocessing = dao.getDatas(sql.toString());
	    result.put("待加工", java.util.Arrays.asList(waitprocessing));
	    
	    sql.setLength(0);
	    //總庫存
	    sql.append(" SELECT  ")
	       .append(" A.年月,A.斗二總庫存, A.斗二大原料鋼捲, A.斗二成品鋼板捲, A.斗二管料, A.斗二次級, B.斗二配管, B.斗二構造管, B.斗二扁鐵, B.斗二角鐵, B.斗二無縫管 ")
	       .append(" FROM V_IPQ7R4_原料存貨分析_廠區 A  ")
	       .append(" INNER JOIN V_IPQ7R4_鋼管存貨分析_廠區 B  ")
	       .append(" ON A.年月 = B.年月   ")
	       .append(" WHERE A.年月 = LEFT('" + endDate + "', 6); ");

	    de318.logs("總庫存SQL", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map stock = dao.getData(sql.toString());
	    result.putAll(stock);	
	    result.put("斗二大原料鋼捲",   aaTool.getBigDecimal(result.get("斗二大原料鋼捲")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二成品鋼板捲",   aaTool.getBigDecimal(result.get("斗二成品鋼板捲")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二管料",   aaTool.getBigDecimal(result.get("斗二管料")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二扁鐵",   aaTool.getBigDecimal(result.get("斗二扁鐵")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二次級",   aaTool.getBigDecimal(result.get("斗二次級")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二構造管",   aaTool.getBigDecimal(result.get("斗二構造管")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二配管",   aaTool.getBigDecimal(result.get("斗二配管")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二角鐵",   aaTool.getBigDecimal(result.get("斗二角鐵")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("斗二無縫管",   aaTool.getBigDecimal(result.get("斗二無縫管")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    BigDecimal totalStock = aaTool.getBigDecimal(result.get("斗二總庫存"))  // 原本的總庫存（大原料）
	    	    .add(aaTool.getBigDecimal(result.get("斗二州次級")))
	    	    .add(aaTool.getBigDecimal(result.get("斗二配管")))
	    	    .add(aaTool.getBigDecimal(result.get("斗二構造管")))
	    	    .add(aaTool.getBigDecimal(result.get("斗二扁鐵")))
	    	    .add(aaTool.getBigDecimal(result.get("斗二角鐵")))
	    	    
	    	    .add(aaTool.getBigDecimal(result.get("斗二無縫管")));
	    result.put("斗二總庫存", totalStock.setScale(0, BigDecimal.ROUND_HALF_UP));
	    
	    sql.setLength(0);
	    //目標產量
	    sql.append(" SELECT * FROM dbo.tbde23 WHERE TABID='PIPEPRODTARGET' and FIELD1 = '"+ yearmonth +"'  ");
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map target = dao.getData(sql.toString());	   
	    if (target != null && !target.isEmpty()) {	       
	        result.putAll(target);      
	        result.put("目標產量", aaTool.getBigDecimal(result.get("FIELD2")).setScale(0, BigDecimal.ROUND_HALF_UP));
	        result.put("目標酸洗總量", aaTool.getBigDecimal(result.get("FIELD3")).setScale(0, BigDecimal.ROUND_HALF_UP));
	    } else {	      
	        result.put("目標產量", BigDecimal.ZERO);
	        result.put("目標酸洗總量", BigDecimal.ZERO);	     
	    }
	    return result;
	}

    public Map getDashboardData105(dsjccom dsCom, HttpServletRequest request) throws SQLException, Exception {
    	Connection conCIC = null;
    	try {
	    	Map result = new HashMap();
	    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
		    String endDate = aaTool.getStr(request.getParameter("updateDate")).replaceAll("/","");  	
		    if("".equals(endDate))
		    	endDate = new dejc308().getCrntDateWFmt1();
		    
		    String dateYM = aaTool.getWYearMonth(endDate);
			String domDate = dateYM + "01";
			
		
			
			de318.logs("日期", "orderDate="+endDate+",domDate="+domDate);
			
			bqjcGetConnectionCIC bqGetCon = new bqjcGetConnectionCIC(dsCom);
	        conCIC = bqGetCon.getSQLServerConnection();
	        
		    result.put("updateDate",endDate);
		    result.put("105Data",this.gettab105DataFromDB(dsCom,conCIC, endDate, domDate));
	
		    return result;
		    
    	} catch (Exception e) {
            throw e;
        } finally {
            if (conCIC != null) {
                try { conCIC.close(); } catch (Exception e) {}
            }
            conCIC = null;
        }
	}

}
