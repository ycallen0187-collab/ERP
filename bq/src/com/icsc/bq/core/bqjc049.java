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

public class bqjc049{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjc049.java,v 1.6 2026/06/22 09:17:37 01681 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc049(dsjccom dsCom) {
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
     * 取得大看板所需的所有廠區數據
     */
    public Map getDashboardData(dsjccom dsCom, HttpServletRequest request) {
        Map dashboardData = new HashMap();
        String today = new dejc308().getCrntDateWFmt1();
        String thisYM = today.substring(0,6);
        String lastYM = aaTool.getNextNMonth(thisYM, -1);
        String startYM = aaTool.getNextNMonth(thisYM, -5);
        // 1. 系統更新時間
        dashboardData.put("updateDate", today);
        
        // 2. 呼叫各自工廠的私有抽離方法取得資料
        dashboardData.put("xzData", getPipeTubeDataFromDB(lastYM, thisYM, startYM).get(0));
        dashboardData.put("dl1Data", getDl1Data(lastYM, thisYM, startYM));
        dashboardData.put("dl2Data", getPipeTubeDataFromDB(lastYM, thisYM, startYM).get(1));

        return dashboardData;
    }
    
/*
 * =========================================================================================
 * Private Method (工廠資料抓取邏輯拆分區塊)
 * =========================================================================================
 */

