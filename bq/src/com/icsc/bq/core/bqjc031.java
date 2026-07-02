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

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import javax.servlet.http.HttpServletRequest;
import org.json.JSONArray;

import com.icsc.aa.yc.util.aajcYCATool;
import com.icsc.dpms.de.dejc318;
import com.icsc.dpms.de.dejcQueryDAO;
import com.icsc.dpms.ds.dsjccom;

public class bqjc031{
	private static final String PROCID = "BQJC031";
	public final static String CLASS_VERSION = "$Id: bqjc031.java,v 1.1 2026/03/10 10:10:55 yc13 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc031(dsjccom dsCom) {
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
     * 從資料庫查詢資料
     */
    public Map[] getRawDataFromDB(dsjccom dsCom, HttpServletRequest request) throws Exception {
		aajcYCATool aaTool = new aajcYCATool();

	    String begDate = aaTool.getStr(request.getParameter("begDate_qry")).replaceAll("/","");
	    String endDate = aaTool.getStr(request.getParameter("endDate_qry")).replaceAll("/","");  
	    if("".equals(begDate))
	    	begDate = "20260101";
	    if("".equals(endDate))
	    	endDate = "20260101";
	    
		StringBuffer sql = new StringBuffer();
		sql.append(" SELECT * FROM TABLE(DB.FN_BQ031('"+begDate+"','"+endDate+"'))");
		sql.append(" WITH UR ");
		
		System.out.println("SQL" + sql.toString());

		return new dejcQueryDAO(dsCom).getDatas(sql.toString());		
	}
    
