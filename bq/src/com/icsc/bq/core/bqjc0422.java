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
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import com.icsc.aa.yc.dao.aajcYCADAO;
import com.icsc.aa.yc.util.aajcYCATool;
import com.icsc.dpms.de.dejc308;
import com.icsc.dpms.de.dejc318;
import com.icsc.dpms.ds.dsjccom;
import com.icsc.dpms.de.dejcQueryDAO;


public class bqjc0422{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjc0422.java,v 1.6 2026/06/25 02:28:11 02553 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc0422(dsjccom dsCom) {
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
     * 取得斗一廠 本月與上月的接單、出貨報表 <br>
     * DataBase:CIC <br>
     * Table/View:V_IPQ77_接單出貨彙整 
     */
    public Map getOrderAndShipment(Connection conCIC) throws Exception {
    		Map Result = new HashMap();
    		StringBuffer sql = new StringBuffer();
    		
            sql.append(" WITH MonthlyData AS ( ")
               .append("     SELECT  ")
               .append("         年月, ")
               .append("         外銷板捲接單重量, ")
               .append("         鋼板出貨目標, ")
               .append("         外銷確認重量, ")
               .append("         DENSE_RANK() OVER (ORDER BY 年月 DESC) as rank ")
               .append("     FROM dbo.[V_IPQ77_接單出貨彙整] ")
               .append("     WHERE 廠區 = 'C' ")
               .append(" ) ")
               .append(" SELECT  ")
               .append("     curr.年月 as 本月月份, ")
               .append("     curr.外銷板捲接單重量/1000 as 本月接單, ") 
               .append("     prev.外銷板捲接單重量/1000 as 上月接單, ")
               .append("     curr.鋼板出貨目標/1000 as 本月出貨目標, ")
               .append("     curr.外銷確認重量/1000 as 本月銷貨重量 ")
               .append(" FROM MonthlyData curr ")
               .append(" LEFT JOIN MonthlyData prev ON prev.rank = curr.rank + 1 ")
               .append(" WHERE curr.rank = 1 ");
            
            Map m = new dejcQueryDAO(dsCom, conCIC).getData(sql.toString());

            Result.put("本月月份", aaTool.getStr(m.get("本月月份")));
            Result.put("本月接單", aaTool.getBigDecimal(m.get("本月接單")));
            Result.put("上月接單", aaTool.getBigDecimal(m.get("上月接單")));
            Result.put("本月出貨目標", aaTool.getBigDecimal(m.get("本月出貨目標")));
            Result.put("本月銷貨重量", aaTool.getBigDecimal(m.get("本月銷貨重量")));
            
    		return Result;
    		
	}
    
    /**
     * 斗一廠 月生產量資料 <br>
     * DataBase:YCPROD 
     */
    public Map getMonthProduction(String dateYM) throws Exception {
		Map result = new HashMap();
    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
    	StringBuilder sql = new StringBuilder();
    	
    	sql.append("SELECT ROUND(SUM(CASE WHEN b.PRODUCETYPE LIKE 'C%' THEN 0 ELSE b.WGT END)/1000,0) AS PRODWGT ")
    	   .append("FROM db.tbwzsB030 a ")
    	   .append("JOIN db.tbwms020 b ON a.COMPID=b.COMPID AND a.MOID=b.MOID ")
    	   .append("JOIN db.tbwzsA010 c ON a.COMPID=c.COMPID AND a.MACHINEID=c.MACHINEID ")
    	   .append("WHERE a.COMPID='yc' AND a.ENDWORKDATE LIKE '"+dateYM+"%' AND b.OPERATESTATUS='C' ")
    	   .append("AND a.MACHINEID IN ('CC01','CC02','CCH1','CCH3','CS01') ");
    	Map m = aaDao.qrySql(sql.toString());
    	de318.logs("本月生產量資料", sql.toString());
    	
    	result.put("本月生產量", aaTool.getStr(m.get("PRODWGT")));
		return result;
    }
    