    private List getPipeTubeDataFromDB(String lastYM, String thisYM, String startYM){
    	List result = new ArrayList();
    	Map xzData = new HashMap();
    	Map dl2Data = new HashMap();
    	result.add(xzData);
    	result.add(dl2Data);
    	try {
	    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
	    	StringBuilder sql = new StringBuilder("");
	    	//BY月份共6筆 溪州斗二成材率良品率半年度的趨勢
	    	sql.append(" SELECT  ");
	    	sql.append(" 月份 ");
	    	sql.append(" ,round(sum(x.溪州成材量)*1.00000/sum(x.溪州投入量),4)*100 AS 溪州成材率 ");
	    	sql.append(" ,round(sum(x.溪州良品量)*1.00000/sum(x.溪州投入量),4)*100 AS 溪州良品率 ");
	    	sql.append(" ,round(sum(x.斗二成材量)*1.00000/sum(x.斗二投入量),4)*100 AS 斗二成材率 ");
	    	sql.append(" ,round(sum(x.斗二良品量)*1.00000/sum(x.斗二投入量),4)*100 AS 斗二良品率 ");
	    	sql.append(" FROM (SELECT ");
	    	sql.append(" substr(a.enddate,1,6) AS 月份  ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' THEN a.GOODINPUTWGT ELSE 0 END AS 溪州成材量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' THEN a.INPUTWGT ELSE 0 END AS 溪州投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' THEN a.S_WGT ELSE 0 END AS 溪州良品量 ");
	    	sql.append("  ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' THEN a.GOODINPUTWGT ELSE 0 END AS 斗二成材量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' THEN a.INPUTWGT ELSE 0 END AS 斗二投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' THEN a.S_WGT ELSE 0 END AS 斗二良品量 ");
	    	sql.append(" FROM db.tbucM111 a  ");
	    	sql.append(" WHERE a.COMPID='yc'  ");
	    	sql.append(" AND substr(a.enddate,1,6) between '"+startYM+"' and '"+thisYM+"'  ");
	    	sql.append(" and a.LOCATE in ('B', 'D')) x ");
	    	sql.append(" GROUP BY 月份 WITH UR ");
	    	de318.logs("溪州斗二成材率良品率", sql.toString());
	    	Map[] mArr = aaDao.qrySqlAll(sql.toString());
	    	List xzMonths = new ArrayList();     //趨勢圖X軸月份
	    	List yieldTrend = new ArrayList();   //溪州成材率趨勢
	    	List yieldTrendD = new ArrayList();  //斗二成材率趨勢
	    	List qualityTrend = new ArrayList(); //溪州良品率趨勢
	    	List qualityTrendD = new ArrayList();//斗二良品率趨勢
	    	for(int i=0; i<mArr.length; i++) {
	    		Map m = mArr[i];
	    		String month = aaTool.getStr(m.get("月份"));
	    		int xMonth = Integer.parseInt(month.substring(4));
	    		String goodRateB = aaTool.format(m.get("溪州成材率"),"00.00");
	    		String goodRateD = aaTool.format(m.get("斗二成材率"),"00.00");
	    		String SRateB = aaTool.format(m.get("溪州良品率"),"00.00");
	    		String SRateD = aaTool.format(m.get("斗二良品率"),"00.00");
	    		String prefix = "";
	    		if(lastYM.equals(month)) {
	    			prefix="LAST_";
	    		}
	    		if(lastYM.equals(month) || thisYM.equals(month)) {
	    			xzData.put(prefix+"MAIN_YIELD", goodRateB);   // 當月製造成材率
	    	        xzData.put(prefix+"AVG_QUALITY", SRateB);  // 當月每月平均良率
	    	        dl2Data.put(prefix+"MAIN_YIELD", goodRateD);     // 製造成材率實績
	    	        dl2Data.put(prefix+"DAILY_QUALITY", SRateD);  // 製造良品率（每月平均）實績
	    		}
	    		xzMonths.add(xMonth+"月");
	    		yieldTrend.add(new Double(goodRateB));   //溪州成材率趨勢
	    		yieldTrendD.add(new Double(goodRateD));  //斗二成材率趨勢
	    		qualityTrend.add(new Double(SRateB));  //溪州良品率趨勢
	    		qualityTrendD.add(new Double(SRateD)); //斗二良品率趨勢
		    }
	    	xzData.put("TREND_MONTHS", xzMonths);
	    	dl2Data.put("TREND_MONTHS", xzMonths);
	    	xzData.put("TREND_YIELD_LIST", yieldTrend);
	    	dl2Data.put("TREND_YIELD_LIST", yieldTrendD);
	    	xzData.put("TREND_QUALITY_LIST", qualityTrend);
	    	dl2Data.put("TREND_QUALITY_LIST", qualityTrendD);
	    	
	    	//共2筆BY月份 溪州斗二細項良品率
	    	sql.setLength(0);
	    	sql.append(" SELECT  ");
	    	sql.append(" 月份 ");
	    	sql.append(" ,round(sum(x.溪州成材量)*1.00000/sum(x.溪州投入量),4)*100 AS 溪州成材率 ");
	    	sql.append(" ,round(sum(x.溪州雷射良品量)*1.00000/sum(x.溪州雷射投入量),4)*100 AS 溪州雷射良品率 ");
	    	sql.append(" ,round(sum(x.溪州大方扁良品量)*1.00000/sum(x.溪州大方扁投入量),4)*100 AS 溪州大方扁良品率 ");
	    	sql.append(" ,round(sum(x.溪州其他鋼管良品量)*1.00000/sum(x.溪州其他鋼管投入量),4)*100 AS 溪州其他鋼管良品率 ");
	    	sql.append(" ,round(sum(x.斗二成材量)*1.00000/sum(x.斗二投入量),4)*100 AS 斗二成材率 ");
	    	sql.append(" ,round(sum(x.斗二雷射良品量)*1.00000/sum(x.斗二雷射投入量),4)*100 AS 斗二雷射良品率 ");
	    	sql.append(" ,round(sum(x.斗二6吋以上良品量)*1.00000/sum(x.斗二6吋以上投入量),4)*100 AS 斗二6吋以上良品率 ");
	    	sql.append(" ,round(sum(x.斗二其他鋼管良品量)*1.00000/sum(x.斗二其他鋼管投入量),4)*100 AS 斗二其他鋼管良品率 ");
	    	sql.append(" FROM (SELECT ");
	    	sql.append(" substr(a.enddate,1,6) AS 月份  ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' THEN a.GOODINPUTWGT ELSE 0 END AS 溪州成材量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' THEN a.INPUTWGT ELSE 0 END AS 溪州投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' AND a.ISLASER='Y' AND a.MACHINEID IN (SELECT FIELD1 FROM db.tbde23 WHERE TABID='FIBERLASERMACHINE') THEN a.S_WGT ELSE 0 END AS 溪州雷射良品量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' AND a.ISLASER='Y' AND a.MACHINEID IN (SELECT FIELD1 FROM db.tbde23 WHERE TABID='FIBERLASERMACHINE') THEN a.INPUTWGT ELSE 0 END AS 溪州雷射投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' AND a.MACHINEID IN ('BF32','BF33','BF34','BF35','BF56','BF75') THEN a.S_WGT ELSE 0 END AS 溪州大方扁良品量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' AND a.MACHINEID IN ('BF32','BF33','BF34','BF35','BF56','BF75') THEN a.INPUTWGT ELSE 0 END AS 溪州大方扁投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' AND a.MACHINEID NOT IN ('BF32','BF33','BF34','BF35','BF56','BF75') AND a.ISLASER<>'Y' AND a.INVTYPE NOT IN ('Q1','QE','L') THEN a.S_WGT ELSE 0 END AS 溪州其他鋼管良品量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'B' AND a.MACHINEID NOT IN ('BF32','BF33','BF34','BF35','BF56','BF75') AND a.ISLASER<>'Y' AND a.INVTYPE NOT IN ('Q1','QE','L') THEN a.INPUTWGT ELSE 0 END AS 溪州其他鋼管投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' THEN a.GOODINPUTWGT ELSE 0 END AS 斗二成材量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' THEN a.INPUTWGT ELSE 0 END AS 斗二投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' AND a.PIPEDIAMETERI>=152.4 AND a.INVTYPE NOT IN ('Q1','QE') AND a.ISLASER<>'Y' AND a.BELONGCOST NOT IN ('MD13','ND13') THEN a.S_WGT ELSE 0 END AS 斗二6吋以上良品量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' AND a.PIPEDIAMETERI>=152.4 AND a.INVTYPE NOT IN ('Q1','QE') AND a.ISLASER<>'Y' AND a.BELONGCOST NOT IN ('MD13','ND13') THEN a.INPUTWGT ELSE 0 END AS 斗二6吋以上投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' AND a.ISLASER='Y' THEN a.S_WGT ELSE 0 END AS 斗二雷射良品量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' AND a.ISLASER='Y' THEN a.INPUTWGT ELSE 0 END AS 斗二雷射投入量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' AND a.PIPEDIAMETERI<152.4 AND a.INVTYPE NOT IN ('Q1','QE') AND a.ISLASER<>'Y' AND a.BELONGCOST NOT IN ('MD13','ND13') THEN a.S_WGT ELSE 0 END AS 斗二其他鋼管良品量 ");
	    	sql.append(" ,CASE WHEN a.LOCATE = 'D' AND a.PIPEDIAMETERI<152.4 AND a.INVTYPE NOT IN ('Q1','QE') AND a.ISLASER<>'Y' AND a.BELONGCOST NOT IN ('MD13','ND13')  THEN a.INPUTWGT ELSE 0 END AS 斗二其他鋼管投入量 ");
	    	sql.append(" FROM db.tbucM111 a  ");
	    	sql.append(" WHERE a.COMPID='yc' AND substr(a.enddate,1,6) IN ('"+lastYM+"','"+thisYM+"') and a.LOCATE in ('B', 'D')) x ");
	    	sql.append(" GROUP BY 月份 WITH UR ");
	    	de318.logs("溪州斗二細項良品率", sql.toString());
	    	mArr = aaDao.qrySqlAll(sql.toString());
	    	for(int i=0; i<mArr.length; i++) {
	    		Map m = mArr[i];
	    		String month = aaTool.getStr(m.get("月份"));
	    		String prefix = "";
	    		if(lastYM.equals(month)) {
	    			prefix="LAST_";
	    		}
	    		xzData.put(prefix+"MAIN_YIELD", aaTool.format(m.get("溪州成材率"),"00.00"));   // 當月製造成材率
    	        xzData.put(prefix+"YIELD_LASER", aaTool.format(m.get("溪州雷射良品率"),"00.00"));  // LASER製程良率
    	        xzData.put(prefix+"YIELD_SQUARE", aaTool.format(m.get("溪州大方扁良品率"),"00.00")); // 大方 / 扁管良率
    	        xzData.put(prefix+"YIELD_OTHER", aaTool.format(m.get("溪州其他鋼管良品率"),"00.00"));  // 其他鋼管良率
    	        dl2Data.put(prefix+"MAIN_YIELD", aaTool.format(m.get("斗二成材率"),"00.00"));             // 製造成材率實績
    	        dl2Data.put(prefix+"SPEC_6_ABOVE", aaTool.format(m.get("斗二6吋以上良品率"),"00.00"));     // 6"（含）以上 良品率
    	        dl2Data.put(prefix+"LASER_YIELD", aaTool.format(m.get("斗二雷射良品率"),"00.00"));         // LASER製程 良品率
    	        dl2Data.put(prefix+"OTHER_PIPE_YIELD", aaTool.format(m.get("斗二其他鋼管良品率"),"00.00"));// 其他鋼管 良品率
    	    }
	    	//共2筆BY月份 溪州Q型態良品率
	    	sql.setLength(0);
	    	sql.append(" SELECT YYYYMM AS 月份,ROUND(SUM(x.S_WGT)*1.00000/SUM(x.INPUTWGT),4)*100 AS 溪州Q型態良品率 FROM (  ");
	    	sql.append(" 	SELECT substr(a.enddate,1,6) AS YYYYMM,a.MOID, a.S_WGT, a.INPUTWGT FROM db.tbucM111 a  ");
	    	sql.append(" 	WHERE a.COMPID='yc' and substr(a.enddate,1,6) IN ('"+lastYM+"','"+thisYM+"') AND a.LOCATE='B' AND a.INVTYPE IN ('Q1','QE')  ");
	    	sql.append(" 	UNION ALL  ");
	    	sql.append(" 	SELECT substr(a.enddate,1,6) AS YYYYMM,b.MOID, round(b.ABQTY*c.WETPERPCS,0) AS S_WGT, 0 AS INPUTWGT FROM db.tbucM111 a  ");
	    	sql.append(" 	JOIN db.tbwmpB035 b ON a.COMPID=b.COMPID AND a.MOID=b.MOID AND b.DEFECTREASON='E-2-24' AND b.ABQTY>0  ");
	    	sql.append(" 	JOIN db.tbwmpB020 c ON b.COMPID=c.COMPID AND b.MOID=c.MOID AND b.RUNCARD=c.RUNCARD  ");
	    	sql.append(" 	WHERE a.COMPID='yc' AND substr(a.enddate,1,6) IN ('"+lastYM+"','"+thisYM+"') AND a.LOCATE='B' AND a.INVTYPE IN ('Q1','QE')  ");
	    	sql.append(" ) x GROUP BY YYYYMM WITH UR ");
	    	de318.logs("溪州Q型態良品率", sql.toString());
	    	mArr = aaDao.qrySqlAll(sql.toString());
	    	for(int i=0; i<mArr.length; i++) {
	    		Map m = mArr[i];
	    		String month = aaTool.getStr(m.get("月份"));
	    		String prefix = "";
	    		if(lastYM.equals(month)) {
	    			prefix="LAST_";
	    		}
	    		xzData.put(prefix+"YIELD_Q", aaTool.format(m.get("溪州Q型態良品率"),"00.00"));  // Q型態良率
	    	}
	    	//共8筆BY廠區*2 型態*2 月份*2 PYE&非PYE型態銲道邊厚度符合率
	    	sql.setLength(0);
	    	sql.append(" SELECT y.廠區, y.型態分類, y.月份,ROUND(SUM(y.OK)*1.00000/SUM(y.COUNT),4)*100 as RATE  ");
	    	sql.append(" FROM (  ");
	    	sql.append(" SELECT x.廠區, x.型態分類, x.月份,count(*) COUNT, sum(CASE WHEN x.PRODMINTHICK-x.INPUTMINTHICK>=-0.05 THEN 1 ELSE 0 END) OK  ");
	    	sql.append(" FROM ( SELECT  ");
	    	sql.append(" a.廠區,substr(a.完工日期,1,6) AS 月份,CASE WHEN SUBSTR(a.型態,1,1) IN ('P','Y','E') THEN 'PYE' ELSE 'NON_PYE' END AS 型態分類 ");
	    	sql.append(" ,MIN(a.檢驗厚度, a.檢驗焊道邊厚度, a.檢驗焊道邊厚度II, a.檢驗距焊道邊5MM厚度I, a.檢驗距焊道邊5MM厚度II) AS PRODMINTHICK  ");
	    	sql.append(" ,MIN(a.製管入料檢驗厚度, a.製管入料距邊5MM厚度I, a.製管入料距邊5MM厚度II) AS INPUTMINTHICK    ");
	    	sql.append(" FROM db.tbwmpQ003 a  ");
	    	sql.append(" JOIN db.tbwzpA010 b ON b.MACHINEID=a.機台 AND b.MACHINEPROP='A'  ");
	    	sql.append(" WHERE a.廠區 IN ('B','D') AND substr(a.完工日期,1,6) IN ('"+lastYM+"','"+thisYM+"')  ");
	    	sql.append(" AND a.檢驗種類 BETWEEN 'A' AND 'D' AND substr(a.機台,2,1) IN ('F','Q') ) x  ");
	    	sql.append(" GROUP BY x.廠區, x.型態分類, x.月份 ");
	    	sql.append(" ) y GROUP BY y.廠區, y.型態分類, y.月份 ");
	    	sql.append(" ORDER BY y.廠區, y.型態分類, y.月份 ");
	    	sql.append(" WITH UR  ");
	    	de318.logs("PYE&非PYE型態銲道邊厚度符合率", sql.toString());
	    	mArr = aaDao.qrySqlAll(sql.toString());
	    	Map locateMap = aaTool.mapAryToMapList(mArr, "廠區");
	    	List BList = (List)locateMap.get("B");
	    	List DList = (List)locateMap.get("D");
	    	for(int i=0; i<BList.size(); i++) {
	    		Map m = (Map)BList.get(i);
	    		String month = aaTool.getStr(m.get("月份"));
	    		String pye = aaTool.getStr(m.get("型態分類"));
	    		String rate = aaTool.format(m.get("RATE"),"00.00");
	    		String prefix = "";
	    		if(lastYM.equals(month)) {
	    			prefix="LAST_";
	    		}
	    		if("PYE".equals(pye))
    				xzData.put(prefix+"PYE_5", rate);     // PYE型態五條內符合率
    			else
    				xzData.put(prefix+"NON_PYE_5", rate); // 非PYE型態五條內符合率
	    	}
	    	for(int i=0; i<DList.size(); i++) {
	    		Map m = (Map)DList.get(i);
	    		String month = aaTool.getStr(m.get("月份"));
	    		String pye = aaTool.getStr(m.get("型態分類"));
	    		String rate = aaTool.format(m.get("RATE"),"00.00");
	    		String prefix = "";
	    		if(lastYM.equals(month)) {
	    			prefix="LAST_";
	    		}
	    		if("PYE".equals(pye))
    				dl2Data.put(prefix+"PYE_MATCH", rate); // PYE型態符合率
    			else
    				dl2Data.put(prefix+"NON_PYE_MATCH", rate);// 非PYE型態符合率
	    	}
	    	//共2筆BY月份 規範符合率+外銷構造管符合率
	    	sql.setLength(0);
	    	sql.append(" SELECT 月份 ");
	    	sql.append(" ,round(sum(x.溪州OK)*1.0000 / NULLIF(sum(x.溪州總筆數), 0), 4)*100 AS 溪州OK  ");
	    	sql.append(" ,round(sum(x.溪州W1OK)*1.0000 / NULLIF(sum(x.溪州W1筆數), 0), 4)*100 AS 溪州W1OK  ");
	    	sql.append(" ,round(sum(x.斗二OK)*1.0000 / NULLIF(sum(x.斗二總筆數), 0), 4)*100 AS 斗二OK  ");
	    	sql.append(" ,round(sum(x.斗二W1OK)*1.0000 / NULLIF(sum(x.斗二W1筆數), 0), 4)*100 AS 斗二W1OK  ");
	    	sql.append(" FROM  ");
	    	sql.append(" (SELECT substr(a.完工日期,1,6) AS 月份 ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'B' THEN 1 ELSE 0 END AS 溪州總筆數 ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'B' AND a.COMPARE_B >=0 THEN 1 ELSE 0 END AS 溪州OK  ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'B' AND a.型態 = 'W1' THEN 1 ELSE 0 END AS 溪州W1筆數 ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'B' AND a.型態 = 'W1' AND a.COMPARE_B >=0 THEN 1 ELSE 0 END AS 溪州W1OK  ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'D' THEN 1 ELSE 0 END AS 斗二總筆數 ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'D' AND a.COMPARE_B >=0 THEN 1 ELSE 0 END AS 斗二OK  ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'D' AND a.型態 = 'W1' THEN 1 ELSE 0 END AS 斗二W1筆數 ");
	    	sql.append(" ,CASE WHEN a.廠區 = 'D' AND a.型態 = 'W1' AND a.COMPARE_B >=0 THEN 1 ELSE 0 END AS 斗二W1OK ");
	    	sql.append(" FROM db.ITQDB_H a ");
	    	sql.append(" WHERE a.廠區 IN ('B','D') AND substr(a.完工日期,1,6) IN ('"+lastYM+"','"+thisYM+"') ");
	    	sql.append(" )x GROUP BY 月份 ");
	    	de318.logs("規範符合率+外銷構造管符合率", sql.toString());
	    	mArr = aaDao.qrySqlAll(sql.toString());
	    	for(int i=0; i<mArr.length; i++) {
	    		Map m = mArr[i];
	    		String month = aaTool.getStr(m.get("月份"));
	    		String prefix = "";
	    		if(lastYM.equals(month)) {
	    			prefix="LAST_";
	    		}
    			xzData.put(prefix+"WELD_EDGE", aaTool.format(m.get("溪州OK"),"00.00"));    // 規範符合率
    			xzData.put(prefix+"EXPORT_STRUCT", aaTool.format(m.get("溪州W1OK"),"00.00"));// 外銷構造管符合率
    			dl2Data.put(prefix+"TOTAL_MATCH", aaTool.format(m.get("斗二OK"),"00.00")); // 符合規範總體率
	    	}
	    	//共2筆BY月份 斗二酸洗良品率
	    	sql.setLength(0);
	    	sql.append(" SELECT 月份,CASE WHEN x.PRODQTY=0 THEN 0 ELSE 100-round(x.REQTY*100.000/x.PRODQTY,2) END AS RATE  ");
	    	sql.append(" FROM ( SELECT substr(a.SYSTEMDATE,1,6) AS 月份 ");
	    	sql.append(" ,sum(a.QTYA) AS PRODQTY, sum(a.QTYB+a.QTYC) AS REQTY  ");
	    	sql.append(" FROM db.tbwmpB090 a  ");
	    	sql.append(" WHERE a.COMPID='yc' AND a.LOCATE='D'  ");
	    	sql.append(" AND substr(a.SYSTEMDATE,1,6) IN ('"+lastYM+"','"+thisYM+"') ");
	    	sql.append(" GROUP BY substr(a.SYSTEMDATE,1,6) ");
	    	sql.append(" ) x WITH UR  ");
	    	de318.logs("斗二酸洗良品率", sql.toString());
	    	mArr = aaDao.qrySqlAll(sql.toString());
	    	for(int i=0; i<mArr.length; i++) {
	    		Map m = mArr[i];
	    		String month = aaTool.getStr(m.get("月份"));
	    		String prefix = "";
	    		if(lastYM.equals(month)) {
	    			prefix="LAST_";
	    		}
	    		dl2Data.put(prefix+"PICKLING_YIELD", aaTool.format(m.get("RATE"),"00.00"));  // 酸洗良品率實績
	    	}
    	}catch(Exception e) {
    		de318.logs("取得溪州斗二資料失敗", e.getMessage());
    	}
    	return result;
    }
    
    
    /*
     * =========================================================================================
     * Private Method (斗一廠資料抓取邏輯拆分區塊)
     * =========================================================================================
     */

