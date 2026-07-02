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
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import com.icsc.aa.yc.dao.aajcYCADAO;
import com.icsc.aa.yc.util.aajcYCATool;
import com.icsc.dpms.de.dejc308;
import com.icsc.dpms.de.dejc318;
import com.icsc.dpms.ds.dsjccom;

public class bqjc052{
	private static final String PROCID = "BQJC052";
	public final static String CLASS_VERSION = "$Id: bqjc052.java,v 1.4 2026/07/01 02:12:47 02182 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc052(dsjccom dsCom) {
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
     * 查詢各廠總數 整理成畫面需要的資料
     */
    public Map getDashboardDataOV(dsjccom dsCom) throws Exception {
		Map result = new HashMap();
    	aajcYCATool aaTool = new aajcYCATool();
    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
    	
	    //各廠天車數量含合計
    	String craSQL = "SELECT "
    			+ "    CASE  "
    			+ "        WHEN GROUPING(FAC) = 1 THEN '合計_天車' "
    			+ "        ELSE FAC||'_天車' "
    			+ "    END AS cntType, "
    			+ "    COUNT(DISTINCT MEM02NO) AS CNT "
    			+ "FROM "
    			+ "( "
    			//SQL 資料主體
    			+ "SELECT  "
    			+ "a.MEM02NO, a.MEM02NAME, a.EQFTNO, b.MEMC1NAME, b.MEMC1NO, "
    			+ "x1.FIELD2 AS FAC "
    			+ "FROM db.TBMEM02 a "
    			+ "LEFT JOIN db.TBMEMC1 b ON a.MEMC1ID=b.MEMC1ID "
    			+ "LEFT JOIN db.TBDE23 x1 ON x1.TABID='WESTRANSLOCATE' AND x1.FIELD1=a.MEM02NOA "
    			+ "WHERE   a.STATE='A' AND b.MEMC1NO LIKE 'CRA%' AND b.MEMC1NO NOT IN ('CRA','CRA00','CRA04','CRA21')"
    			/**資料主體結尾**************************/
    			+ ") "
    			+ "GROUP BY ROLLUP(FAC) with ur ; "
    			+ "";
    	de318.logs("天車統計", craSQL);
    	System.out.println(craSQL);
    	Map[] m = aaDao.qrySqlAll(craSQL);
    	Map craData = new LinkedHashMap();
    	for(int i=0;i<m.length;i++) {
    		Map rowData = m[i];
    		craData.put(rowData.get("CNTTYPE").toString(), rowData.get("CNT").toString());
    	}
    	result.put("craOV",craData);
    	//各廠機台數量含合計
    	String machineSQL = "SELECT "
    			+ "    CASE  "
    			+ "        WHEN GROUPING(FAC) = 1 THEN '合計_機台' "
    			+ "        ELSE FAC||'_機台'  "
    			+ "    END AS cntType, "
    			+ "    COUNT(DISTINCT 機台碼) AS CNT "
    			+ "FROM ( "
    			//SQL 資料主體
    			+ " SELECT a.* "
    			+ " ,x1.FIELD2 AS fac  "
    			+ " FROM DB.設備處_設備清單 a "
    			+ " LEFT JOIN db.TBDE23 x1 ON x1.TABID='WESTRANSLOCATE' AND x1.FIELD1=a.廠區 "
    			/**資料主體結尾**************************/
    			+ ") "
    			+ "GROUP BY ROLLUP(FAC) with ur ;";
    	de318.logs("機台統計", machineSQL);
    	System.out.println(machineSQL);
    	Map[] m2 = aaDao.qrySqlAll(machineSQL);
    	Map machineData = new LinkedHashMap();
    	for(int i=0;i<m2.length;i++) {
    		Map rowData = m2[i];
    		machineData.put(rowData.get("CNTTYPE").toString(), rowData.get("CNT").toString());
    	}
    	result.put("machineOV",machineData);
    	
    	//各廠堆高機數量含合計
    	String fklSQL = "SELECT "
    			+ "    CASE  "
    			+ "        WHEN GROUPING(FAC) = 1 THEN '合計_堆高' "
    			+ "        ELSE FAC||'_堆高' "
    			+ "    END AS cntType, "
    			+ "    COUNT(DISTINCT MEM02NO) AS CNT "
    			+ "FROM "
    			+ "( "
    			//SQL 資料主體
    			+ "SELECT  "
    			+ "a.MEM02NO, a.MEM02NAME, a.EQFTNO, b.MEMC1NAME, b.MEMC1NO, "
    			+ "x1.FIELD2 AS fac  "
    			+ "FROM db.TBMEM02 a "
    			+ "LEFT JOIN db.TBMEMC1 b ON a.MEMC1ID=b.MEMC1ID "
    			+ "LEFT JOIN db.TBDE23 x1 ON x1.TABID='WESTRANSLOCATE' AND x1.FIELD1=a.MEM02NOA "
    			+ "WHERE   a.STATE='A' AND b.MEMC1NO LIKE 'FKL%' AND b.MEMC1NO NOT IN ('FKL','FKL01')"
    			/**資料主體結尾**************************/
    			+ ") "
    			+ "GROUP BY ROLLUP(FAC) with ur ; "
    			+ "";
    	de318.logs("堆高機統計", fklSQL);
    	System.out.println(fklSQL);
    	Map[] m3 = aaDao.qrySqlAll(fklSQL);
    	Map fklData = new LinkedHashMap();
    	for(int i=0;i<m3.length;i++) {
    		Map rowData = m3[i];
    		fklData.put(rowData.get("CNTTYPE").toString(), rowData.get("CNT").toString());
    	}
    	result.put("fklOV",fklData);
    	
		return result;
	}
    