    /**
     * 整理成畫面需要的資料
     */
    public Map processDashboardData(Map[] rawData) {
		Map result = new HashMap();
		double totalWeight = 0;
		double totalWeightedDays = 0;
		int totalCount = 0;
		int ontimeCount = 0;
		double delayedAmt = 0;
		int exportCount = 0;
		int exportOntimeCount = 0;
		int domesticCount = 0;
		int domesticOntimeCount = 0;
		Map monthlyStats = new TreeMap();
		Map prodStats = new HashMap();
		Map custStats = new HashMap();
		List blackholeList = new ArrayList();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		for (int i = 0; i < rawData.length; i++) {
			Map row = rawData[i];
			String orderNo = aaTool.getStr(row.get("訂單號碼"));
			String custName = aaTool.getStr(row.get("客戶簡稱"));
			String prodType = aaTool.getStr(row.get("產品大類"));
			String salesType = aaTool.getStr(row.get("銷別"));
			String shipMonth = aaTool.getStr(row.get("出貨月份"));
			String isOntime = aaTool.getStr(row.get("達交"));
			double weight = aaTool.getBigDecimal(row.get("出貨重量")).doubleValue();
			double amt = aaTool.getBigDecimal(row.get("出貨金額")).doubleValue();
			double leadTime = aaTool.getBigDecimal(row.get("出貨天數")).doubleValue();
			String shipDateStr = aaTool.getStr(row.get("出貨日期"));
			String dueDateStr = aaTool.getStr(row.get("交期"));
			if ("太陽光電售電".equals(prodType) || weight <= 0) {
				continue;
			}
			long delayDays = 0;
			try {
				if (shipDateStr.length() == 8 && dueDateStr.length() == 8) {
					Date shipDate = sdf.parse(shipDateStr);
					Date dueDate = sdf.parse(dueDateStr);
					delayDays = (shipDate.getTime() - dueDate.getTime()) / (1000 * 60 * 60 * 24);
				}
			} catch (Exception e) {
			}
			totalWeight += weight;
			totalWeightedDays += (weight * leadTime);
			totalCount++;
			if ("Y".equals(isOntime)) {
				ontimeCount++;
			} else {
				delayedAmt += amt;
			}
			if ("外銷".equals(salesType)) {
				exportCount++;
				if ("Y".equals(isOntime))
					exportOntimeCount++;
			} else if ("內銷".equals(salesType)) {
				domesticCount++;
				if ("Y".equals(isOntime))
					domesticOntimeCount++;
			}
			if (!"".equals(shipMonth)) {
				if (!monthlyStats.containsKey(shipMonth)) {
					monthlyStats.put(shipMonth, new double[] { 0, 0, 0, 0 });
				}
				double[] mStat = (double[]) monthlyStats.get(shipMonth);
				mStat[0] += weight;
				mStat[1] += (weight * leadTime);
				mStat[2] += 1;
				if ("Y".equals(isOntime))
					mStat[3] += 1;
			}
			if (!prodStats.containsKey(prodType)) {
				prodStats.put(prodType, new double[] { 0, 0, 0 });
			}
			double[] pStat = (double[]) prodStats.get(prodType);
			pStat[0] += weight;
			pStat[1] += 1;
			if ("Y".equals(isOntime))
				pStat[2] += 1;
			if (!custStats.containsKey(custName)) {
				custStats.put(custName, new double[] { 0, 0, 0, 0 });
			}
			double[] cStat = (double[]) custStats.get(custName);
			cStat[0] += weight;
			cStat[1] += 1;
			if ("N".equals(isOntime)) {
				cStat[2] += 1;
				cStat[3] += weight;
			}
			if (delayDays > 300) {
				Map bhRow = new HashMap();
				bhRow.put("訂單號碼", orderNo);
				bhRow.put("客戶簡稱", custName);
				bhRow.put("銷別", salesType);
				bhRow.put("產品大類", prodType);
				bhRow.put("出貨金額", new Double(amt));
				bhRow.put("延遲天數", new Long(delayDays));
				blackholeList.add(bhRow);
			}
		}
		Map kpi = new HashMap();
		kpi.put("totalWeight", new Double(Math.round(totalWeight / 1000.0)));
		double finalLeadTime = (totalWeight != 0) ? Math.round((totalWeightedDays / totalWeight) * 10.0) / 10.0 : 0.0;
		kpi.put("weightedLeadTime", new Double(finalLeadTime));
		double finalOntimeRate = (totalCount != 0) ? Math.round((ontimeCount * 100.0 / totalCount) * 10.0) / 10.0 : 0.0;
		kpi.put("ontimeRate", new Double(finalOntimeRate));
		kpi.put("delayedAmt", new Double(Math.round((delayedAmt / 100000000.0) * 100.0) / 100.0));
		double finalExportOntime = (exportCount != 0) ? Math.round((exportOntimeCount * 100.0 / exportCount) * 10.0) / 10.0
				: 0.0;
		kpi.put("exportOntime", new Double(finalExportOntime));
		double finalDomesticOntime = (domesticCount != 0) ? Math
				.round((domesticOntimeCount * 100.0 / domesticCount) * 10.0) / 10.0 : 0.0;
		kpi.put("domesticOntime", new Double(finalDomesticOntime));
		result.put("kpi", kpi);
		Collections.sort(blackholeList, new Comparator() {
			public int compare(Object o1, Object o2) {
				Long d1 = (Long) ((Map) o1).get("延遲天數");
				Long d2 = (Long) ((Map) o2).get("延遲天數");
				return d2.compareTo(d1);
			}
		});
		if (blackholeList.size() > 8)
			blackholeList = blackholeList.subList(0, 8);
		result.put("blackholeList", blackholeList);
		JSONArray trendMonths = new JSONArray();
		JSONArray trendWeights = new JSONArray();
		JSONArray trendLeadTime = new JSONArray();
		JSONArray trendOntime = new JSONArray();
		Iterator mIt = monthlyStats.keySet().iterator();
		while (mIt.hasNext()) {
			String month = (String) mIt.next();
			if (month.length() == 6) {
				trendMonths.put(month.substring(2, 4) + "年" + Integer.parseInt(month.substring(4, 6)) + "月");
			} else {
				trendMonths.put(month);
			}
			double[] mStat = (double[]) monthlyStats.get(month);
			trendWeights.put(Math.round(mStat[0] / 1000.0));
			double leadVal = (mStat[0] != 0) ? Math.round((mStat[1] / mStat[0]) * 10.0) / 10.0 : 0.0;
			trendLeadTime.put(new Double(leadVal));
			double ontimeVal = (mStat[2] != 0) ? Math.round((mStat[3] * 100.0 / mStat[2]) * 10.0) / 10.0 : 0.0;
			trendOntime.put(new Double(ontimeVal));
		}
		result.put("trendMonthsJson", trendMonths.toString());
		result.put("trendWeightsJson", trendWeights.toString());
		result.put("trendLeadTimeJson", trendLeadTime.toString());
		result.put("trendOntimeJson", trendOntime.toString());
		List prodList = new ArrayList(prodStats.entrySet());
		Collections.sort(prodList, new Comparator() {
			public int compare(Object o1, Object o2) {
				Double w1 = new Double(((double[]) ((Map.Entry) o1).getValue())[0]);
				Double w2 = new Double(((double[]) ((Map.Entry) o2).getValue())[0]);
				return w2.compareTo(w1);
			}
		});
		JSONArray prodLabels = new JSONArray();
		JSONArray prodWeights = new JSONArray();
		JSONArray prodOntime = new JSONArray();
		for (int i = 0; i < prodList.size() && i < 7; i++) {
			Map.Entry entry = (Map.Entry) prodList.get(i);
			double[] pStat = (double[]) entry.getValue();
			prodLabels.put((String) entry.getKey());
			prodWeights.put(Math.round(pStat[0] / 1000.0));
			double pOntimeVal = (pStat[1] != 0) ? Math.round((pStat[2] * 100.0 / pStat[1]) * 10.0) / 10.0 : 0.0;
			prodOntime.put(new Double(pOntimeVal));
		}
		result.put("prodLabelsJson", prodLabels.toString());
		result.put("prodWeightsJson", prodWeights.toString());
		result.put("prodOntimeJson", prodOntime.toString());
		List custList = new ArrayList(custStats.entrySet());
		Collections.sort(custList, new Comparator() {
			public int compare(Object o1, Object o2) {
				Double w1 = new Double(((double[]) ((Map.Entry) o1).getValue())[3]);
				Double w2 = new Double(((double[]) ((Map.Entry) o2).getValue())[3]);
				return w2.compareTo(w1);
			}
		});
		JSONArray custLabels = new JSONArray();
		JSONArray custWeights = new JSONArray();
		JSONArray custRates = new JSONArray();
		for (int i = 0; i < custList.size() && i < 5; i++) {
			Map.Entry entry = (Map.Entry) custList.get(i);
			double[] cStat = (double[]) entry.getValue();
			if (cStat[3] == 0)
				continue;
			custLabels.put((String) entry.getKey());
			custWeights.put(Math.round(cStat[3] / 1000.0));
			double cRateVal = (cStat[1] != 0) ? Math.round((cStat[2] * 100.0 / cStat[1]) * 10.0) / 10.0 : 0.0;
			custRates.put(new Double(cRateVal));
		}
		result.put("custLabelsJson", custLabels.toString());
		result.put("custWeightsJson", custWeights.toString());
		result.put("custRatesJson", custRates.toString());
		return result;
	}
}