    /**
     * 斗一廠 本月與上月的生產量品項 <br>
     * DataBase:CIC
     * Table/View:V_IPQ137_裁剪月報
     */
    public Map getProductItem(Connection conCIC) throws Exception {
    	Map Result = new HashMap();
		StringBuffer sql = new StringBuffer();
		
		sql.append(" WITH RankedData AS ( ")
		    .append("     SELECT  ")
		    .append("         年月, ")
		    .append("         SUM(產出重_管料) / 1000 AS [管料], ")
		    .append("         SUM(產出重_CR) / 1000 AS [CR鋼板卷], ")
		    .append("         SUM(產出重_HR) / 1000 AS [HR鋼板卷], ")
		    .append("         SUM(產出重_8K) / 1000 AS [8K], ")
		    .append("         SUM(產出重_型鋼) / 1000 AS [型鋼], ")
		    .append("         DENSE_RANK() OVER (ORDER BY 年月 DESC) as rank ")
		    .append("     FROM dbo.[V_IPQ137_裁剪月報] ")
		    .append("     WHERE 廠區 = 'C' ")
		    .append("     GROUP BY 年月 ")
		    .append(" ) ")
		    .append(" SELECT  ")
		    .append("     MAX(CASE WHEN rank = 1 THEN [管料] ELSE 0 END) AS 本月管料, ")
		    .append("     MAX(CASE WHEN rank = 2 THEN [管料] ELSE 0 END) AS 上月管料, ")
		    .append("     MAX(CASE WHEN rank = 1 THEN [CR鋼板卷] ELSE 0 END) AS 本月CR鋼板卷, ")
		    .append("     MAX(CASE WHEN rank = 2 THEN [CR鋼板卷] ELSE 0 END) AS 上月CR鋼板卷, ")
		    .append("     MAX(CASE WHEN rank = 1 THEN [HR鋼板卷] ELSE 0 END) AS 本月HR鋼板卷, ")
		    .append("     MAX(CASE WHEN rank = 2 THEN [HR鋼板卷] ELSE 0 END) AS 上月HR鋼板卷, ")
		    .append("     MAX(CASE WHEN rank = 1 THEN [8K] ELSE 0 END) AS 本月8K, ")
		    .append("     MAX(CASE WHEN rank = 2 THEN [8K] ELSE 0 END) AS 上月8K, ")
		    .append("     MAX(CASE WHEN rank = 1 THEN [型鋼] ELSE 0 END) AS 本月型鋼, ")
		    .append("     MAX(CASE WHEN rank = 2 THEN [型鋼] ELSE 0 END) AS 上月型鋼 ")
		    .append(" FROM RankedData ")
		    .append(" WHERE rank <= 2 ");
        
		Map m = new dejcQueryDAO(dsCom, conCIC).getData(sql.toString());
        	
		//管料
        Result.put("本月管料", aaTool.getBigDecimal(m.get("本月管料")));
        Result.put("上月管料", aaTool.getBigDecimal(m.get("上月管料")));
        //CR鋼板卷
        Result.put("本月CR鋼板卷", aaTool.getBigDecimal(m.get("本月CR鋼板卷")));
        Result.put("上月CR鋼板卷", aaTool.getBigDecimal(m.get("上月CR鋼板卷")));
        //HR鋼板卷
        Result.put("本月HR鋼板卷", aaTool.getBigDecimal(m.get("本月HR鋼板卷")));
        Result.put("上月HR鋼板卷", aaTool.getBigDecimal(m.get("上月HR鋼板卷")));
        //8K
        Result.put("本月8K", aaTool.getBigDecimal(m.get("本月8K")));
        Result.put("上月8K", aaTool.getBigDecimal(m.get("上月8K")));
        //型鋼
        Result.put("本月型鋼", aaTool.getBigDecimal(m.get("本月型鋼")));
        Result.put("上月型鋼", aaTool.getBigDecimal(m.get("上月型鋼")));
        	
		return Result;
	}
    
