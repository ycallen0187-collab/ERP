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
import java.util.HashMap; 
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import com.icsc.aa.yc.util.aajcYCATool;
import com.icsc.dpms.de.dejc308;
import com.icsc.dpms.de.dejc318;
import com.icsc.dpms.de.dejcQueryDAO;
import com.icsc.dpms.ds.dsjccom;

public class bqjc0423{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjc0423.java,v 1.4 2026/06/15 01:41:18 yc13 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc0423(dsjccom dsCom) {
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
     * 整理成畫面需要的資料
     * @throws Exception 
     * @throws SQLException 
     */
    public Map getTRDashboardData(dsjccom dsCom, HttpServletRequest request) throws Exception {
    	//畫面上沒有輸入日期，預設今天，後續由TR端程式判斷要抓哪一天資料
	    String endDate = aaTool.getStr(request.getParameter("endDate_qry")).replaceAll("/","");
	    if("".equals(endDate))
	    	endDate = new dejc308().getCrntDateWFmt1();
	    
	    //塞AP需要資訊
		Map queryMap = new HashMap();
		queryMap.put("FORMID", "BQ051");				//這個最重要
		queryMap.put("ERPUSERID", dsCom.user.ID);		//判斷授權用				
		queryMap.put("endDate_qry", endDate);			//查詢條件，隨時想加什麼參數，直接 put 進Map就好！
	    
	    //呼叫API
	    return new bqjcGetTRData(dsCom).getDashboard(queryMap);
    }
    