    /**
     * 查詢某廠總數 整理成畫面需要的資料
     */
    public Map getDashboardDataByFac(dsjccom dsCom,String fac) throws Exception {
		Map result = new HashMap();
    	aajcYCATool aaTool = new aajcYCATool();
    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
    	
	    //各廠天車數量含合計
    	String craSQL = "SELECT "
    			+ "    CASE  "
    			+ "        WHEN GROUPING(MEMC1NAME) = 1 THEN '合計_天車' "
    			+ "        ELSE MEMC1NAME  "
    			+ "    END AS cntType, "
    			+ "    COUNT(DISTINCT MEM02NO) AS CNT "
    			+ "FROM "
    			+ "( "
    			//SQL 資料主體
    			+ "SELECT  "
    			+ "a.MEM02NO, a.MEM02NAME, a.EQFTNO, b.MEMC1NAME, b.MEMC1NO, "
    			+ "x1.FIELD2 AS FAC "
    			+ "FROM db.TBMEM02 a "
    			+ "LEFT JOIN db.TBMEMC1 b ON a.MEMC1ID=b.MEMC1ID "
    			+ "LEFT JOIN db.TBDE23 x1 ON x1.TABID='WESTRANSLOCATE' AND x1.FIELD1=a.MEM02NOA "
    			+ "WHERE   a.STATE='A' AND b.MEMC1NO LIKE 'CRA%' AND b.MEMC1NO NOT IN ('CRA','CRA00','CRA04','CRA21')"
    			+ "      AND MEM02NOA='"+fac+"' "
    			/**資料主體結尾**************************/
    			+ ") "
    			+ "GROUP BY ROLLUP(MEMC1NAME);";
    	Map[] m = aaDao.qrySqlAll(craSQL);
    	List craData = Arrays.asList(m);
    	result.put("craFac",craData);
    	//各廠機台機數量含合計
    	String machineSQL = ""
    			//SQL 資料主體
    			+"SELECT a.* "
    			+ ",x1.FIELD2 AS fac  "
    			+ "FROM DB.設備處_設備清單 a "
    			+ "LEFT JOIN db.TBDE23 x1 ON x1.TABID='WESTRANSLOCATE' AND x1.FIELD1=a.廠區 "
    			+ "WHERE a.廠區='"+fac+"' ";
    			/**資料主體結尾**************************/
    	de318.logs("機台統計", machineSQL);
    	System.out.println(machineSQL);
    	Map[] m2 = aaDao.qrySqlAll(machineSQL);
    	List machineData = Arrays.asList(m2);
    	result.put("machineFac",machineData);
    	//各廠堆高機數量含合計
    	String fklSQL = "SELECT "
    			+ "    CASE  "
    			+ "        WHEN GROUPING(MEMC1NAME) = 1 THEN '合計_堆高' "
    			+ "        ELSE MEMC1NAME  "
    			+ "    END AS cntType, "
    			+ "    COUNT(DISTINCT MEM02NO) AS CNT "
    			+ "FROM "
    			+ "( "
    			//SQL 資料主體
    			+ "SELECT  "
    			+ "a.MEM02NO, a.MEM02NAME, a.EQFTNO, b.MEMC1NAME, b.MEMC1NO, "
    			+ "x1.FIELD2 AS fac  "
    			+ "FROM db.TBMEM02 a "
    			+ "LEFT JOIN db.TBMEMC1 b ON a.MEMC1ID=b.MEMC1ID "
    			+ "LEFT JOIN db.TBDE23 x1 ON x1.TABID='WESTRANSLOCATE' AND x1.FIELD1=a.MEM02NOA "
    			+ "WHERE   a.STATE='A' AND b.MEMC1NO LIKE 'FKL%' AND b.MEMC1NO NOT IN ('FKL','FKL01')"
    			+ "      AND MEM02NOA='"+fac+"' "
    			/**資料主體結尾**************************/
    			+ ") "
    			+ "GROUP BY ROLLUP(MEMC1NAME);";
    	Map[] m3 = aaDao.qrySqlAll(fklSQL);
    	List fklData = Arrays.asList(m3);
    	result.put("fklFac",fklData);
		return result;
	}
}