    /**
     * 斗一廠 總庫存品項(大原料管料、小原料管料、大原料鋼捲、成品鋼板、成品鋼捲、次級) <br>
     * DataBase:CIC <br>
     * Table/View:IPQ7R4_原料存貨分析
     */
    public Map getInventoryItemI(Connection conCIC, String dateYM) throws Exception {
    	Map Result = new HashMap();
		StringBuffer sql = new StringBuffer();
		
        sql.append(" SELECT a.年月 ")
           .append("   , ROUND(SUM(CASE WHEN a.[產品順序] IN ('07') AND a.[群組分類] IN ('CR大原料_管料','HR大原料_管料') THEN a.[斗一重] ELSE 0 END), 0) AS 斗一大原料管料 ")
           .append("   , ROUND(SUM(CASE WHEN a.[產品順序] IN ('07') AND a.[群組分類] IN ('CR小原料_管料','HR小原料_管料') THEN a.[斗一重] ELSE 0 END), 0) AS 斗一小原料管料 ")
           .append("   , ROUND(SUM(CASE WHEN a.[產品順序] IN ('01','04') THEN a.[斗一重] ELSE 0 END), 0) AS 斗一大原料鋼捲 ")
           .append("   , ROUND(SUM(CASE WHEN a.[產品順序] IN ('02','05') AND a.[群組分類]='鋼板' THEN a.[斗一重] ELSE 0 END), 0) AS 斗一成品鋼板 ")
           .append("   , ROUND(SUM(CASE WHEN a.[產品順序] IN ('02','05') AND a.[群組分類]='鋼捲' THEN a.[斗一重] ELSE 0 END), 0) AS 斗一成品鋼捲 ")
           .append("   , ROUND(SUM(CASE WHEN a.[產品順序] IN ('03') THEN a.[斗一重] ELSE 0 END), 0) AS 斗一次級 ")
           .append(" FROM dbo.[IPQ7R4_原料存貨分析] a ")
           .append(" WHERE a.年月='"+dateYM+"' AND a.區域='TW' ")
           .append(" GROUP BY a.年月 ");
        
        Map m = new dejcQueryDAO(dsCom, conCIC).getData(sql.toString());
        if(m == null) m = new HashMap();
        
        Result.put("斗一大原料管料", aaTool.getBigDecimal(m.get("斗一大原料管料")));
        Result.put("斗一小原料管料", aaTool.getBigDecimal(m.get("斗一小原料管料")));
        Result.put("斗一大原料鋼捲", aaTool.getBigDecimal(m.get("斗一大原料鋼捲")));
        Result.put("斗一成品鋼板", aaTool.getBigDecimal(m.get("斗一成品鋼板")));
        Result.put("斗一成品鋼捲", aaTool.getBigDecimal(m.get("斗一成品鋼捲")));
        Result.put("斗一次級", aaTool.getBigDecimal(m.get("斗一次級")));
        	
		return Result;
	}
    
    /**
     * 斗一廠 總庫存品項(角鐵、扁鐵) <br>
     * DataBase:CIC <br>
     * Table/View:V_IPQ7R4_鋼管存貨分析_廠區
     */
    public Map getInventoryItemII(Connection conCIC, String dateYM) throws Exception {
    	Map Result = new HashMap();
		StringBuffer sql = new StringBuffer();
		
        sql.append("SELECT a.年月,a.斗一角鐵,a.斗一扁鐵 ")
           .append(" FROM dbo.[V_IPQ7R4_鋼管存貨分析_廠區] a ")
           .append(" WHERE a.年月='"+dateYM+"' ");
        
        Map m = new dejcQueryDAO(dsCom, conCIC).getData(sql.toString());
        if(m == null) m = new HashMap();
        
        Result.put("斗一角鐵", aaTool.getBigDecimal(m.get("斗一角鐵")));
        Result.put("斗一扁鐵", aaTool.getBigDecimal(m.get("斗一扁鐵")));
        	
		return Result;
	}
    