    /**
     * 整理成畫面需要的資料--原來從TW端連線TR抓資料介面，但很慢
     * @throws Exception 
     * @throws SQLException 
     */
    public Map getDashboardData(dsjccom dsCom, HttpServletRequest request) throws SQLException, Exception {
    	Connection conTR = null;
    	try {
    		Map result = new HashMap();
        	bqjcGetConnectionCIC bqGetCon = new bqjcGetConnectionCIC(dsCom);
        	conTR = bqGetCon.getTRDB2Connection();
        	//畫面上沒有輸入日期，改抓TBAO061最大日期
    	    String endDate = aaTool.getStr(request.getParameter("endDate_qry")).replaceAll("/","");
    	    if("".equals(endDate))
    	    	endDate = new dejc308().getCrntDateWFmt1();
    	    String dateYM = aaTool.getWYearMonth(endDate);
    		
    	    //內銷日期
    	    String domDate = dateYM + "01";
    		Map dom = new dejcQueryDAO(dsCom, conTR).getData("SELECT max(a.DATE) AS DATE FROM DB.TBAO031 a WHERE a.COMPID='yc' AND a.DATE<='"+endDate+"'");
    		if(dom != null)
    			domDate = aaTool.getStr(dom.get("DATE"));
    		
    		//外銷日期
    		String expDate = dateYM + "01";
    		Map exp = new dejcQueryDAO(dsCom, conTR).getData("SELECT max(a.DATE) AS DATE FROM DB.TBAO041 a WHERE a.COMPID='yc' AND a.DATE<='"+endDate+"'");
    		if(exp != null)
    			expDate = aaTool.getStr(exp.get("DATE"));
    		
    		//20260606，IV1報表目前滾到資料庫的最大日期
    	    Map date = new dejcQueryDAO(dsCom, conTR).getData("SELECT max(a.DATE) AS DATE FROM DB.TBAO061 a WHERE a.COMPID='yc' AND a.DATE<='"+endDate+"'");
    		if(date != null)
    			endDate = aaTool.getStr(date.get("DATE"));
    		
    		de318.logs("日期", "orderDate="+endDate+",domDate="+domDate+",expDate="+expDate);
    	    result.put("updateDate",endDate);
    	    result.put("orderData",this.getOrderDataFromDB(dsCom, endDate, domDate, expDate,conTR));
    	    result.put("inventoryData",this.getStockDataFromDB(dsCom, endDate, conTR));
    	    
    	    return result;
    	}catch(Exception e){
			throw e;
		}finally {
			if(conTR != null)
				conTR.close();
			conTR = null;
		}
    	
	}

/*
 * =========================================================================================
 * private Method--抽到TR段執行了
 * =========================================================================================
 */
    /**
     * 查詢訂單/出貨/訂未交資料 整理成畫面需要的資料
     */
    private Map getOrderDataFromDB(dsjccom dsCom, String endDate, String domDate, String expDate, Connection conTR) throws Exception {
		Map result = new HashMap();
    	aajcYCATool aaTool = new aajcYCATool();
    	
	    //第幾工作天
    	Map m = new dejcQueryDAO(dsCom, conTR).getData("SELECT currdays AS WORKDAYS FROM DB.TBAO031 c where c.COMPID='yc' AND c.DATE='"+domDate+"'");
    	Map m2 = new dejcQueryDAO(dsCom, conTR).getData("SELECT currdays AS EXP_WORKDAYS FROM DB.TBAO041 c where c.COMPID='yc' AND c.DATE='"+expDate+"'");
    	result.putAll(m);
    	result.putAll(m2);
    	//目標量月份
    	String ym = aaTool.getWYearMonth(domDate);
    	//取得該年月共用表最近一版
    	Map tmp = new dejcQueryDAO(dsCom, conTR).getData("SELECT MAX(SUBSTR(a.TABID,length(a.TABID)-5,6)) AS YM FROM DB.TBDE23 a WHERE a.TABID LIKE 'AOG06DOMP%' AND SUBSTR(a.TABID,length(a.TABID)-5,6)<='"+ym+"'");
    	if(tmp != null)
    		ym = aaTool.getStr(tmp.get("YM"));
    	String goal = "_" + ym;
    	
    	//內銷目標
		StringBuilder sql = new StringBuilder();
		sql.append(" SELECT ")
		.append("     sum(a.FIELD4) AS 內銷當天目標,  ")
		.append("     sum(coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0)) AS DOM_TARGET, ")  //內銷累計目標
		.append("     sum(CASE WHEN a.PRODCLASS='C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) AS DOM_FLAT_TARGET, ")  //內銷板累計目標
		.append("     sum(CASE WHEN a.PRODCLASS<>'C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) AS DOM_LONG_TARGET, ")  //內銷管累計目標
		.append("     sum(coalesce(b.當日接單重,0)) AS 內銷當日接單重, ")
		.append("     SUM(coalesce(b.累計接單重,0)) AS 內銷累計接單重, ")
		//內銷日達成率--TR用不到
		//.append("     round(sum(coalesce(b.累計接單重,0))* 1.00000 / sum(coalesce(FLOAT(a.FIELD4)*FLOAT(c.CURRDAYS),0)) * 100, 1) AS DOM_RATE, ")
		//內銷板達成率
		.append("     round(sum(CASE WHEN b.PRODCLASS='C' THEN coalesce(b.累計接單重,0) ELSE 0 END)* 1.00000 " +
				"/ sum(CASE WHEN a.PRODCLASS='C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) * 100, 1) AS DOM_FLAT_RATE, ")
		//內銷管達成率
		.append("     round(sum(CASE WHEN b.PRODCLASS<>'C' THEN coalesce(b.累計接單重,0) ELSE 0 END)* 1.00000 " +
				"/ sum(CASE WHEN a.PRODCLASS<>'C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) * 100, 1) AS DOM_LONG_RATE, ")
		.append("     SUM(CASE WHEN b.PRODCLASS='C' THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷板累計接單重, ")
		.append("     SUM(CASE WHEN b.PRODCLASS<>'C' THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷管累計接單重 ")
		.append(" FROM ( ")
		//IV1_DOM因為沒接到單，所以不能用台灣抓法抓
		.append(" 	SELECT a.*, ")
		.append(" 	CASE WHEN a.FIELD2 BETWEEN '1' AND '4' THEN 'P' WHEN a.FIELD2 BETWEEN '5' AND '7.5' THEN 'C' ELSE 'Y' END AS PRODCLASS")
		.append(" 	FROM DB.TBDE23 a")
		.append(" 	WHERE a.TABID='AOG06DOM" + goal + "'")
		.append(" ) a ")
		 //-- 呼叫函數 1 (內銷)
		.append(" LEFT JOIN TABLE(DB.IV1_DOM('"+domDate+"')) b ON a.FIELD1 = b.PRODTYPE ")
		.append(" JOIN DB.TBAO031 c ON c.COMPID='yc' AND c.DATE='"+domDate+"' ")
		.append(" WHERE a.TABID='AOG06DOM" + goal + "' AND a.FIELD3='PRODTYPE' ")
		.append(" WITH UR ");
		Map domM = new dejcQueryDAO(dsCom, conTR).getData(sql.toString());
		de318.logs("內銷目標", sql.toString());
		//外銷目標
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append("     sum(a.FIELD4) AS 外銷當天目標,  ")
		.append("     sum(coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0)) AS EXP_TARGET, ")  //外銷累計目標
		.append("     sum(CASE WHEN a.PRODCLASS='C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) AS EXP_FLAT_TARGET, ")  //外銷板累計目標
		.append("     sum(CASE WHEN a.PRODCLASS<>'C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) AS EXP_LONG_TARGET, ")  //外銷管累計目標		
		.append("     sum(coalesce(b.當天未KEY,0) + coalesce(b.當天已KEY,0)) AS 外銷當日接單重, ")
		.append("     sum(coalesce(b.累計接單量,0) + coalesce(b.累計未KEY,0)) AS 外銷累計接單重, ")
		//外銷板達成率
		.append("     round(sum(CASE WHEN b.PRODCLASS='C' THEN coalesce(b.累計接單量,0) + coalesce(b.累計未KEY,0) ELSE 0 END)* 1.00000 " +
				"/ sum(CASE WHEN a.PRODCLASS='C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) * 100, 1) AS EXP_FLAT_RATE, ")
		//外銷管達成率
		.append("     round(sum(CASE WHEN b.PRODCLASS<>'C' THEN coalesce(b.累計接單量,0) + coalesce(b.累計未KEY,0) ELSE 0 END)* 1.00000 " +
				"/ sum(CASE WHEN a.PRODCLASS<>'C' THEN coalesce(FLOAT(a.FIELD4)/FLOAT(c.WORKDAYS)*FLOAT(c.CURRDAYS),0) ELSE 0 END) * 100, 1) AS EXP_LONG_RATE, ")
		.append("     SUM(CASE WHEN b.PRODCLASS='C' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷板累計接單重, ")
		.append("     SUM(CASE WHEN b.PRODCLASS<>'C' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷管累計接單重 ")
		//IV1_EXP因為沒接到單，所以不能用台灣抓法抓
		.append(" FROM ( ")
		.append(" 	SELECT a.*, ")
		.append(" 	CASE WHEN a.FIELD2 BETWEEN '1' AND '4' THEN 'P' WHEN a.FIELD2 BETWEEN '5' AND '7.5' THEN 'C' ELSE 'Y' END AS PRODCLASS")
		.append(" 	FROM DB.TBDE23 a")
		.append(" 	WHERE a.TABID='AOG06EXP" + goal + "'")
		.append(" ) a ")
		//-- 呼叫函數 2 (外銷)
		.append(" JOIN TABLE(DB.IV1_EXP('"+expDate+"')) b ON a.FIELD1 = b.PRODTYPE ")
		.append(" JOIN DB.TBAO041 c ON c.COMPID='yc' AND c.DATE='"+expDate+"' ")
		.append(" WHERE a.TABID='AOG06EXP" + goal + "' AND a.FIELD3='PRODTYPE' ")
		.append(" WITH UR ");
		Map expM = new dejcQueryDAO(dsCom, conTR).getData(sql.toString());
		de318.logs("外銷目標", sql.toString());
		//銷貨與出貨
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append(" x.*,")
		//計算單價
		.append(" CASE WHEN x.SALESQTY > 0 THEN x.銷貨金額*10000*10 / x.SALESQTY ELSE 0 END AS 銷貨單價,")
		.append(" CASE WHEN x.\"CR_C/S_銷貨量\" > 0 THEN \"CR_C/S_銷貨金額\"*10000*10 / x.\"CR_C/S_銷貨量\" ELSE 0 END AS \"CR_C/S_銷貨單價\",")
		.append(" CASE WHEN x.\"HR_C/S_銷貨量\" > 0 THEN \"HR_C/S_銷貨金額\"*10000*10 / x.\"HR_C/S_銷貨量\" ELSE 0 END AS \"HR_C/S_銷貨單價\",")
		.append(" CASE WHEN x.配管_銷貨量 > 0 THEN x.配管_銷貨金額*10000*10 / x.配管_銷貨量 ELSE 0 END AS 配管_銷貨單價,")
		.append(" CASE WHEN x.構造管_銷貨量 > 0 THEN x.構造管_銷貨金額*10000*10 / x.構造管_銷貨量 ELSE 0 END AS 構造管_銷貨單價,")
		.append(" CASE WHEN x.角扁鐵_銷貨量 > 0 THEN x.角扁鐵_銷貨金額*10000*10 / x.角扁鐵_銷貨量 ELSE 0 END AS 角扁鐵_銷貨單價,")
		//達成率
		.append(" CASE WHEN x.內銷管_出貨目標 > 0 THEN x.內銷管_出貨量 * 100 / x.內銷管_出貨目標 ELSE 0 END AS 內銷管_出貨達標率,")
		.append(" CASE WHEN x.外銷管_出貨目標 > 0 THEN x.外銷管_出貨量 * 100 / x.外銷管_出貨目標 ELSE 0 END AS 外銷管_出貨達標率,")
		.append(" CASE WHEN x.板捲_出貨目標 > 0 THEN x.\"C/S_出貨量\" * 100 / x.板捲_出貨目標 ELSE 0 END AS 板捲_出貨達標率,")
		.append(" CASE WHEN x.本月_出貨目標 > 0 THEN x.SHIPQTY * 100 / x.本月_出貨目標 ELSE 0 END AS 本月_出貨達標率,")
		.append(" CASE WHEN x.內銷配管_出貨目標 > 0 THEN x.內銷配管_出貨量 * 100 / x.內銷配管_出貨目標 ELSE 0 END AS 內銷配管_出貨達標率,")
		.append(" CASE WHEN x.內銷構造管_出貨目標 > 0 THEN x.內銷構造管_出貨量 * 100 / x.內銷構造管_出貨目標 ELSE 0 END AS 內銷構造管_出貨達標率,")
		.append(" CASE WHEN x.內銷角扁鐵_出貨目標 > 0 THEN x.內銷角扁鐵_出貨量 * 100 / x.內銷角扁鐵_出貨目標 ELSE 0 END AS 內銷角扁鐵_出貨達標率,")
		.append(" CASE WHEN x.外銷配管_出貨目標 > 0 THEN x.外銷配管_出貨量 * 100 / x.外銷配管_出貨目標 ELSE 0 END AS 外銷配管_出貨達標率,")
		.append(" CASE WHEN x.外銷構造管_出貨目標 > 0 THEN x.外銷構造管_出貨量 * 100 / x.外銷構造管_出貨目標 ELSE 0 END AS 外銷構造管_出貨達標率,")
		.append(" CASE WHEN x.外銷角扁鐵_出貨目標 > 0 THEN x.外銷角扁鐵_出貨量 * 100 / x.外銷角扁鐵_出貨目標 ELSE 0 END AS 外銷角扁鐵_出貨達標率,")
		.append(" CASE WHEN x.CR板捲_出貨目標 > 0 THEN x.\"CR_C/S_出貨量\" * 100 / x.CR板捲_出貨目標 ELSE 0 END AS CR板捲_出貨達標率,")
		.append(" CASE WHEN x.HR板捲_出貨目標 > 0 THEN x.\"HR_C/S_出貨量\" * 100 / x.HR板捲_出貨目標 ELSE 0 END AS HR板捲_出貨達標率")
		.append(" FROM (")
			.append(" SELECT  ")
			//C/S不分內外銷
			.append(" SUM(CASE WHEN x.FIELD1='CR_C/S' THEN coalesce(a.內外銷量, 0) END) AS \"CR_C/S_銷貨量\",")
			.append(" SUM(CASE WHEN x.FIELD1='CR_C/S' THEN coalesce(a.內銷量, 0) + coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) END) AS \"CR_C/S_出貨量\",")
			.append(" SUM(CASE WHEN x.FIELD1='HR_C/S' THEN coalesce(a.內外銷量, 0) END) AS \"HR_C/S_銷貨量\",")
			.append(" SUM(CASE WHEN x.FIELD1='HR_C/S' THEN coalesce(a.內銷量, 0) + coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) END) AS \"HR_C/S_出貨量\",")
			.append(" SUM(CASE WHEN x.FIELD1='CR_C/S' THEN coalesce(a.內外銷金額, 0)/10000 END) AS \"CR_C/S_銷貨金額\",")
			.append(" SUM(CASE WHEN x.FIELD1='HR_C/S' THEN coalesce(a.內外銷金額, 0)/10000 END) AS \"HR_C/S_銷貨金額\",")
			
			//C/S小計
			.append(" SUM(CASE WHEN x.FIELD1 IN ('CR_C/S','HR_C/S') THEN coalesce(a.內外銷量, 0) END) AS \"C/S_銷貨量\",")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('CR_C/S','HR_C/S') THEN coalesce(a.內銷量, 0) + coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) END) AS \"C/S_出貨量\",")
			
			//配管
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(a.內外銷量, 0) - coalesce(a.內銷量, 0) END) AS 外銷配管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) - coalesce(b.本月待簽收_噸, 0) END) AS 外銷配管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(a.內銷量, 0) END) AS 內銷配管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(a.內銷量, 0) + coalesce(b.本月待簽收_噸, 0) END) AS 內銷配管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(a.內銷金額, 0)/10000 END) AS 內銷配管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(a.外銷金額, 0)/10000 END) AS 外銷配管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(a.內外銷量, 0) END) AS 配管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='配管' THEN coalesce(a.內外銷金額, 0)/10000 END) AS 配管_銷貨金額,")
			//構造管
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(a.內外銷量, 0) - coalesce(a.內銷量, 0) END) AS 外銷構造管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) - coalesce(b.本月待簽收_噸, 0) END) AS 外銷構造管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(a.內銷量, 0) END) AS 內銷構造管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(a.內銷量, 0) + coalesce(b.本月待簽收_噸, 0) END) AS 內銷構造管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(a.內銷金額, 0) END)/10000 AS 內銷構造管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(a.外銷金額, 0) END)/10000 AS 外銷構造管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(a.內外銷量, 0) END) AS 構造管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1='構造管' THEN coalesce(a.內外銷金額, 0) END)/10000 AS 構造管_銷貨金額,")
			//角扁鐵
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(a.內外銷量, 0) - coalesce(a.內銷量, 0) END) AS 外銷角扁鐵_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) - coalesce(b.本月待簽收_噸, 0) END) AS 外銷角扁鐵_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(a.內銷量, 0) END) AS 內銷角扁鐵_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(a.內銷量, 0) + coalesce(b.本月待簽收_噸, 0) END) AS 內銷角扁鐵_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(a.內銷金額, 0)/10000 END) AS 內銷角扁鐵_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(a.外銷金額, 0)/10000 END) AS 外銷角扁鐵_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(a.內外銷量, 0) END) AS 角扁鐵_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角扁鐵') THEN coalesce(a.內外銷金額, 0)/10000 END) AS 角扁鐵_銷貨金額,")
			//內外銷-管小計
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(a.內銷量, 0) END) AS 內銷管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(a.內銷量, 0) + coalesce(b.本月待簽收_噸, 0) END) AS 內銷管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(a.內外銷量, 0) - coalesce(a.內銷量, 0) END) AS 外銷管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) - coalesce(b.本月待簽收_噸, 0) END) AS 外銷管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(a.內銷金額, 0)/10000 END) AS 內銷管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(a.外銷金額, 0)/10000 END) AS 外銷管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(a.內外銷量, 0) END) AS 管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角扁鐵') THEN coalesce(a.內外銷金額, 0)/10000 END) AS 管_銷貨金額,")
			//總量
			.append(" SUM(coalesce(a.內外銷量, 0)) AS SALESQTY,")  //內外銷貨量
			.append(" SUM(coalesce(a.內銷量, 0) + coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0)) AS SHIPQTY,")  //本月內外銷出貨量
			.append(" SUM(coalesce(a.內外銷金額, 0)/10000) AS 銷貨金額,")
			//目標量
			.append(" SUM (CASE WHEN x2.FIELD1 = '配管' THEN x2.FIELD4 END) AS 內銷配管_出貨目標,")
			.append(" SUM (CASE WHEN x2.FIELD1 = '構造管' THEN x2.FIELD4 END) AS 內銷構造管_出貨目標,")
			.append(" SUM (CASE WHEN x2.FIELD1 IN ('角扁鐵')  THEN x2.FIELD4 END) AS 內銷角扁鐵_出貨目標,")
			.append(" SUM (CASE WHEN x2.FIELD1 IN ('配管', '構造管', '角扁鐵')  THEN x2.FIELD4 END) AS 內銷管_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 = '配管' THEN x3.FIELD4 END) AS 外銷配管_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 = '構造管' THEN x3.FIELD4 END) AS 外銷構造管_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 IN ('角扁鐵')  THEN x3.FIELD4 END) AS 外銷角扁鐵_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 IN ('配管', '構造管', '角扁鐵')  THEN x3.FIELD4 END) AS 外銷管_出貨目標,")
			.append(" SUM (CASE WHEN x.FIELD1 IN ('CR_C/S') THEN x2.FIELD4 + x3.FIELD4 END) AS CR板捲_出貨目標,")
			.append(" SUM (CASE WHEN x.FIELD1 IN ('HR_C/S') THEN x2.FIELD4 + x3.FIELD4 END) AS HR板捲_出貨目標,")
			.append(" SUM (CASE WHEN x.FIELD1 IN ('CR_C/S', 'HR_C/S') THEN x2.FIELD4 + x3.FIELD4 END) AS 板捲_出貨目標,")
			.append(" SUM (x2.FIELD4 + x3.FIELD4) AS 本月_出貨目標")
			
			.append(" FROM DB.TBDE23 x ")
			//-- 1. 呼叫內外銷 Function 
			.append(" LEFT JOIN TABLE(DB.IV1_SHIP_SALES('"+endDate+"')) a ON x.FIELD1 = a.PRODTYPE ")
			//-- 2. 呼叫碼頭 Function 
			.append(" LEFT JOIN TABLE(DB.IV1_SHIP_PORT('"+endDate+"')) b ON x.FIELD1 = b.PRODTYPE ")
			//-- 3. 呼叫結關 Function 
			.append(" LEFT JOIN TABLE(DB.IV1_SHIP_CLOSE('"+endDate+"')) c ON x.FIELD1 = c.PRODTYPE ")
			//-- 4. 目標量
			.append(" LEFT JOIN DB.TBDE23 x2 ON x2.TABID = 'AOG06SS_DOM' AND x.FIELD1=x2.FIELD1 ")
			.append(" LEFT JOIN DB.TBDE23 x3 ON x3.TABID = 'AOG06SS_EXP' AND x.FIELD1=x3.FIELD1 ")
			.append(" WHERE x.TABID='AOG06SS' ")
		.append(" ) x ")
		.append(" WITH UR ");
		Map shipM = new dejcQueryDAO(dsCom, conTR).getData(sql.toString());
		de318.logs("銷貨與出貨", sql.toString());
		//訂未交
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append("   SUM(CASE WHEN a.PRODTYPE IN ('CR_C','CR_S') THEN a.UNDERWET ELSE 0 END) AS CR_板捲_未交重,")
		.append("   SUM(CASE WHEN a.PRODTYPE IN ('HR_C','HR_S') THEN a.UNDERWET ELSE 0 END) AS HR_板捲_未交重,")
		.append("   SUM(CASE WHEN a.PRODTYPE IN ('CR_C','CR_S','HR_C','HR_S') THEN a.UNDERWET ELSE 0 END) AS 板捲_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE='Pipe' THEN a.UNDERWET ELSE 0 END) AS 內銷_P_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE='Pipe' THEN a.UNDERWET ELSE 0 END) AS 外銷_P_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE='Tube口' THEN a.UNDERWET ELSE 0 END) AS 內銷_T_口_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE='Tube口' THEN a.UNDERWET ELSE 0 END) AS 外銷_T_口_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE='TubeΦ' THEN a.UNDERWET ELSE 0 END) AS 內銷_T_O_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE='TubeΦ' THEN a.UNDERWET ELSE 0 END) AS 外銷_T_O_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE='F/L' THEN a.UNDERWET ELSE 0 END) AS 內銷_FL_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE='F/L' THEN a.UNDERWET ELSE 0 END) AS 外銷_FL_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND (a.PRODTYPE='Pipe' OR a.PRODTYPE LIKE 'Tube%' OR a.PRODTYPE='F/L') THEN a.UNDERWET ELSE 0 END) AS 內銷管_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND (a.PRODTYPE='Pipe' OR a.PRODTYPE LIKE 'Tube%' OR a.PRODTYPE='F/L') THEN a.UNDERWET ELSE 0 END) AS 外銷管_未交重,")		
		.append("   SUM(a.UNDERWET) AS UNDERWET ")
		.append("FROM ( ")
		.append("	SELECT  ")
		.append("		CASE WHEN a.SCHPRODMODE='B' THEN '受託加工'  ")
		.append("		     WHEN a.ISPO='YC TR' THEN 'YC TR' ")
		.append("		     WHEN a.SALESTYPE='S' THEN '內銷' ")
		.append("		     WHEN a.SALESTYPE='G' THEN '總務' ")
		.append("		ELSE '外銷' END AS 部門, ")
		.append("		a.* ")
		.append("	FROM DB.TBAO062 a ")
		.append("	WHERE a.COMPID='yc' AND a.DATE='"+endDate+"'  AND coalesce(a.ISPO,'')<>'S' AND a.PRODCLASS<>'Y' ")
		.append(") a ")
		.append("WHERE (a.PRODCLASS IN ('C') AND a.部門 IN ('內銷', '外銷', 'YC TR')) ")
		.append("   OR (a.PRODCLASS IN ('P') AND a.部門 IN ('內銷', '外銷')) ")
		.append("   OR (a.PRODCLASS IN ('H') AND a.部門 IN ('內銷', '外銷')) ")
		.append("   OR (a.PRODCLASS IN ('Y')) ")
		.append("WITH UR ");
		Map underM = new dejcQueryDAO(dsCom, conTR).getData(sql.toString());
		de318.logs("訂未交", sql.toString());
		//訂未交 TOP 5
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append(" b.CUSTNAME as 客戶名, SUM(a.UNDERWET) AS 訂未交")
		.append(" FROM DB.TBAO0621 a ")
		.append(" JOIN DB.TBSOYC021 b ON a.COMPID=b.COMPID AND a.ORDERNO=b.ORDERNO")
		.append(" WHERE a.COMPID='yc' AND a.DATE='"+endDate+"' AND b.SALESDEPT LIKE 'S%'")
		.append(" GROUP BY b.CUSTNAME ")
		.append(" ORDER BY SUM(a.UNDERWET) DESC ")
		.append(" FETCH FIRST 5 ROWS ONLY ")
		.append(" WITH UR ");
		Map[] under5_Dom = new dejcQueryDAO(dsCom, conTR).getDatas(sql.toString());
		de318.logs("內銷訂未交 TOP 5", sql.toString());
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append(" b.CUSTNAME as 客戶名, SUM(a.UNDERWET) AS 訂未交")
		.append(" FROM DB.TBAO0621 a ")
		.append(" JOIN DB.TBSOYC021 b ON a.COMPID=b.COMPID AND a.ORDERNO=b.ORDERNO")
		.append(" WHERE a.COMPID='yc' AND a.DATE='"+endDate+"' AND b.SALESDEPT LIKE 'T%'")
		.append(" GROUP BY b.CUSTNAME ")
		.append(" ORDER BY SUM(a.UNDERWET) DESC ")
		.append(" FETCH FIRST 5 ROWS ONLY ")
		.append(" WITH UR ");
		Map[] under5_Exp = new dejcQueryDAO(dsCom, conTR).getDatas(sql.toString());
		de318.logs("外銷訂未交 TOP 5", sql.toString());
		
		// 會覆蓋重複的 key
		result.putAll(domM);
		result.putAll(expM);
		result.putAll(shipM); 
		result.putAll(underM); 
		result.put("內銷訂未交 TOP 5", under5_Dom);
		result.put("外銷訂未交 TOP 5", under5_Exp);
		
		//本月接單
		result.put("ORDERQTY", aaTool.getBigDecimal(domM.get("內銷累計接單重")).add(aaTool.getBigDecimal(expM.get("外銷累計接單重"))).setScale(0, BigDecimal.ROUND_HALF_UP)); 
		//今日接單
		result.put("ORD_TODAYQTY", aaTool.getBigDecimal(domM.get("內銷當日接單重")).add(aaTool.getBigDecimal(expM.get("外銷當日接單重"))).setScale(0, BigDecimal.ROUND_HALF_UP));
		//本月累計目標
		result.put("ORD_TARGET", aaTool.getBigDecimal(domM.get("DOM_TARGET")).add(aaTool.getBigDecimal(expM.get("EXP_TARGET"))).setScale(0, BigDecimal.ROUND_HALF_UP));
		//總接單達成率
		if(aaTool.getBigDecimal(result.get("ORD_TARGET")).intValue() > 0)
			result.put("ORD_RATE", aaTool.getBigDecimal(result.get("ORDERQTY")).multiply(new BigDecimal(100)).divide(
					aaTool.getBigDecimal(result.get("ORD_TARGET")), 1, BigDecimal.ROUND_HALF_UP));
		result.put("ORDQTY_DOM", aaTool.getBigDecimal(domM.get("內銷累計接單重")).setScale(0, BigDecimal.ROUND_HALF_UP));		
		result.put("ORDQTY_EXP_FLAT", aaTool.getBigDecimal(expM.get("外銷板累計接單重")).setScale(0, BigDecimal.ROUND_HALF_UP));
		result.put("ORDQTY_EXP_LONG", aaTool.getBigDecimal(expM.get("外銷管累計接單重")).setScale(0, BigDecimal.ROUND_HALF_UP));
		//板捲累計接單重
		result.put("ORDQTY_FLAT", aaTool.getBigDecimal(domM.get("內銷板累計接單重")).add(aaTool.getBigDecimal(expM.get("外銷板累計接單重"))).setScale(0, BigDecimal.ROUND_HALF_UP));
		result.put("ORD_FLAT_TARGET", aaTool.getBigDecimal(domM.get("DOM_FLAT_TARGET")).add(aaTool.getBigDecimal(expM.get("EXP_FLAT_TARGET"))).setScale(0, BigDecimal.ROUND_HALF_UP));
		if(aaTool.getBigDecimal(result.get("ORD_FLAT_TARGET")).intValue() > 0)
			result.put("ORDQTY_FLAT_RATE", aaTool.getBigDecimal(result.get("ORDQTY_FLAT")).multiply(new BigDecimal(100)).divide(
					aaTool.getBigDecimal(result.get("ORD_FLAT_TARGET")), 1, BigDecimal.ROUND_HALF_UP));
		
		return result;
	}

    /**
     * 查詢庫存資料 整理成畫面需要的資料
     */
    private Map getStockDataFromDB(dsjccom dsCom, String endDate, Connection conTR) throws Exception {
		Map result = new HashMap();
    	aajcYCATool aaTool = new aajcYCATool();
    	StringBuilder sql = new StringBuilder();
    	
    	sql.append("SELECT round(存貨,0) + round(管料,0) AS 原料庫存")
    	.append(",round(鋼管_存貨,0) + round(角扁鐵_存貨,0) AS 成品庫存")
    	.append(",round(鋼廠未交,0) + round(管料_鋼廠未交,0) AS 鋼廠未交")
    	.append(",round(結存,0) AS 結存 FROM TABLE(DB.FN_BQ042_STOCK('"+endDate+"'))");
    	Map m = new dejcQueryDAO(dsCom, conTR).getData(sql.toString());
    	de318.logs("庫存資料", sql.toString());
    	
    	result.put("原料庫存", aaTool.getStr(m.get("原料庫存")));
    	//成品庫存 = 鋼管_存貨 + 角扁鐵_存貨
    	result.put("成品庫存", aaTool.getStr(m.get("成品庫存")));
    	//鋼廠未交 = 鋼廠未交 + 管料_鋼廠未交
    	result.put("鋼廠未交", aaTool.getStr(m.get("鋼廠未交")));
    	result.put("結存", aaTool.getStr(m.get("結存")));
		return result;
	}
    
}
