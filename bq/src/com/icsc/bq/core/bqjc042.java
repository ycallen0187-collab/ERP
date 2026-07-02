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

public class bqjc042{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjc042.java,v 1.9 2026/06/17 03:37:52 02515 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc042(dsjccom dsCom) {
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
     * 查詢訂單/出貨/訂未交資料 整理成畫面需要的資料
     */
    public Map getOrderDataFromDB(dsjccom dsCom, String endDate, String domDate, String expDate) throws Exception {
		Map result = new HashMap();
    	aajcYCATool aaTool = new aajcYCATool();
    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
    	
	    //第幾工作天
    	Map m = aaDao.qrySql("SELECT currdays AS WORKDAYS FROM DB.TBAO031 c where c.COMPID='yc' AND c.DATE='"+domDate+"'");
    	Map m2 = aaDao.qrySql("SELECT currdays AS EXP_WORKDAYS FROM DB.TBAO041 c where c.COMPID='yc' AND c.DATE='"+expDate+"'");
    	result.putAll(m);
    	result.putAll(m2);
    	
    	//內銷目標
		StringBuilder sql = new StringBuilder();
		sql.append(" SELECT ")
		.append("     sum(a.FIELD4) AS 內銷當天目標,  ")
		.append("     sum(coalesce(FLOAT(a.FIELD4)*FLOAT(c.CURRDAYS),0)) AS DOM_TARGET, ")  //內銷累計目標
		.append("     sum(coalesce(b.當日接單重,0)) AS 內銷當日接單重, ")
		.append("     SUM(coalesce(b.累計接單重,0)) AS 內銷累計接單重, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'P' THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷_P_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'T_O' THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷_T_O_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'T_口' THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷_T_口_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'F/L' THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷_FL_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE in ('P', 'T_O', 'T_口', 'F/L') THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷管_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE in ('CR_C/S', 'CR_次級板') THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷_CR_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'HR_C/S' THEN coalesce (b.累計接單重, 0) ELSE 0 END) AS 內銷_HR_接單量, ")
		.append("     round(sum(coalesce(b.累計接單重,0))* 1.00000 / sum(coalesce(FLOAT(a.FIELD4)*FLOAT(c.CURRDAYS),0)) * 100, 1) AS DOM_RATE ")  //內銷日達成率
		.append(" FROM DB.TBDE23 a ")
		 //-- 呼叫函數 1 (內銷)
		.append(" LEFT JOIN TABLE(DB.IV1_DOM('"+domDate+"')) b ON a.FIELD1 = b.PRODTYPE ")
		.append(" JOIN DB.TBAO031 c ON c.COMPID='yc' AND c.DATE='"+domDate+"' ")
		.append(" WHERE a.TABID='AOG06DOM_2022' AND a.FIELD3='PRODTYPE' ")
		.append(" WITH UR ");
		Map domM = aaDao.qrySql(sql.toString());
		de318.logs("內銷目標", sql.toString());
		//外銷目標
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append("     sum(a.FIELD4) AS 外銷當天目標,  ")
		.append("     sum(coalesce(FLOAT(a.FIELD4)*FLOAT(b.CURRDAYS),0)) AS EXP_TARGET, ")  //外銷累計目標
		.append("     sum(coalesce(b.當天未KEY,0) + coalesce(b.當天已KEY,0)) AS 外銷當日接單重, ")
		.append("     sum(coalesce(b.累計接單量,0) + coalesce(b.累計未KEY,0)) AS 外銷累計接單重, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'P' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷_P_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'T_O' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷_T_O_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'T_口' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷_T_口_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'F/L' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷_FL_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE in ('CR_C/S', 'CR_次級板') THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷_CR_接單量, ")
		.append("     SUM (CASE WHEN b.PRODTYPE = 'HR_C/S' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷_HR_接單量, ")
		//外銷板達成率
		.append("     round(sum(CASE WHEN b.PRODCLASS='C' THEN coalesce(b.累計接單量,0) + coalesce(b.累計未KEY,0) ELSE 0 END)* 1.00000 " +
				"/ sum(CASE WHEN b.PRODCLASS='C' THEN coalesce(FLOAT(a.FIELD4)*FLOAT(b.CURRDAYS),0) ELSE 0 END) * 100, 1) AS EXP_FLAT_RATE, ")
		//外銷管達成率
		.append("     round(sum(CASE WHEN b.PRODCLASS<>'C' THEN coalesce(b.累計接單量,0) + coalesce(b.累計未KEY,0) ELSE 0 END)* 1.00000 " +
				"/ sum(CASE WHEN b.PRODCLASS<>'C' THEN coalesce(FLOAT(a.FIELD4)*FLOAT(b.CURRDAYS),0) ELSE 0 END) * 100, 1) AS EXP_LONG_RATE, ")
		.append("     SUM(CASE WHEN b.PRODCLASS='C' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷板累計接單重, ")
		.append("     SUM(CASE WHEN b.PRODCLASS<>'C' THEN coalesce (b.累計接單量, 0) + coalesce (b.累計未KEY, 0) ELSE 0 END) AS 外銷管累計接單重 ")
		.append(" FROM DB.TBDE23 a ")
		//-- 呼叫函數 2 (外銷)
		.append(" LEFT JOIN TABLE(DB.IV1_EXP('"+expDate+"')) b ON a.FIELD1 = b.PRODTYPE ")
		.append(" WHERE a.TABID='AOG06EXP_2022' AND a.FIELD3='PRODTYPE' ")
		.append(" WITH UR ");
		Map expM = aaDao.qrySql(sql.toString());
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
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(a.內外銷量, 0) - coalesce(a.內銷量, 0) END) AS 外銷角扁鐵_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) - coalesce(b.本月待簽收_噸, 0) END) AS 外銷角扁鐵_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(a.內銷量, 0) END) AS 內銷角扁鐵_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(a.內銷量, 0) + coalesce(b.本月待簽收_噸, 0) END) AS 內銷角扁鐵_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(a.內銷金額, 0)/10000 END) AS 內銷角扁鐵_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(a.外銷金額, 0)/10000 END) AS 外銷角扁鐵_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(a.內外銷量, 0) END) AS 角扁鐵_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('角鐵', '扁鐵') THEN coalesce(a.內外銷金額, 0)/10000 END) AS 角扁鐵_銷貨金額,")
			//內外銷-管小計
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(a.內銷量, 0) END) AS 內銷管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(a.內銷量, 0) + coalesce(b.本月待簽收_噸, 0) END) AS 內銷管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(a.內外銷量, 0) - coalesce(a.內銷量, 0) END) AS 外銷管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0) - coalesce(b.本月待簽收_噸, 0) END) AS 外銷管_出貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(a.內銷金額, 0)/10000 END) AS 內銷管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(a.外銷金額, 0)/10000 END) AS 外銷管_銷貨金額,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(a.內外銷量, 0) END) AS 管_銷貨量,")
			.append(" SUM(CASE WHEN x.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵') THEN coalesce(a.內外銷金額, 0)/10000 END) AS 管_銷貨金額,")
			//總量
			.append(" SUM(coalesce(a.內外銷量, 0)) AS SALESQTY,")  //內外銷貨量
			.append(" SUM(coalesce(a.內銷量, 0) + coalesce(b.本月碼頭量_噸, 0) + coalesce(c.本月結關量, 0)) AS SHIPQTY,")  //本月內外銷出貨量
			.append(" SUM(coalesce(a.內外銷金額, 0)/10000) AS 銷貨金額,")
			//目標量
			.append(" SUM (CASE WHEN x2.FIELD1 = '配管' THEN x2.FIELD4 END) AS 內銷配管_出貨目標,")
			.append(" SUM (CASE WHEN x2.FIELD1 = '構造管' THEN x2.FIELD4 END) AS 內銷構造管_出貨目標,")
			.append(" SUM (CASE WHEN x2.FIELD1 IN ('角鐵', '扁鐵')  THEN x2.FIELD4 END) AS 內銷角扁鐵_出貨目標,")
			.append(" SUM (CASE WHEN x2.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵')  THEN x2.FIELD4 END) AS 內銷管_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 = '配管' THEN x3.FIELD4 END) AS 外銷配管_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 = '構造管' THEN x3.FIELD4 END) AS 外銷構造管_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 IN ('角鐵', '扁鐵')  THEN x3.FIELD4 END) AS 外銷角扁鐵_出貨目標,")
			.append(" SUM (CASE WHEN x3.FIELD1 IN ('配管', '構造管', '角鐵', '扁鐵')  THEN x3.FIELD4 END) AS 外銷管_出貨目標,")
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
		Map shipM = aaDao.qrySql(sql.toString());
		de318.logs("銷貨與出貨", sql.toString());
		//訂未交
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append("   SUM(CASE WHEN a.PRODTYPE IN ('CR_C','CR_S') THEN a.UNDERWET ELSE 0 END) AS CR_板捲_未交重,")
		.append("   SUM(CASE WHEN a.PRODTYPE IN ('HR_C','HR_S') THEN a.UNDERWET ELSE 0 END) AS HR_板捲_未交重,")
		.append("   SUM(CASE WHEN a.PRODTYPE IN ('CR_C','CR_S','HR_C','HR_S') THEN a.UNDERWET ELSE 0 END) AS 板捲_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE LIKE '%配管%' THEN a.UNDERWET ELSE 0 END) AS 內銷_P_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE LIKE '%配管%' THEN a.UNDERWET ELSE 0 END) AS 外銷_P_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE LIKE '%構造長/方管%' THEN a.UNDERWET ELSE 0 END) AS 內銷_T_口_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE LIKE '%構造長/方管%' THEN a.UNDERWET ELSE 0 END) AS 外銷_T_口_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE LIKE '%構造圓管%' THEN a.UNDERWET ELSE 0 END) AS 內銷_T_O_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE LIKE '%構造圓管%' THEN a.UNDERWET ELSE 0 END) AS 外銷_T_O_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND a.PRODTYPE IN ('角鐵', '扁鐵') THEN a.UNDERWET ELSE 0 END) AS 內銷_FL_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND a.PRODTYPE IN ('角鐵', '扁鐵') THEN a.UNDERWET ELSE 0 END) AS 外銷_FL_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='S' AND (a.PRODTYPE LIKE '%配管%' OR a.PRODTYPE LIKE '%構造%' OR a.PRODTYPE IN ('角鐵', '扁鐵')) THEN a.UNDERWET ELSE 0 END) AS 內銷管_未交重,")
		.append("   SUM(CASE WHEN a.SALESTYPE='T' AND (a.PRODTYPE LIKE '%配管%' OR a.PRODTYPE LIKE '%構造%' OR a.PRODTYPE IN ('角鐵', '扁鐵')) THEN a.UNDERWET ELSE 0 END) AS 外銷管_未交重,")		
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
		Map underM = aaDao.qrySql(sql.toString());
		de318.logs("訂未交", sql.toString());
		//訂未交 TOP 5
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append(" b.CUSTNAME as 客戶名, SUM(a.UNDERWET) AS 訂未交")
		.append(" FROM DB.TBAO0622 a ")
		.append(" JOIN DB.TBSOYC021 b ON a.COMPID=b.COMPID AND a.ORDERNO=b.ORDERNO")
		.append(" WHERE a.COMPID='yc' AND a.DATE='"+endDate+"' AND b.SALESDEPT LIKE 'S%'")
		.append(" GROUP BY b.CUSTNAME ")
		.append(" ORDER BY SUM(a.UNDERWET) DESC ")
		.append(" FETCH FIRST 5 ROWS ONLY ")
		.append(" WITH UR ");
		Map[] under5_Dom = aaDao.qrySqlAll(sql.toString());
		de318.logs("內銷訂未交 TOP 5", sql.toString());
		sql.setLength(0);
		sql.append(" SELECT  ")
		.append(" b.CUSTNAME as 客戶名, SUM(a.UNDERWET) AS 訂未交")
		.append(" FROM DB.TBAO0622 a ")
		.append(" JOIN DB.TBSOYC021 b ON a.COMPID=b.COMPID AND a.ORDERNO=b.ORDERNO")
		.append(" WHERE a.COMPID='yc' AND a.DATE='"+endDate+"' AND b.SALESDEPT LIKE 'T%'")
		.append(" GROUP BY b.CUSTNAME ")
		.append(" ORDER BY SUM(a.UNDERWET) DESC ")
		.append(" FETCH FIRST 5 ROWS ONLY ")
		.append(" WITH UR ");
		Map[] under5_Exp = aaDao.qrySqlAll(sql.toString());
		de318.logs("外銷訂未交 TOP 5", sql.toString());
		//鋼管接單量TOP10:內銷AO031+外銷AO042&AO061
		sql.setLength(0);
		sql.append(" SELECT * FROM(  ")
		.append(" SELECT  ")
		.append("     c.CUSTNAME as 客戶名, ")
		.append("     ROUND(SUM(d.WET) / 1000,0) AS 接單量 ")
		.append("     FROM DB.TBAO031 a ")
		.append("     JOIN DB.TBSOYC021 c ON a.COMPID=c.COMPID  ")
		.append("     JOIN DB.TBSOYC023 d ON c.COMPID=d.COMPID AND c.ORDERNO=d.ORDERNO ")
		.append("     WHERE a.COMPID='yc'  ")
		.append("     AND a.DATE = '"+domDate+"' ")
		.append("     AND EXISTS (SELECT 1 FROM DB.TBAO061 x WHERE x.COMPID=a.COMPID AND x.DATE=a.DATE AND x.ORDERNO=d.ORDERNO AND x.ORDERITEM=d.ORDERITEMNO AND x.TYPE='D') ")
		.append("     AND c.PRODCLASS IN ('P','H') ")
		.append(" GROUP BY c.PRODCLASS,c.CUSTNAME ")
		.append(" UNION ALL ")
		.append(" SELECT COALESCE(A.CUSTNAME,B.CUSTNAME) AS 客戶名, ")
		.append(" COALESCE(累計未KEY,0)+COALESCE(ORDWGT,0) AS 接單量  ")
		.append(" FROM( ")
		.append("   SELECT  ")
		.append(" 		a.COMPID, a.DATE, A.CUSTNAME,  ")
		.append(" 		sum(CASE WHEN a.STATUS IN ('A','B') THEN a.PWGT + a.ENWGT + a.TCWGT + a.TSWGT + a.FWGT ELSE 0 END) AS 累計未KEY ")
		.append("   FROM DB.TBAO042 A WHERE A.DATE = '"+expDate+"' GROUP BY a.COMPID, a.DATE, A.CUSTNAME)a  ")
		.append("   FULL OUTER JOIN ( ")
		.append("    SELECT  ")
		.append(" 		b.COMPID, b.DATE, C.CUSTNAME, ")
		.append(" 		ROUND(SUM(b.ORDWGT/1000),0) AS ORDWGT ")
		.append("   FROM ( ")
		.append("   	SELECT * FROM DB.TBAO061 ")
		.append("   	UNION  ")
		.append("   	SELECT * FROM DB.TBAO061_H ")
		.append("   ) b  ")
		.append("   JOIN DB.TBSOYC021 c ON b.COMPID=c.COMPID AND b.ORDERNO=c.ORDERNO ")
		.append("   JOIN DB.TBSOYC023 d ON b.COMPID=d.COMPID AND b.ORDERNO=d.ORDERNO AND b.ORDERITEM=d.ORDERITEMNO ")
		.append("   WHERE b.TYPE='EP' AND d.CLOSESTATUS IN ('','A') AND c.CUSTNO<>'FTR101' AND B.DATE = '"+expDate+"' ")
		.append("   GROUP BY b.COMPID, b.DATE, C.CUSTNAME ")
		.append("   ) b ON A.COMPID=b.COMPID AND A.DATE=b.DATE AND A.CUSTNAME = B.CUSTNAME ")
		.append(" ) ")
		.append(" ORDER BY 接單量 DESC ")
		.append(" FETCH FIRST 10 ROWS ONLY ")
		.append(" WITH UR ");
		de318.logs("鋼管接單量TOP10", sql.toString());
		Map[] receive10_P = aaDao.qrySqlAll(sql.toString());
		//鋼板接單量TOP10:內銷AO031+外銷AO052&AO061
		sql.setLength(0);
		sql.append(" SELECT * FROM( ")
		.append(" SELECT  ")
		.append("     c.CUSTNAME as 客戶名, ")
		.append("     ROUND(SUM(d.WET) / 1000,0) AS 接單量 ")
		.append("     FROM DB.TBAO031 a ")
		.append("     JOIN DB.TBSOYC021 c ON a.COMPID=c.COMPID  ")
		.append("     JOIN DB.TBSOYC023 d ON c.COMPID=d.COMPID AND c.ORDERNO=d.ORDERNO ")
		.append("     WHERE a.COMPID='yc'  ")
		.append("     AND a.DATE = '"+domDate+"' ")
		.append("     AND EXISTS (SELECT 1 FROM DB.TBAO061 x WHERE x.COMPID=a.COMPID AND x.DATE=a.DATE AND x.ORDERNO=d.ORDERNO AND x.ORDERITEM=d.ORDERITEMNO AND x.TYPE='D') ")
		.append("     AND c.PRODCLASS IN ('C') ")
		.append(" GROUP BY c.PRODCLASS,c.CUSTNAME ")
		.append(" UNION ALL  ")
		.append(" SELECT COALESCE(A.CUSTNAME,B.CUSTNAME) AS 客戶名, ")
		.append(" COALESCE(累計未KEY,0)+COALESCE(ORDWGT,0) AS 接單量  ")
		.append(" FROM(SELECT  ")
		.append(" 		a.COMPID, a.DATE, a.custname, ")
		.append(" 		SUM(CASE WHEN a.STATUS IN ('未') THEN a.CRWGT+a.HRWGT+a.SNDWGT ELSE 0 END) AS 累計未KEY  ")
		.append(" FROM DB.TBAO052 a  WHERE A.DATE = '"+expDate+"' GROUP BY a.COMPID, a.DATE, A.CUSTNAME)a ")
		.append(" FULL OUTER JOIN( ")
		.append(" SELECT  ")
		.append(" 			b.COMPID, b.DATE, C.CUSTNAME,   ")
		.append(" 			ROUND(SUM(b.ORDWGT/1000),0) AS ORDWGT ")
		.append(" 		FROM ( ")
		.append(" 			SELECT * FROM DB.TBAO061 ")
		.append(" 			UNION  ")
		.append(" 			SELECT * FROM DB.TBAO061_H ")
		.append(" 		) b  ")
		.append(" 		JOIN DB.TBSOYC021 c ON b.COMPID=c.COMPID AND b.ORDERNO=c.ORDERNO  ")
		.append(" 		JOIN DB.TBSOYC023 d ON b.COMPID=d.COMPID AND b.ORDERNO=d.ORDERNO AND b.ORDERITEM=d.ORDERITEMNO ")
		.append(" 		LEFT JOIN DB.TBSOYC071 e ON c.COMPID=e.COMPID AND c.PURPOSEPORT=e.PORTNO ")
		.append(" 		WHERE b.TYPE='EC' AND c.CUSTNO<>'FTR101'  AND B.DATE = '"+expDate+"' ")
		.append(" 		GROUP BY b.COMPID, b.DATE, C.CUSTNAME ")
		.append(" ) b ON A.COMPID=b.COMPID AND A.DATE=b.DATE AND A.CUSTNAME = B.CUSTNAME ")
		.append(" ) ")
		.append(" ORDER BY 接單量 DESC ")
		.append(" FETCH FIRST 10 ROWS ONLY ")
		.append(" WITH UR ");
		de318.logs("板接單量TOP10", sql.toString());
		Map[] receive10_C = aaDao.qrySqlAll(sql.toString());
		// 會覆蓋重複的 key
		result.putAll(domM);
		result.putAll(expM);
		result.putAll(shipM); 
		result.putAll(underM); 
		result.put("內銷訂未交 TOP 5", under5_Dom);
		result.put("外銷訂未交 TOP 5", under5_Exp);
		result.put("PIPE_TOP10", receive10_P);
		result.put("FLAT_TOP10", receive10_C);
		
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
		result.put("CR_板捲_接單量", aaTool.getBigDecimal(domM.get("內銷_CR_接單量")).add(aaTool.getBigDecimal(expM.get("外銷_CR_接單量"))).setScale(0, BigDecimal.ROUND_HALF_UP));
		result.put("HR_板捲_接單量", aaTool.getBigDecimal(domM.get("內銷_HR_接單量")).add(aaTool.getBigDecimal(expM.get("外銷_HR_接單量"))).setScale(0, BigDecimal.ROUND_HALF_UP));
		return result;
	}

    /**
     * 查詢庫存資料 整理成畫面需要的資料
     */
    public Map getStockDataFromDB(dsjccom dsCom, String endDate) throws Exception {
		Map result = new HashMap();
    	aajcYCATool aaTool = new aajcYCATool();
    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
    	StringBuilder sql = new StringBuilder();
    	sql.append("SELECT round(存貨,0) + round(管料,0) AS 原料庫存")
    	.append(",round(鋼管_存貨,0) + round(角扁鐵_存貨,0) AS 成品庫存")
    	.append(",round(鋼廠未交,0) + round(管料_鋼廠未交,0) AS 鋼廠未交")
    	.append(",round(結存,0) AS 結存 FROM TABLE(DB.FN_BQ042_STOCK('"+endDate+"'))");
    	Map m = aaDao.qrySql(sql.toString());
    	de318.logs("庫存資料", sql.toString());
    	
    	result.put("原料庫存", aaTool.getStr(m.get("原料庫存")));
    	//成品庫存 = 鋼管_存貨 + 角扁鐵_存貨
    	result.put("成品庫存", aaTool.getStr(m.get("成品庫存")));
    	//鋼廠未交 = 鋼廠未交 + 管料_鋼廠未交
    	result.put("鋼廠未交", aaTool.getStr(m.get("鋼廠未交")));
    	result.put("結存", aaTool.getStr(m.get("結存")));
		return result;
	}
    
    /**
     * 查詢製造/機台/稼動資料 整理成畫面需要的資料
     */
    public List getMachineDataFromDB(dsjccom dsCom, String yyyymm) throws Exception {
    	Map<String,HashMap<String,String>> resultM = new HashMap();
    	aajcYCATool aaTool = new aajcYCATool();
    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
    	//製造資料
		StringBuilder sql = new StringBuilder();
		sql.append(" SELECT a.廠區 ")
		.append("         , a.廠區名稱 ")
		.append("         , round(sum(a.原料重量-a.餘退重量-a.接頭重量-a.原料不良重量-a.廢管重量)*100/sum(a.原料重量-a.餘退重量), 2) AS 成材率 ")
		.append("         , round(sum(a.Q型態良品重量)*100/sum(a.原料重量-a.餘退重量), 2) AS 良品率 ")
		.append(" FROM DB.IPQ111_製造日報 a  ")
		.append(" WHERE a.完工日期 LIKE '"+yyyymm+"%' GROUP BY a.廠區, a.廠區名稱 WITH UR");
		Map[] prodMs = aaDao.qrySqlAll(sql.toString());
		de318.logs("製造資料", sql.toString());
		for(int i=0; i<prodMs.length; i++) {
			Map map = prodMs[i];
			String factoryId = aaTool.getStr(map.get("廠區"));
			HashMap<String,String> mm;
			if(resultM.containsKey(factoryId)) {
				mm = resultM.get(factoryId);
			}else {
				mm = new HashMap();
				mm.put("factoryId", factoryId);
				mm.put("factoryName", aaTool.getStr(map.get("廠區名稱")));
			}
			mm.put("yieldRate", aaTool.getBigDecimal(map.get("成材率")).setScale(1,BigDecimal.ROUND_HALF_UP).toString());
			mm.put("goodRate", aaTool.getBigDecimal(map.get("良品率")).setScale(1,BigDecimal.ROUND_HALF_UP).toString());
			resultM.put(factoryId, mm);
		}
		
		//機台數量
		sql.setLength(0);
		sql.append(" SELECT SUBSTR(a.機台代號,1,1) AS 廠區 ")
		.append("          , a.廠區 AS 廠區名稱 ")
		.append("          , SUM(CASE WHEN a.機台特性='A' THEN 1 ELSE 0 END) AS 製管機台數 ")
		.append("          , SUM(CASE WHEN a.機台特性='B' THEN 1 ELSE 0 END) AS 加工機台數 ")
		.append("          , SUM(CASE WHEN a.機台特性='C' THEN 1 ELSE 0 END) AS 包裝機台數 ")
		.append("          , SUM(CASE WHEN a.機台特性 IN ('A','B','C') THEN 1 ELSE 0 END) AS 機台數 ")
		.append("  FROM DB.IWZPC1_製管機台 a ")
		.append("  WHERE a.是否委外<>'Y' AND a.是否停用<>'Y' ")
		.append("  GROUP BY SUBSTR(a.機台代號,1,1), a.廠區 ");
		Map[] machineM = aaDao.qrySqlAll(sql.toString());
		de318.logs("機台數量", sql.toString());
		for(int i=0; i<machineM.length; i++) {
			Map map = machineM[i];
			String factoryId = aaTool.getStr(map.get("廠區"));
			HashMap<String,String> mm;
			if(resultM.containsKey(factoryId)) {
				mm = resultM.get(factoryId);
			}else {
				mm = new HashMap();
				mm.put("factoryId", factoryId);
				mm.put("factoryName", aaTool.getStr(map.get("廠區名稱")));
			}
			mm.put("status","");  //先不看機台運行狀態
			mm.put("machineCount", aaTool.getStr(map.get("製管機台數")));
			resultM.put(factoryId, mm);
		}
		//稼動率
		sql.setLength(0);
		sql.append(" SELECT a.廠區 ")
		.append("         , a.廠區名稱 ")
		.append("         , round(sum(a.開機時數)*100.00/sum(a.上班時數), 0) AS 稼動率 ")
		.append("         , round(sum(a.開機時數)*100.00/sum(a.上班時數+a.無人+a.待料), 0) AS 稼動率_含無人待料 ")
		.append(" FROM DB.TBIPQ116 a  ")
		.append(" WHERE a.年月='"+yyyymm+"' ")
		.append(" GROUP BY a.廠區, a.廠區名稱 ");
		Map[] utilRateM = aaDao.qrySqlAll(sql.toString());
		de318.logs("稼動率", sql.toString());
		for(int i=0; i<utilRateM.length; i++) {
			Map map = utilRateM[i];
			String factoryId = aaTool.getStr(map.get("廠區"));
			HashMap<String,String> mm;
			if(resultM.containsKey(factoryId)) {
				mm = resultM.get(factoryId);
			}else {
				mm = new HashMap();
				mm.put("factoryId", factoryId);
				mm.put("factoryName", aaTool.getStr(map.get("廠區名稱")));
			}
			mm.put("utilizationRate", aaTool.getBigDecimal(map.get("稼動率")).setScale(0,BigDecimal.ROUND_HALF_UP).toString());
			mm.put("unmannedUtilRate", aaTool.getBigDecimal(map.get("稼動率_含無人待料")).setScale(0,BigDecimal.ROUND_HALF_UP).toString());
			resultM.put(factoryId, mm);
		}
		return new ArrayList(resultM.values());
	}
    
    /**
     * 整理成畫面需要的資料
     * @throws Exception 
     * @throws SQLException 
     */
    public Map getDashboardData(dsjccom dsCom, HttpServletRequest request) throws SQLException, Exception {
    	Map result = new HashMap();
    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
	    //畫面上沒有輸入日期，改抓TBAO061最大日期
    	String endDate = aaTool.getStr(request.getParameter("endDate_qry")).replaceAll("/","");
	    if("".equals(endDate))
	    	endDate = new dejc308().getCrntDateWFmt1();
	    
	    //內銷日期
	    String dateYM = aaTool.getWYearMonth(endDate);
		String domDate = dateYM + "01";
		Map dom = aaDao.qrySql("SELECT max(a.DATE) AS DATE FROM DB.TBAO031 a WHERE a.COMPID='yc' AND a.DATE<='"+endDate+"'");
		if(dom != null)
			domDate = aaTool.getStr(dom.get("DATE"));
		
		//外銷日期
		String expDate = dateYM + "01";
		Map exp = aaDao.qrySql("SELECT max(a.DATE) AS DATE FROM DB.TBAO041 a WHERE a.COMPID='yc' AND a.DATE<='"+endDate+"'");
		if(exp != null)
			expDate = aaTool.getStr(exp.get("DATE"));

	    //20260606，IV1報表目前滾到資料庫的最大日期
	    Map date = aaDao.qrySql("SELECT max(a.DATE) AS DATE FROM DB.TBAO061 a WHERE a.COMPID='yc' AND a.DATE<='"+endDate+"'");
		if(date != null)
			endDate = aaTool.getStr(date.get("DATE"));
	    
		de318.logs("日期", "orderDate="+endDate+",domDate="+domDate+",expDate="+expDate);
	    result.put("updateDate",endDate);
	    result.put("orderData",this.getOrderDataFromDB(dsCom, endDate, domDate, expDate));
	    result.put("inventoryData",this.getStockDataFromDB(dsCom, endDate));
	    //改成點擊到該折頁才抓取
	    //result.put("factoryList",this.getMachineDataFromDB(dsCom, endDate.substring(0, 6)));
	    return result;
	}
}