    /**
     * 斗一廠 欠量、未生產(切版、8K、研磨、停剪機、CR分條) <br>
     * DataBase:CIC <br>
     * Table/View:dbo.IIHSH5_板捲理貨
     */
    public Map getEquipmentBacklogI(Connection conCIC) throws Exception {
		Map result = new HashMap();
    	StringBuilder sql = new StringBuilder();
    	
    	sql.append("SELECT ROUND(SUM(CASE WHEN a.表面判斷='8K' THEN a.欠量重 ELSE 0 END)/1000, 0) AS 欠量重_8K ")
        .append("     , ROUND(SUM(CASE WHEN a.表面判斷='8K' THEN a.未生產重 ELSE 0 END)/1000, 0) AS 未生產重_8K ")
        .append("     , ROUND(SUM(CASE WHEN a.表面判斷='加工' THEN a.欠量重 ELSE 0 END)/1000, 0) AS 欠量重_研磨 ")
        .append("     , ROUND(SUM(CASE WHEN a.表面判斷='加工' THEN a.未生產重 ELSE 0 END)/1000, 0) AS 未生產重_研磨 ")
        .append("     , ROUND(SUM(CASE WHEN a.機台='CR切板' THEN a.欠量重 ELSE 0 END)/1000, 0) AS 欠量重_切板 ")
        .append("     , ROUND(SUM(CASE WHEN a.機台='CR切板' THEN a.未生產重 ELSE 0 END)/1000, 0) AS 未生產重_切板 ")
        .append("     , ROUND(SUM(CASE WHEN a.機台='HR停剪' THEN a.欠量重 ELSE 0 END)/1000, 0) AS 欠量重_停剪 ")
        .append("     , ROUND(SUM(CASE WHEN a.機台='HR停剪' THEN a.未生產重 ELSE 0 END)/1000, 0) AS 未生產重_停剪 ")
        .append("     , ROUND(SUM(CASE WHEN a.機台='CR分條' THEN a.欠量重 ELSE 0 END)/1000, 0) AS 欠量重_CR分條 ")
        .append("     , ROUND(SUM(CASE WHEN a.機台='CR分條' THEN a.未生產重 ELSE 0 END)/1000, 0) AS 未生產重_CR分條 ")
        .append("FROM ( ")
        .append("    SELECT a.區域 ")
        .append("         , a.廠區 ")
        .append("         , a.廠區名稱 ")
        .append("         , a.訂單編號 ")
        .append("         , a.項次 ")
        .append("         , a.銷別 ")
        .append("         , a.表面判斷 ")
        .append("         , a.機台 ")
        .append("         , CASE WHEN a.未出貨重-a.碼頭重<0 THEN 0 ELSE a.未出貨重-a.碼頭重 END AS 欠量重 ")
        .append("         , a.安排重 + CASE WHEN a.未排程重<0 THEN 0 ELSE a.未排程重 END AS 未生產重 ")
        .append("    FROM dbo.IIHSH5_板捲理貨 a  ")
        .append("    WHERE a.區域='TW' AND SUBSTRING(a.訂單編號,1,2) IN ('EC','DC') ")
        .append(") a ");

    	Map m = new dejcQueryDAO(dsCom, conCIC).getData(sql.toString());
	    de318.logs("欠量與未生產資料I", sql.toString());
	     
	    result.put("欠量重_8K", aaTool.getBigDecimal(m.get("欠量重_8K")));
	    result.put("未生產重_8K", aaTool.getBigDecimal(m.get("未生產重_8K")));
	    result.put("欠量重_研磨", aaTool.getBigDecimal(m.get("欠量重_研磨")));
	    result.put("未生產重_研磨", aaTool.getBigDecimal(m.get("未生產重_研磨")));
	    result.put("欠量重_切板", aaTool.getBigDecimal(m.get("欠量重_切板")));
	    result.put("未生產重_切板", aaTool.getBigDecimal(m.get("未生產重_切板")));
	    result.put("欠量重_停剪", aaTool.getBigDecimal(m.get("欠量重_停剪")));
	    result.put("未生產重_停剪", aaTool.getBigDecimal(m.get("未生產重_停剪")));
	    result.put("欠量重_CR分條", aaTool.getBigDecimal(m.get("欠量重_CR分條")));
	    result.put("未生產重_CR分條", aaTool.getBigDecimal(m.get("未生產重_CR分條")));
		
	    return result;
    }
    
    /**
     * 斗一廠 欠量、未生產(HR分條、角扁鐵) <br>
     * DataBase:CIC <br>
     * Table/View:dbo.IPQ76_鋼管訂未交
     */
    public Map getEquipmentBacklogII(Connection conCIC) throws Exception {
		Map result = new HashMap();
    	StringBuilder sql = new StringBuilder();
    	
    	sql.append("SELECT ROUND(SUM(CASE WHEN a.財務類別='配管' AND a.外購='N' THEN a.訂未交重-a.碼頭重 ELSE 0 END)/1000, 0) AS HR分條欠量重 ")
        .append("     , ROUND(SUM(CASE WHEN a.財務類別='配管' AND a.外購='N' THEN a.待生產重 ELSE 0 END)/1000, 0) AS HR分條未生產重 ")
        .append("     , ROUND(SUM(CASE WHEN a.財務類別 IN ('角鐵','扁鐵') AND a.外購='N' THEN a.訂未交重-a.碼頭重 ELSE 0 END)/1000, 0) AS 角扁鐵欠量重 ")
        .append("     , ROUND(SUM(CASE WHEN a.財務類別 IN ('角鐵','扁鐵') AND a.外購='N' THEN a.待生產重 ELSE 0 END)/1000, 0) AS 角扁鐵未生產重 ")
        .append("FROM dbo.IPQ76_鋼管訂未交 a ")
        .append("WHERE a.區域='TW' ");
    	
    	Map m = new dejcQueryDAO(dsCom, conCIC).getData(sql.toString());
	    de318.logs("欠量與未生產資料II", sql.toString());
	     
	    result.put("HR分條欠量重", aaTool.getBigDecimal(m.get("HR分條欠量重")));
	    result.put("HR分條未生產重", aaTool.getBigDecimal(m.get("HR分條未生產重")));
	    result.put("角扁鐵欠量重", aaTool.getBigDecimal(m.get("角扁鐵欠量重")));
	    result.put("角扁鐵未生產重", aaTool.getBigDecimal(m.get("角扁鐵未生產重")));
		
	    return result;
    }
    
