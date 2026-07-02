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


public class bqjc0421{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjc0421.java,v 1.9 2026/06/25 02:13:34 02587 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc0421(dsjccom dsCom) {
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
	public Map gettabXZDataFromDB(dsjccom dsCom,Connection conCIC,String endDate, String domDate) throws Exception {
	    

	    Map result = new HashMap();
	    aajcYCATool aaTool = new aajcYCATool();
	    dejcQueryDAO dao = new dejcQueryDAO(dsCom, conCIC);


	    // 製造細項
	    
	    StringBuilder sql = new StringBuilder();
	    
	    sql.append(" SELECT ")
	       .append("     SUM(CASE WHEN 型態 IN ('Q1', 'Q6', 'QE') THEN 成材重量 ELSE 0 END) / 1000.0 AS Q產量, ")
	       .append("     SUM(CASE WHEN 表面 LIKE '%Y%' AND 表面 LIKE '%B%' THEN 成材重量 ELSE 0 END) / 1000.0 AS 光退產量, ")
	       .append("     CAST(SUM(原料重量 - 餘退重量 - 接頭重量 - 原料不良重量 - 廢管重量) * 100.0 / NULLIF(SUM(原料重量 - 餘退重量), 0) AS DECIMAL(18,2)) AS 當月成材率, ")
	       .append("     CAST(SUM(CASE WHEN 產出類別 = 'Q型態' THEN 原料重量 - 餘退重量 - 接頭重量 - 原料不良重量 - 廢管重量 ELSE 0 END) * 100.0 ")
	       .append("          / NULLIF(SUM(CASE WHEN 產出類別 = 'Q型態' THEN 原料重量 - 餘退重量 ELSE 0 END), 0) AS DECIMAL(18,2)) AS Q型態成材率, ")
	       .append("     CAST(SUM(CASE WHEN 產出類別 = 'Q型態' AND Q型態指標 = 'Y' THEN Q型態良品重量 WHEN 產出類別 = 'Q型態' THEN 良品支數重量 ELSE 0 END) * 100.0 ")
	       .append("          / NULLIF(SUM(CASE WHEN 產出類別 = 'Q型態' THEN 原料重量 - 餘退重量 ELSE 0 END), 0) AS DECIMAL(18,2)) AS Q良品率, ")
	       .append("     SUM(廢管重量 / 1000.0) AS 廢管重量, ")
	       .append("     SUM(成材重量 / 1000.0) AS 當月產量 ")
	       .append(" FROM dbo.IPQ111_製造日報 ")
	       .append(" WHERE 廠區名稱 = '溪州' ")
	       .append("   AND 完工日期 >= '" + domDate + "' ")
	       .append("   AND 完工日期 <= '" + endDate + "' ");
	    de318.logs("製造細項", sql.toString());
	    Map PQ = dao.getData(sql.toString());
	    result.putAll(PQ);
	    java.math.BigDecimal monthlyVol = aaTool.getBigDecimal(result.get("當月產量"));
	    result.put("當月產量",   aaTool.getBigDecimal(result.get("當月產量")).setScale(0, BigDecimal.ROUND_HALF_UP));
	    result.put("Q產量",     aaTool.getBigDecimal(result.get("Q產量")).setScale(0, BigDecimal.ROUND_HALF_UP));
	    result.put("光退產量",   aaTool.getBigDecimal(result.get("光退產量")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("廢管重量",   aaTool.getBigDecimal(result.get("廢管重量")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("當月成材率",  aaTool.getBigDecimal(result.get("當月成材率")).setScale(2, BigDecimal.ROUND_HALF_UP));
	    result.put("Q型態成材率", aaTool.getBigDecimal(result.get("Q型態成材率")).setScale(2, BigDecimal.ROUND_HALF_UP));
	    result.put("Q良品率",    aaTool.getBigDecimal(result.get("Q良品率")).setScale(2, BigDecimal.ROUND_HALF_UP));
	    result.put("Q型態占產量", monthlyVol == null || monthlyVol.compareTo(java.math.BigDecimal.ZERO) == 0 ? "0.0" : aaTool.format(aaTool.getBigDecimal(result.get("Q產量")).multiply(new java.math.BigDecimal(100)).divide(monthlyVol, 1, java.math.BigDecimal.ROUND_HALF_UP), "#0.0"));
	    result.put("光退占產量",  monthlyVol == null || monthlyVol.compareTo(java.math.BigDecimal.ZERO) == 0 ? "0.0" : aaTool.format(aaTool.getBigDecimal(result.get("光退產量")).multiply(new java.math.BigDecimal(100)).divide(monthlyVol, 1, java.math.BigDecimal.ROUND_HALF_UP), "#0.0"));
	    sql.setLength(0);
	    // 加工細項
	    
	    sql.append(" WITH Base AS ( ")
	    .append("     SELECT ")
	    .append("         SUM(CASE WHEN 重工原因 = '' THEN 良品重 / 1000.0 ELSE 0.0 END) AS 加工產量, ")
	    .append("         SUM(CASE WHEN 重工原因 = '' THEN 良品數 ELSE 0 END) AS 支數, ")
	    //重拋率
	    .append("         SUM(良品數) AS 總產出, ")
	    .append("         SUM(CASE WHEN 重工 = 'N' THEN 良品數 ELSE 0 END) AS 不含重工產出, ")
	    // 圓管
	    .append("         SUM(CASE WHEN 外徑2 = '0' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管不含重工, ")
	    // 方管
	    .append("         SUM(CASE WHEN 外徑2 <> '0' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 方管總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 <> '0' AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 方管不含重工, ")
	    // 圓管 50以下
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 <= 50.8 THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管50總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 <= 50.8 AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管50不含重工, ")
	    // 方管 58以下
	    .append("         SUM(CASE WHEN 外徑2 <> '0' AND 外徑1 <= 50.8 AND 外徑2 <= 50.8 THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 方管58總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 <> '0' AND 外徑1 <= 50.8 AND 外徑2 <= 50.8 AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 方管58不含重工, ")
	    // 圓管 50.8~76.2
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 > 50.8 AND 外徑1 <= 76.2 THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管76總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 > 50.8 AND 外徑1 <= 76.2 AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管76不含重工, ")
	    // 方管 60以上
	    .append("         SUM(CASE WHEN 外徑2 <> '0' AND 外徑1 >= 60 AND 外徑2 >= 60 THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 方管60總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 <> '0' AND 外徑1 >= 60 AND 外徑2 >= 60 AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 方管60不含重工, ")
	    // 圓管 76.2~101.6
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 > 76.2 AND 外徑1 <= 101.6 THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管101總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 > 76.2 AND 外徑1 <= 101.6 AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管101不含重工, ")
	    // 圓管 114以上
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 > 101.6 THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管114總產出, ")
	    .append("         SUM(CASE WHEN 外徑2 = '0' AND 外徑1 > 101.6 AND 重工 = 'N' THEN CAST(良品數 AS DECIMAL(18,4)) ELSE 0 END) AS 圓管114不含重工 ")
	    .append("     FROM dbo.IPQ121_加工日報 ")
	    .append("     WHERE 廠區名稱 = '溪州' AND 加工站 = 'PG01' ")
	    .append("       AND 完工日期 >= '" + domDate + "' AND 完工日期 <= '" + endDate + "' ")
	    .append(" ) ")
	    .append(" SELECT ")
	    .append("     加工產量, 支數, ")
	    .append("     COALESCE(CAST((總產出 - 不含重工產出) * 100.0 / NULLIF(總產出, 0) AS DECIMAL(18,2)), 0.00) AS 重拋率, ")
	    .append("     COALESCE(CAST((圓管總產出 - 圓管不含重工) * 100.0 / NULLIF(圓管總產出, 0) AS DECIMAL(18,2)), 0.00) AS 圓管重拋率, ")
	    .append("     COALESCE(CAST((方管總產出 - 方管不含重工) * 100.0 / NULLIF(方管總產出, 0) AS DECIMAL(18,2)), 0.00) AS 方管重拋率, ")
	    .append("     COALESCE(CAST((圓管50總產出 - 圓管50不含重工) * 100.0 / NULLIF(圓管50總產出, 0) AS DECIMAL(18,2)), 0.00) AS 圓管重拋率_50以下, ")
	    .append("     COALESCE(CAST((方管58總產出 - 方管58不含重工) * 100.0 / NULLIF(方管58總產出, 0) AS DECIMAL(18,2)), 0.00) AS 方管重拋率_58以下, ")
	    .append("     COALESCE(CAST((圓管76總產出 - 圓管76不含重工) * 100.0 / NULLIF(圓管76總產出, 0) AS DECIMAL(18,2)), 0.00) AS 圓管重拋率_50_8到76_2, ")
	    .append("     COALESCE(CAST((方管60總產出 - 方管60不含重工) * 100.0 / NULLIF(方管60總產出, 0) AS DECIMAL(18,2)), 0.00) AS 方管重拋率_60以上, ")
	    .append("     COALESCE(CAST((圓管101總產出 - 圓管101不含重工) * 100.0 / NULLIF(圓管101總產出, 0) AS DECIMAL(18,2)), 0.00) AS 圓管重拋率_76_2到101_6, ")
	    .append("     COALESCE(CAST((圓管114總產出 - 圓管114不含重工) * 100.0 / NULLIF(圓管114總產出, 0) AS DECIMAL(18,2)), 0.00) AS 圓管重拋率_114以上 ")
	    .append(" FROM Base ");
	    de318.logs("加工細項", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map WMP = dao.getData(sql.toString());
	    result.putAll(WMP);
	    result.put("加工產量", aaTool.getBigDecimal(result.get("加工產量")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("重拋率",   aaTool.getBigDecimal(result.get("重拋率")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("圓管重拋率",   aaTool.getBigDecimal(result.get("圓管重拋率")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("方管重拋率",   aaTool.getBigDecimal(result.get("方管重拋率")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("圓管重拋率_50以下",   aaTool.getBigDecimal(result.get("圓管重拋率_50以下")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("方管重拋率_58以下",   aaTool.getBigDecimal(result.get("方管重拋率_58以下")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("圓管重拋率_50_8到76_2",   aaTool.getBigDecimal(result.get("圓管重拋率_50_8到76_2")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("方管重拋率_60以上",   aaTool.getBigDecimal(result.get("方管重拋率_60以上")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("圓管重拋率_76_2到101_6",   aaTool.getBigDecimal(result.get("圓管重拋率_76_2到101_6")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("圓管重拋率_114以上",   aaTool.getBigDecimal(result.get("圓管重拋率_114以上")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    
	    sql.setLength(0);
	    // 可用噴槍
	    sql.append(" SELECT SUM(QTY) AS 可用噴槍庫存 FROM dbo.IMIRB WHERE FACID = 'B' AND MATNO = '0700000001' ");
	    de318.logs("噴槍庫存", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map GUN = dao.getData(sql.toString());
	    result.putAll(GUN);

	    sql.setLength(0);
	    // 人力
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
	       .append("     SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備','行政') AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 其他台籍人數, ")
	       .append("     SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備','行政') AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 其他外籍人數 ")
	       .append(" FROM dbo.H01_人力結構 ")
	       .append(" WHERE 服務 = '在職' AND 廠別 = '總公司(溪州廠)'; ");
	    de318.logs("人力結構", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map HUM = dao.getData(sql.toString());
	    if (HUM != null) {
	    	 java.math.BigDecimal mTaiwan  = aaTool.getBigDecimal(HUM.get("製造台籍人數"));
		        java.math.BigDecimal mForeign = aaTool.getBigDecimal(HUM.get("製造外籍人數"));
		        java.math.BigDecimal pTaiwan  = aaTool.getBigDecimal(HUM.get("加工台籍人數"));
		        java.math.BigDecimal pForeign = aaTool.getBigDecimal(HUM.get("加工外籍人數"));
		        java.math.BigDecimal mbTaiwan  = aaTool.getBigDecimal(HUM.get("廠務台籍人數"));
		        java.math.BigDecimal mbForeign = aaTool.getBigDecimal(HUM.get("廠務外籍人數"));
		        java.math.BigDecimal eTaiwan  = aaTool.getBigDecimal(HUM.get("生管成品台籍人數"));
		        java.math.BigDecimal eForeign = aaTool.getBigDecimal(HUM.get("生管成品外籍人數"));
		        java.math.BigDecimal m41Taiwan  = aaTool.getBigDecimal(HUM.get("設備台籍人數"));
		        java.math.BigDecimal m41Foreign = aaTool.getBigDecimal(HUM.get("設備外籍人數"));
		        java.math.BigDecimal elseTaiwan  = aaTool.getBigDecimal(HUM.get("其他台籍人數"));
		        java.math.BigDecimal elseForeign = aaTool.getBigDecimal(HUM.get("其他外籍人數"));
		        
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
		        HUM.put("外籍總人數", mForeign.add(pForeign).add(mbForeign).add(eForeign).add(m41Foreign).add(elseForeign));
	    }
	    result.putAll(HUM);

	    sql.setLength(0);
	    // 日產量 Top5
	    sql.append(" SELECT TOP 5 ")
	       .append("     CONVERT(VARCHAR(10), CAST(完工日期 AS DATE), 120) AS 完工日期, ")
	       .append("     SUM(成材重量) AS 每日成材重量, ")
	       .append("     DENSE_RANK() OVER (ORDER BY SUM(成材重量) DESC) AS 產量名次 ")
	       .append(" FROM dbo.IPQ111_製造日報 ")
	       .append(" WHERE 廠區名稱 = '溪州' ")
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
	    sql.append(" SELECT TOP 5 機台, SUM(廢管重量) AS 廢管 ")
	       .append(" FROM dbo.IPQ111_製造日報 ")
	       .append(" WHERE 廠區名稱 = '溪州' ")
	       .append("   AND 完工日期 >= '" + domDate + "' ")
	       .append("   AND 完工日期 <= '" + endDate + "' ")
	       .append(" GROUP BY 機台 ORDER BY SUM(廢管重量) DESC ");
	    de318.logs("廢重機台", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] disuse1 = dao.getDatas(sql.toString());
	    result.put("廢重機台", java.util.Arrays.asList(disuse1));

	    sql.setLength(0);
	    // 機故時數 Top5
	    sql.append(" SELECT TOP 5 機台, ")
	       .append("     (SUM(ISNULL(磨故,0)) + SUM(ISNULL(機故,0)) + SUM(ISNULL(焊故,0))) AS 機故時間 ")
	       .append(" FROM dbo.IPQ116 ")
	       .append(" WHERE 區域 = 'TW' and 廠區 ='B' ")
	       .append("   AND 年月 >= CONVERT(VARCHAR(6), GETDATE(), 112) ")
	       .append("   AND 年月 <= CONVERT(VARCHAR(8), GETDATE(), 112) ")
	       .append(" GROUP BY 機台 ORDER BY 機故時間 DESC ");
	    de318.logs("機故時數", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] failure = dao.getDatas(sql.toString());
	    result.put("機故時數",  java.util.Arrays.asList(failure));

	    sql.setLength(0);
	    sql.append(" WITH PreparedData AS ( ")
	       .append("     SELECT ")
	       .append("         停機原因, ")
	       .append("         CAST(停機時間 AS DECIMAL(18,4)) AS 停機時間_DEC, ")
	       .append("         CASE WHEN 機台 LIKE 'BF%' OR 機台 LIKE 'BQ%' THEN 1 ")
	       .append("              WHEN 機台 LIKE 'BN%' OR 機台 LIKE 'BG%' THEN 2 ")
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
	    result.put("加工停機", processList);

	    sql.setLength(0);
	    sql.append(" WITH BaseMetrics AS ( ")
	       .append("     SELECT ")
	       .append("         SUM(CASE WHEN 呆滯天數 <= 90  AND 站別 IN ('PG01','PD02','PG03','PC01') THEN 數量 ELSE 0 END) AS 小於90天, ")
	       .append("         SUM(CASE WHEN 呆滯天數 > 90 AND 呆滯天數 < 180 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN 數量 ELSE 0 END) AS 從90到180天, ")
	       .append("         SUM(CASE WHEN 呆滯天數 > 180 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN 數量 ELSE 0 END) AS 大於180天, ")
	       .append("         COUNT(CASE WHEN 站別 = 'PD02' THEN 1 END) AS 待手工筆數, ")
	       .append("         SUM(CASE WHEN 站別 = 'PD02' THEN 數量 ELSE 0 END) AS 待手工矯直, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 10.0  AND 外徑1 < 30.0  AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_10到30, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 30.0  AND 外徑1 < 50.0  AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_30到50, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 50.0  AND 外徑1 < 60.0  AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_50到60, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 60.0  AND 外徑1 < 70.0  AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_60到70, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 70.0  AND 外徑1 < 90.0  AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_70到90, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 90.0  AND 外徑1 < 120.0 AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_90到120, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 120.0 AND 外徑1 < 180.0 AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_120到180, ")
	       .append("         SUM(CASE WHEN 外徑1 >= 180.0 AND 外徑1 < 220.0 AND 外徑2 = 0 AND 站別 IN ('PG01','PD02','PG03','PC01') THEN CAST(材積 AS DECIMAL(18,4)) ELSE 0 END) AS 材積_180到220 ")
	       .append("     FROM dbo.IPQ123_加工未完 WITH (NOLOCK) ")
	       .append("     WHERE 廠區名稱 = '溪州' ")
	       .append("       AND 日期 = '" + endDate + "' ")
	       .append(" ), ")
	       .append(" TotalVolume AS ( ")
	       .append("     SELECT *, ")
	       .append("         (材積_10到30 + 材積_30到50 + 材積_50到60 + 材積_60到70 + 材積_70到90 + 材積_90到120 + 材積_120到180 + 材積_180到220) AS 總材積 ")
	       .append("     FROM BaseMetrics ")
	       .append(" ) ")
	       .append(" SELECT *, ")
	       .append("     CAST(材積_10到30   * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_10到30, ")
	       .append("     CAST(材積_30到50   * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_30到50, ")
	       .append("     CAST(材積_50到60   * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_50到60, ")
	       .append("     CAST(材積_60到70   * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_60到70, ")
	       .append("     CAST(材積_70到90   * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_70到90, ")
	       .append("     CAST(材積_90到120  * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_90到120, ")
	       .append("     CAST(材積_120到180 * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_120到180, ")
	       .append("     CAST(材積_180到220 * 100.0 / NULLIF(總材積, 0) AS DECIMAL(18,2)) AS 佔比_180到220 ")
	       .append(" FROM TotalVolume ");

	    de318.logs("呆滯與材積合併查詢", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map combinedData = dao.getData(sql.toString());
	    
	    if (combinedData != null) {
	        result.putAll(combinedData);
	    }
	    
	    java.math.BigDecimal low90 = aaTool.getBigDecimal(result.get("小於90天"));
	    java.math.BigDecimal mid180 = aaTool.getBigDecimal(result.get("從90到180天"));
	    result.put("總呆滯品支數", low90.add(mid180).setScale(0, java.math.BigDecimal.ROUND_HALF_UP));
	    
	    
	    sql.setLength(0);
	    //待加工
	    sql.append(" SELECT  ")
	       .append(" CONVERT(DATETIME, CAST([日期] AS VARCHAR(8)), 112) AS [time],  ")
	       .append("  SUM([重量] / 1000.0) AS [不含品檢]  ")
	       .append("  FROM dbo.[IPQ123_加工未完] ")
	       .append("  WHERE [廠區名稱] IN ('溪州')  ")
	       .append("  AND [站別名稱] NOT IN ('切斷', '線外ET', '品檢')  ")
	       .append("  AND [日期] >= CONVERT(VARCHAR(8), DATEADD(DAY, -90, GETDATE()), 112) ")
	       .append("  GROUP BY  [日期] ")
	       .append("  ORDER BY [日期]; ");
	    de318.logs("加工待處理SQL", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map[] waitprocessing = dao.getDatas(sql.toString());
	    result.put("待加工", java.util.Arrays.asList(waitprocessing));
	    
	    sql.setLength(0);
	    //總庫存
	    sql.append(" SELECT  ")
	       .append(" A.年月,A.溪州總庫存, A.溪州大原料鋼捲, A.溪州成品鋼板捲, A.溪州管料, A.溪州次級, B.溪州配管, B.溪州構造管, B.溪州扁鐵, B.溪州角鐵, B.溪州無縫管 ")
	       .append(" FROM V_IPQ7R4_原料存貨分析_廠區 A  ")
	       .append(" INNER JOIN V_IPQ7R4_鋼管存貨分析_廠區 B  ")
	       .append(" ON A.年月 = B.年月   ")
	       .append(" WHERE A.年月 = LEFT('" + endDate + "', 6); ");

	    de318.logs("總庫存SQL", sql.toString());
	    dao = new dejcQueryDAO(dsCom, conCIC);
	    Map stock = dao.getData(sql.toString());
	    result.putAll(stock);	
	    result.put("溪州大原料鋼捲",   aaTool.getBigDecimal(result.get("溪州大原料鋼捲")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州成品鋼板捲",   aaTool.getBigDecimal(result.get("溪州成品鋼板捲")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州管料",   aaTool.getBigDecimal(result.get("溪州管料")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州扁鐵",   aaTool.getBigDecimal(result.get("溪州扁鐵")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州次級",   aaTool.getBigDecimal(result.get("溪州次級")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州構造管",   aaTool.getBigDecimal(result.get("溪州構造管")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州配管",   aaTool.getBigDecimal(result.get("溪州配管")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州角鐵",   aaTool.getBigDecimal(result.get("溪州角鐵")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    result.put("溪州無縫管",   aaTool.getBigDecimal(result.get("溪州無縫管")).setScale(1, BigDecimal.ROUND_HALF_UP));
	    BigDecimal totalStock = aaTool.getBigDecimal(result.get("溪州總庫存"))  // 原本的總庫存（大原料）
	    	    .add(aaTool.getBigDecimal(result.get("溪州次級")))
	    	    .add(aaTool.getBigDecimal(result.get("溪州配管")))
	    	    .add(aaTool.getBigDecimal(result.get("溪州構造管")))
	    	    .add(aaTool.getBigDecimal(result.get("溪州扁鐵")))
	    	    .add(aaTool.getBigDecimal(result.get("溪州角鐵")))
	    	    .add(aaTool.getBigDecimal(result.get("溪州無縫管")));
	    result.put("溪州總庫存", totalStock.setScale(0, BigDecimal.ROUND_HALF_UP));
	    return result;
	}

    public Map getDashboardDataXZ(dsjccom dsCom, HttpServletRequest request) throws SQLException, Exception {
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
		    result.put("XZData",this.gettabXZDataFromDB(dsCom,conCIC, endDate, domDate));
	
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