        private Map getDl1Data(String lastYM, String thisYM, String startYM){
        
        	Map dl1Data = new HashMap();
        	
        	try {
    	    	aajcYCADAO aaDao = new aajcYCADAO(dsCom);
    	    	StringBuilder sql = new StringBuilder("");
    	    	
    	    	sql.setLength(0);
    	    	sql.append("SELECT ");
    	    	sql.append("    月份 ");
    	    
    	    	sql.append("  , ROUND(SUM(x.CR切板次級量)*1.00000 / NULLIF(SUM(x.CR切板總量),0), 4)*100 AS CR切板次級率 ");
    	    	sql.append("  , ROUND(SUM(x.CR切板中料量)*1.00000 / NULLIF(SUM(x.CR切板總量),0), 4)*100 AS CR切板中料率 ");
    	    	sql.append("  , ROUND(SUM(x.CR分條中料量)*1.00000 / NULLIF(SUM(x.CR分條總量),0), 4)*100 AS CR分條中料率 ");
    	    	sql.append("  , ROUND(SUM(x.鏡面研磨次級量)*1.00000 / NULLIF(SUM(x.鏡面研磨總量),0), 4)*100 AS 鏡面研磨次級率 ");
    	    	sql.append("  , ROUND(SUM(x.停剪機2B次級量)*1.00000 / NULLIF(SUM(x.停剪機2B總量),0), 4)*100 AS 停剪機2B次級率 ");
    	    	sql.append("  , ROUND(SUM(x.停剪機2B中料量)*1.00000 / NULLIF(SUM(x.停剪機2B總量),0), 4)*100 AS 停剪機2B中料率 ");
    	    	sql.append("  , ROUND(SUM(x.NO1中料量)*1.00000 / NULLIF(SUM(x.NO1總量),0), 4)*100 AS 厚板NO1中料率 ");
    	    	sql.append("  , ROUND(SUM(x.停機痕零片數)*1.00000 / NULLIF(SUM(x.停機痕總片數),0), 4)*100 AS 停機痕零片率 ");
    	    	sql.append("FROM ( ");


    	    	// ===== IPQ7XA_C =====
    	    	sql.append("    SELECT ");
    	    	sql.append("        SUBSTR(A.ENDWORKDATE,1,6) AS 月份 ");
    	    	sql.append("      , A.ZERO_PCS AS 停機痕零片數 ");
    	    	sql.append("      , A.PROD_PCS AS 停機痕總片數 ");
    	    	sql.append("      , A.SEC_WGT  AS CR切板次級量 ");
    	    	sql.append("      , A.MID_WGT  AS CR切板中料量 ");
    	    	sql.append("      , A.TOTWGT   AS CR切板總量 ");
    	    	sql.append("      , 0 AS CR分條中料量 ");
    	    	sql.append("      , 0 AS CR分條總量 ");
    	    	sql.append("      , 0 AS 鏡面研磨次級量 ");
    	    	sql.append("      , 0 AS 鏡面研磨總量 ");
    	    	sql.append("      , 0 AS 停剪機2B次級量 ");
    	    	sql.append("      , 0 AS 停剪機2B中料量 ");
    	    	sql.append("      , 0 AS 停剪機2B總量 ");
    	    	sql.append("      , 0 AS NO1中料量 ");
    	    	sql.append("      , 0 AS NO1總量 ");
    	    	sql.append("    FROM db.IPQ7XA_C A ");
    	    	sql.append("    WHERE SUBSTR(A.ENDWORKDATE,1,6) IN ('"+lastYM+"','"+thisYM+"') ");

    	    	sql.append("    UNION ALL ");


    	    	// ===== IPQ7XA_D =====
    	    	sql.append("    SELECT ");
    	    	sql.append("        SUBSTR(A.ENDWORKDATE,1,6) ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("      , 0, 0, 0 ");
    	    	sql.append("      , A.MID_WGT ");
    	    	sql.append("      , A.TOTWGT ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("      , 0, 0, 0 ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("    FROM db.IPQ7XA_D A ");
    	    	sql.append("    WHERE SUBSTR(A.ENDWORKDATE,1,6) IN  ('"+lastYM+"','"+thisYM+"') ");
    	    	sql.append("      AND A.MACHINENAME LIKE '%CR%' ");

    	    	sql.append("    UNION ALL ");


    	    	// ===== IPQ7XA_E =====
    	    	sql.append("    SELECT ");
    	    	sql.append("        SUBSTR(A.ENDWORKDATE,1,6) ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("      , 0, 0, 0 ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("      , A.SEC_WGT ");
    	    	sql.append("      , A.TOTWGT ");
    	    	sql.append("      , 0, 0, 0 ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("    FROM db.IPQ7XA_E A ");
    	    	sql.append("    WHERE SUBSTR(A.ENDWORKDATE,1,6) IN ('"+lastYM+"','"+thisYM+"') ");

    	    	sql.append("    UNION ALL ");


    	    	// ===== IPQ7XA_A =====
    	    	sql.append("    SELECT ");
    	    	sql.append("        SUBSTR(A.ENDWORKDATE,1,6) ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("      , 0, 0, 0 ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("      , 0, 0 ");
    	    	sql.append("      , CASE WHEN A.SURFCODE='2B0' THEN A.SEC_WGT ELSE 0 END ");
    	    	sql.append("      , CASE WHEN A.SURFCODE='2B0' THEN A.MID_WGT ELSE 0 END ");
    	    	sql.append("      , CASE WHEN A.SURFCODE='2B0' THEN A.TOTWGT ELSE 0 END ");
    	    	sql.append("      , CASE WHEN A.SURFCODE='N10' THEN A.MID_WGT ELSE 0 END ");
    	    	sql.append("      , CASE WHEN A.SURFCODE='N10' THEN A.TOTWGT ELSE 0 END ");
    	    	sql.append("    FROM db.IPQ7XA_A A ");
    	    	sql.append("    WHERE SUBSTR(A.ENDWORKDATE,1,6) IN ('"+lastYM+"','"+thisYM+"') ");

    	    	sql.append(") x ");

    	    	sql.append("GROUP BY 月份 ");
    	    	sql.append("ORDER BY 月份 ");
    	    	sql.append("WITH UR ");
    	    	de318.logs("斗一廠品質監控SQL", sql.toString());
    	    	Map[] mArr = aaDao.qrySqlAll(sql.toString());
    	    	mArr = aaDao.qrySqlAll(sql.toString());
    	    	for(int i=0; i<mArr.length; i++) {
    	    		Map m = mArr[i];
    	    		String month = aaTool.getStr(m.get("月份"));
    	    		String prefix = "";
    	    		if(lastYM.equals(month)) {
    	    			prefix="LAST_";
    	    		}
    	    		dl1Data.put(prefix+"CR_SUB_RATE", aaTool.format(m.get("CR切板次級率"),"##0.00"));   // CR切板次級率
    	    		dl1Data.put(prefix+"CR_MID_RATE", aaTool.format(m.get("CR切板中料率"),"##0.00"));  // CR 切板中料率
    	    		dl1Data.put(prefix+"CR_SLIT_RATE", aaTool.format(m.get("CR分條中料率"),"##0.00")); // CR分條中料率
    	    		dl1Data.put(prefix+"GRIND_SUB_RATE", aaTool.format(m.get("鏡面研磨次級率"),"##0.00"));  // 鏡面研磨次級率
    	    		dl1Data.put(prefix+"CUT_SUB_2B_RATE", aaTool.format(m.get("停剪機2B次級率"),"##0.00")); // 停剪機2B次級率
    	    		dl1Data.put(prefix+"CUT_MID_2B_RATE", aaTool.format(m.get("停剪機2B中料率"),"##0.00")); // 停剪機2B中料率
    	    		dl1Data.put(prefix+"CUT_MID_NO1_RATE", aaTool.format(m.get("厚板NO1中料率"),"##0.00")); // 厚板NO1中料率
    	    		dl1Data.put(prefix+"停機痕_RATE", aaTool.format(m.get("停機痕零片率"),"##0.00"));// 停機痕零片率
        	    }
    	    	
    	    	//核心製程損耗明細
    	    	/**CR飛剪損耗的部份為次級率+中料率+修邊下腳率
				HR製程-2B損耗的部份為2M停剪機(2B表面)小計+2M分條機(2B表面)小計
				HR製程-No.1損耗的部份為2M停剪機(NO.1表面)小計+2M分條機(No.1表面)小計
				以上資訊來源為(PQ7XA) 鋼板捲製造生產狀況表
				數值請以年平均呈現(去年平均及今年平均!!
    	    	**/
    	    	
    	    	String thisyear = thisYM.substring(0, 4);//今年
				int prevYear = Integer.parseInt(thisyear) - 1;
				String prevYearS = prevYear+"";//去年
				String lastDate = prevYear + "0101";//去年
				
				//CR飛剪
				sql.setLength(0);
				sql.append("SELECT a.MACHINENAME ");
    	    	sql.append(" , SUBSTR(a.ENDWORKDATE,1,4) AS 年份 ");
    	    	sql.append(" , SUM(a.SEC_WGT + a.CUTE_WGT + a.HEAD_WGT + a.END_WGT + a.MID_WGT) AS 損耗重 ");
    	    	sql.append(" , SUM(a.TOTWGT) AS 總產出重 ");
    	    	sql.append(" , ROUND(SUM(a.SEC_WGT + a.CUTE_WGT + a.HEAD_WGT + a.END_WGT + a.MID_WGT)*1.00000 ");
    	    	sql.append("   / NULLIF(SUM(a.TOTWGT),0), 4) * 100 AS CR_LOSS_RATIO ");
    	    	sql.append("FROM DB.IPQ7XA_C a ");
    	    	sql.append("WHERE a.ENDWORKDATE > '" + lastDate + "' ");
    	    	sql.append("GROUP BY a.MACHINENAME, SUBSTR(a.ENDWORKDATE,1,4) ");
    	    	sql.append("ORDER BY 年份, a.MACHINENAME ");
    	    	sql.append("WITH UR ");
    	    	
    	    	
    	    	de318.logs("斗一核心製程損耗明細_1", sql.toString());
    	    	mArr = aaDao.qrySqlAll(sql.toString());
    	    	for(int i=0; i<mArr.length; i++) {
    	    		Map m = mArr[i];
    	    		String year = aaTool.getStr(m.get("年份"));
    	    		
    	    		String prefix = "";
    	    		if(prevYearS.equals(year)) {
    	    			prefix="LAST_";
    	    		}
    	    		
    	    			dl1Data.put(prefix+"CR_FLY_LOSS", aaTool.format(m.get("CR_LOSS_RATIO"),"##0.00"));  //CR飛剪

    	    	}
    	    	
    	    	
    	    	//HR製程-2B & No.1
    	    	sql.setLength(0);
    	    	sql.append("SELECT x.年份 ");
    	    	sql.append("      , x.表面 ");
    	    	sql.append("      ,  ROUND(SUM(x.損耗重) * 1.00000 / NULLIF(SUM(x.總產出重),0), 4)*100 AS LOSS_RATIO ");
    	    	sql.append("FROM ( ");

    	    	sql.append("    SELECT a.MACHINENAME ");
    	    	sql.append("         , SUBSTR(a.ENDWORKDATE,1,4) AS 年份 ");
    	    	sql.append("         , a.SURFCODE AS 表面 ");
    	    	sql.append("         , SUM(a.SEC_WGT+a.CUTE_WGT+a.HEAD_WGT+a.END_WGT+a.MID_WGT) AS 損耗重 ");
    	    	sql.append("         , SUM(a.TOTWGT) AS 總產出重 ");
    	    	sql.append("    FROM DB.IPQ7XA_A a ");
    	    	sql.append("    WHERE a.ENDWORKDATE > '"+lastDate+"' ");
    	    	sql.append("      AND a.SURFCODE IN ('2B0','N10') ");
    	    	sql.append("    GROUP BY a.MACHINENAME, SUBSTR(a.ENDWORKDATE,1,4), a.SURFCODE ");

    	    	sql.append("    UNION ALL ");

    	    	sql.append("    SELECT a.MACHINENAME ");
    	    	sql.append("         , SUBSTR(a.ENDWORKDATE,1,4) AS 年份 ");
    	    	sql.append("         , a.SURFCODE AS 表面 ");
    	    	sql.append("         , SUM(a.SEC_WGT+a.CUTE_WGT+a.HEAD_WGT+a.END_WGT+a.MID_WGT) AS 損耗重 ");
    	    	sql.append("         , SUM(a.TOTWGT) AS 總產出重 ");
    	    	sql.append("    FROM DB.IPQ7XA_B a ");
    	    	sql.append("    WHERE a.ENDWORKDATE > '"+lastDate+"' ");
    	    	sql.append("      AND a.SURFCODE IN ('2B0','N10') ");
    	    	sql.append("    GROUP BY a.MACHINENAME, SUBSTR(a.ENDWORKDATE,1,4), a.SURFCODE ");

    	    	sql.append(") x ");
    	    	sql.append("GROUP BY x.年份, x.表面 ");
    	    	sql.append("WITH UR ");

    	    	
    	    	de318.logs("斗一核心製程損耗明細_2", sql.toString());
    	    	mArr = aaDao.qrySqlAll(sql.toString());
    	    	for(int i=0; i<mArr.length; i++) {
    	    		Map m = mArr[i];
    	    		String year = aaTool.getStr(m.get("年份"));
    	    		String surfcode = aaTool.getStr(m.get("表面"));
    	    		String prefix = "";
    	    		if(prevYearS.equals(year)) {
    	    			prefix="LAST_";
    	    		}
    	    		//HR製程-2B
    	    		if(surfcode.equals("2B0")) {
    	    			dl1Data.put(prefix+"HR_2B_LOSS", aaTool.format(m.get("LOSS_RATIO"),"##0.00"));  //HR製程-2B
    	    			
    	    		//HR製程-No.1
    	    		}else if(surfcode.equals("N10")) {
    	    			dl1Data.put(prefix+"HR_NO1_LOSS", aaTool.format(m.get("LOSS_RATIO"),"##0.00"));  //HR製程-No.1
    	    			
    	    		}
    	    		
    	    	}
    	    	
    	    	
    	    
    	    
        	}catch(Exception e) {
        		de318.logs("取得斗一廠資料失敗", e.getMessage());
        	}
        	return dl1Data;
        }

    /**
     * 抓取並組裝斗一廠 (DL1) 品質指標數據
     */
//    private Map getDl1Data() {
//        Map dl1Data = new HashMap();
//        dl1Data.put("CR_SUB_RATE", "4.06");                 // CR 切板次級率實績
//        dl1Data.put("CR_SUB_TARGET", "提列改善 ≧3.58%");    // CR 切板次級率目標值標籤
//        
//        dl1Data.put("CR_MID_RATE", "0.69");                 // CR 切板中料率實績
//        dl1Data.put("CR_MID_TARGET", "提列改善 ≧0.68%");    // CR 切板中料率目標值標籤
//        
//        dl1Data.put("CR_SLIT_RATE", "1.51");                // CR 分條中料率實績
//        dl1Data.put("CR_SLIT_TARGET", "提列改善 ≧1.51%");   // CR 分條中料率目標值標籤
//        
//        dl1Data.put("GRIND_SUB_RATE", "1.75");              // 研磨次級率實績
//        dl1Data.put("GRIND_SUB_TARGET", "提列改善 ≧1.75%"); // 研磨次級率目標值標籤
//        
//        dl1Data.put("CUT_SUB_2B_RATE", "1.75");              // 停剪機2B次級率實績
//        dl1Data.put("CUT_SUB_2B_TARGET", "提列改善 ≧7.0%"); // 停剪機2B次級率目標值標籤
//        
//        dl1Data.put("CUT_MID_2B_RATE", "1.75");              // 停剪機2B中料率實績
//        dl1Data.put("CUT_MID_2B_TARGET", "提列改善 ≧0.36%"); // 停剪機2B中料率目標值標籤
//        
//        dl1Data.put("CUT_MID_NO1_RATE", "1.75");              // 厚板停剪機NO1中料率實績
//        dl1Data.put("CUT_MID_NO1_TARGET", "提列改善 ≧2.44%"); // 厚板停剪機NO1中料率目標值標籤
//        
//        dl1Data.put("停機痕_RATE", "1.75");              // 切板機停機痕零片件數比率實績
//        dl1Data.put("停機痕_TARGET", "提列改善 ≦65%"); // 切板機停機痕零片件數比率目標值標籤
//        
//        dl1Data.put("CR_FLY_LOSS", "11");      // CR 飛剪損耗合計
//        
//        dl1Data.put("HR_2B_LOSS", "8.16");                  // HR 製程-2B 表面加總
//        dl1Data.put("HR_NO1_LOSS", "5.59");                 // HR 製程-No.1 表面加總
//        return dl1Data;
//    }

}