    /**
     * 斗一廠 人力與追蹤項目 <br>
     * DataBase:CIC <br>
     * Table/View:dbo.H01_人力結構
     */
    public Map getStaffData(Connection conCIC) throws Exception {
		Map result = new HashMap();
    	StringBuilder sql = new StringBuilder();
    	
    	sql.append(" SELECT ")
	       .append("     SUM(CASE WHEN 分類 = '廠務'   AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 廠務台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '廠務'   AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 廠務外籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '生管成品' AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 生管成品台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '生管成品' AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 生管成品外籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '製造'   AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 製造台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '製造'   AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 製造外籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '加工'   AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 加工台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '加工'   AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 加工外籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '設備'   AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 設備台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 = '設備'   AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 設備外籍人數, ")
	       .append("     SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備') AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 其他台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備') AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 其他外籍人數 ")
	       .append(" FROM dbo.H01_人力結構 ")
	       .append(" WHERE 服務 = '在職' AND 廠別 = '斗六一廠'; ");
    	
    	Map m = new dejcQueryDAO(dsCom, conCIC).getData(sql.toString());
	    de318.logs("人力與追蹤項目", sql.toString());
	    if (m != null) { 
		    result.put("廠務台籍人數", aaTool.getBigDecimal(m.get("廠務台籍人數")));
		    result.put("廠務外籍人數", aaTool.getBigDecimal(m.get("廠務外籍人數")));
		    result.put("生管成品台籍人數", aaTool.getBigDecimal(m.get("生管成品台籍人數")));
		    result.put("生管成品外籍人數", aaTool.getBigDecimal(m.get("生管成品外籍人數")));
		    result.put("製造台籍人數", aaTool.getBigDecimal(m.get("製造台籍人數")));
		    result.put("製造外籍人數", aaTool.getBigDecimal(m.get("製造外籍人數")));
		    result.put("加工台籍人數", aaTool.getBigDecimal(m.get("加工台籍人數")));
		    result.put("加工外籍人數", aaTool.getBigDecimal(m.get("加工外籍人數")));
		    result.put("設備台籍人數", aaTool.getBigDecimal(m.get("設備台籍人數")));
		    result.put("設備外籍人數", aaTool.getBigDecimal(m.get("設備外籍人數")));
		    result.put("其他台籍人數", aaTool.getBigDecimal(m.get("其他台籍人數")));
		    result.put("其他外籍人數", aaTool.getBigDecimal(m.get("其他外籍人數")));
	    }
	    
	    return result;
    }
    
    /**
     * 整理成畫面需要的資料
     * @throws Exception 
     * @throws SQLException 
     */
    public Map getDashboardData(dsjccom dsCom, HttpServletRequest request) throws SQLException, Exception {
    	Connection conCIC = null;
    	try {
    		Map result = new HashMap();
    		bqjcGetConnectionCIC bqGetCon = new bqjcGetConnectionCIC(dsCom);
    		conCIC = bqGetCon.getSQLServerConnection();
    		
    	    String endDate = aaTool.getStr(request.getParameter("endDate_qry")).replaceAll("/","");
    	    if("".equals(endDate))
    	    	endDate = new dejc308().getCrntDateWFmt1();
    	    String dateYM = aaTool.getWYearMonth(endDate);
    	    
    		de318.logs("日期", "orderDate="+endDate+",dateYM="+dateYM);
    	    result.put("OrderAndShipment",this.getOrderAndShipment(conCIC));
    	    result.put("MonthProduction",this.getMonthProduction(dateYM));
    	    result.put("ProductItem",this.getProductItem(conCIC));
    	    result.put("InventoryItemI",this.getInventoryItemI(conCIC,dateYM));
    	    result.put("InventoryItemII",this.getInventoryItemII(conCIC,dateYM));
    	    result.put("EquipmentBacklogI",this.getEquipmentBacklogI(conCIC));
    	    result.put("EquipmentBacklogII",this.getEquipmentBacklogII(conCIC));
    	    result.put("StaffData",this.getStaffData(conCIC));
    	    
    	    return result;
    	    
    	}catch(Exception e){
			throw e;
		}finally {
			if(conCIC != null)
				conCIC.close();
			conCIC = null;
		}
	}
}
