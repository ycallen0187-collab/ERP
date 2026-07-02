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
import com.icsc.dpms.de.dejcQueryDAO;
import com.icsc.dpms.ds.dsjccom;
//import com.sun.org.apache.xerces.internal.impl.dv.xs.DecimalDV;

public class bqjc042Factory{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjc042Factory.java,v 1.5 2026/06/25 09:04:41 02587 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjc042Factory(dsjccom dsCom) {
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
    public Map getDashboardData(dsjccom dsCom, HttpServletRequest request) throws SQLException, Exception {

		//連線CIC資料庫取資料
		Connection conCIC = null;
		//連TR 資料庫
		Connection conTR = null;
		
		//跟資料庫連結
		try {
			
			aajcYCADAO aaDao = new aajcYCADAO(dsCom);
			
			//跟CIC資料庫連結
			bqjcGetConnectionCIC bqGetCon = new bqjcGetConnectionCIC(dsCom);
			conCIC = bqGetCon.getSQLServerConnection();
			
			conTR = bqGetCon.getTRDB2Connection();

			Map result = new HashMap();
			
		    String endDate = aaTool.getStr(request.getParameter("endDate_qry")).replaceAll("/","");

		    if("".equals(endDate))
		    	endDate = new dejc308().getCrntDateWFmt1();
		    
		    String endDateYM = endDate.substring(0, 6);
		    
		    //取得展成本資料的日期 
		    String costDate = endDateYM;
		    Map exp = aaDao.qrySql("SELECT max(a.DATEYM) AS DATE FROM DB.TB_BI_AC_WMP_NEW a WHERE a.DATEYM<= '"+endDate+"'");
			if(exp != null) {
				costDate = aaTool.getStr(exp.get("DATE"));
			}
				
		    
		    
		    Map targetTWMap = this.getTargetData(dsCom);
		    Map targetTRMap = this.getTargetTRData(dsCom, conTR);
		    
			//依據財務型態區分廠區
			Map[] ipqxMaps = new dejcQueryDAO(dsCom, conCIC).getDatas(getIPQXsql(endDateYM));
		    
		    Map[] ipqxFactoryMaps = new dejcQueryDAO(dsCom, conCIC).getDatas(getIPQXbyFactorysql(endDateYM));
		    
		    //板捲廠
	    	Map[] ipq137Map = new dejcQueryDAO(dsCom, conCIC).getDatas(getIPQ137sql(endDateYM));
		    
		    Map[] machCountMaps = new dejcQueryDAO(dsCom, conCIC).getDatas(getMachCountsql());
		    
		    //TW人力
		    Map[] humanMaps = new dejcQueryDAO(dsCom, conCIC).getDatas(getTW_humansql());
		    Map[] ALLhumanMaps = new dejcQueryDAO(dsCom, conCIC).getDatas(getTW_ALLhumansql());
		    //連到db2 台灣正式機資料庫
		    Map[] unitCostTWMaps = new dejcQueryDAO(dsCom).getDatas(getTW_UnitCostsql(costDate));
		    Map[] expTWMaps = new dejcQueryDAO(dsCom).getDatas(getTW_IAC4Nsql(costDate));
  
		   //改透過json 連接TR
		   // Map[] unitCostTRMaps = new dejcQueryDAO(dsCom, conTR).getDatas(getTR_UnitCostsql(costDate));
		   // Map[] expTRMaps = new dejcQueryDAO(dsCom, conTR).getDatas(getTR_IAC4Nsql(costDate));
		     
		    result.put("TW_PRODData", this.getProdDataFromIPQX(dsCom, conCIC, endDate, targetTWMap, ipqxMaps, ipqxFactoryMaps, ipq137Map));
		    result.put("TR_PRODData", this.getProdDataTRFromIPQX(dsCom, conCIC, endDate, targetTRMap, ipqxMaps, ipqxFactoryMaps, ipq137Map));
		    
		    result.put("XIZHOU_PRODData", this.getProdDataXIZHOUFromIPQX(dsCom, conCIC, endDate, targetTWMap, ipqxFactoryMaps, 
		    		machCountMaps, unitCostTWMaps, expTWMaps)); 
		   
		    result.put("DOU2_PRODData", this.getProdDataDOU2FromIPQX(dsCom, conCIC, endDate, targetTWMap, ipqxFactoryMaps, 
		    		machCountMaps, unitCostTWMaps, expTWMaps)); 
		    
		    result.put("DOU1_PRODData", this.getProdDataDOU1FromIPQX(dsCom, conCIC, endDate, targetTWMap, ipqxFactoryMaps, 
		    		machCountMaps, unitCostTWMaps, expTWMaps)); 
		    
		    result.put("F108_PRODData", this.getProdDataF108FromIPQX(dsCom, conCIC, endDate, targetTRMap, ipqxFactoryMaps, 
		    		machCountMaps )); 
		    
		    result.put("F105_PRODData", this.getProdDataF105FromIPQX(dsCom, conCIC, endDate, targetTRMap, ipqxFactoryMaps, 
		    		machCountMaps )); 
		    
		    result.put("F109_PRODData", this.getProdDataF109FromIPQX(dsCom, conCIC, endDate, targetTRMap, ipqxFactoryMaps, 
		    		machCountMaps )); 
		    
		    result.put("humanList", this.gethumandata(dsCom, conCIC, humanMaps));//各別三廠
		    result.put("ALLhumanList", this.getALLhumandata(dsCom, conCIC, ALLhumanMaps));//三廠總和
		    
		    return result;
		    
		} catch(Exception e){
			throw e;
		}finally {
			if(conCIC != null)
				conCIC.close();
			conCIC = null;
			
			if(conTR != null)
				conTR.close();
			conTR = null;
		}
		    
	}  
    
    /*
     * 測試網址
     * http://172.21.0.1/erp/event/put/unitech/MES01.run.go?data=json&j={%22i%22:{%22FORMID%22:%22BQ051%22,%22ERPUSERID%22:%2200859%22,%22PASSWORD%22:%22123456%22},%22t%22:%22map%22}
     * 
     */
    
    public Map getTRDashboardData(dsjccom dsCom, HttpServletRequest request) throws Exception {
    	//畫面上沒有輸入日期，預設今天，後續由TR端程式判斷要抓哪一天資料
	    String endDate = aaTool.getStr(request.getParameter("endDate_qry")).replaceAll("/","");
	    if("".equals(endDate))
	    	endDate = new dejc308().getCrntDateWFmt1();
	    
	    //塞AP需要資訊
		Map queryMap = new HashMap();
		queryMap.put("FORMID", "BQ042FACTORY");				//這個最重要
		queryMap.put("ERPUSERID", dsCom.user.ID);		//判斷授權用				
		queryMap.put("endDate_qry", endDate);			//查詢條件，隨時想加什麼參數，直接 put 進Map就好！
	    
	    //呼叫API
	    return new bqjcGetTRData(dsCom).getDashboard(queryMap);
    }
    
    
    
    public Map getTargetData(dsjccom dsCom) throws Exception {
    	 
		try {
			
			Map result = new HashMap();
			Map m = new dejcQueryDAO(dsCom).getData(getTargetSql());
			
			result.put("TW_TARGET_TUBEWGT", aaTool.getStr(m.get("TARGET_TUBEWGT")));
			result.put("TW_TARGET_PIPEWGT", aaTool.getStr(m.get("TARGET_PIPEWGT")));
			result.put("TW_TARGET_SHEETWGT", aaTool.getStr(m.get("TARGET_SHEETWGT"))); 
			return result;
			
			
		} catch(Exception e){
			throw e;
		} 
	}
    
    
    public Map getTargetTRData(dsjccom dsCom, Connection conTR) throws Exception {
   	 
		try {
			
			Map result = new HashMap();
			Map m = new dejcQueryDAO(dsCom, conTR).getData(getTargetSql());
			result.put("TR_TARGET_TUBEWGT", aaTool.getStr(m.get("TARGET_TUBEWGT")));
			result.put("TR_TARGET_PIPEWGT", aaTool.getStr(m.get("TARGET_PIPEWGT")));
			result.put("TR_TARGET_SHEETWGT", aaTool.getStr(m.get("TARGET_SHEETWGT"))); 
			return result;
			
			
		} catch(Exception e){
			throw e;
		} 
	}
    
    public static String getTargetSql(){
		 
 		String sql =" SELECT SUM(CASE WHEN PRODTYPE ='T' THEN WGT ELSE 0  END ) AS TARGET_TUBEWGT,  "+
 				" 	   SUM(CASE WHEN PRODTYPE ='P' THEN WGT ELSE 0  END ) AS TARGET_PIPEWGT,    "+
 				" 	   SUM(CASE WHEN PRODTYPE ='C' THEN WGT ELSE 0  END ) AS TARGET_SHEETWGT    "+
 				" FROM (                                                                        "+
 				" 	SELECT  'T' AS PRODTYPE ,SUM(FIELD4) AS WGT FROM db.TBDE23 WHERE TABID IN ( "+
 				" 	'AOG06SS_DOM',                                                              "+
 				" 	'AOG06SS_EXP'                                                               "+
 				" 	) AND FIELD1 = '構造管'                                                     "+
 				" 	UNION ALL                                                                   "+
 				" 	SELECT  'P' AS PRODTYPE ,SUM(FIELD4) AS WGT FROM db.TBDE23 WHERE TABID IN ( "+
 				" 	'AOG06SS_DOM',                                                              "+
 				" 	'AOG06SS_EXP'                                                               "+
 				" 	) AND  FIELD1 = '配管'                                                      "+
 				" 	UNION ALL                                                                   "+
 				" 	SELECT 'C' AS PRODTYPE ,SUM(FIELD4) AS WGT FROM db.TBDE23 WHERE TABID IN (  "+
 				" 	'AOG06SS_DOM',                                                              "+
 				" 	'AOG06SS_EXP'                                                               "+
 				" 	) AND (FIELD3 = '板捲' OR FIELD1 IN('扁鐵','角鐵') )                        "+
 				" )                                                                             ";
 			
 			
 		return sql;
 	}
    
     
    public Map getProdDataFromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target,Map[] ipqxMaps , Map[] ipqxFactoryMaps, Map[] ipq137Map ) throws Exception {
   	 
		try {
			
			 
			Map result = new HashMap();
			
	    	BigDecimal target_P = aaTool.getBigDecimal(target.get("TW_TARGET_PIPEWGT"));
	    	BigDecimal target_T = aaTool.getBigDecimal(target.get("TW_TARGET_TUBEWGT"));
	    	BigDecimal target_C = aaTool.getBigDecimal(target.get("TW_TARGET_SHEETWGT"));

	    	
	    	for(int i=0; i<ipq137Map.length; i++) {
	    		
				Map m = ipq137Map[i];
				
				if(! aaTool.getStr(m.get("區域")).equals("TW")) {
					continue;
				}
				
				
				result.put("TW_C_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
				result.put("TW_C_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
				result.put("TW_C_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));
				result.put("TW_C_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率")));
				
				if(target_C.intValue() > 0) {
					result.put("TW_C_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
							target_C, 1, BigDecimal.ROUND_HALF_UP)));
				}
	    	}	
	    	
	    	   	
			result.put("TW_TARGET_TUBEWGT", target_T);
			result.put("TW_TARGET_PIPEWGT", target_P);
			result.put("TW_TARGET_SHEETWGT", target_C);
	    	
	    	for(int i=0; i<ipqxMaps.length; i++) {
	    		
				Map m = ipqxMaps[i];
				
				if(! aaTool.getStr(m.get("區域")).equals("TW")) {
					continue;
				}
				
				String prodType = aaTool.getStr(m.get("PRODTYPE"));			
				if(prodType.equals("T")) {
					result.put("TW_T_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("TW_T_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("TW_T_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_T.intValue() > 0) {
						result.put("TW_T_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_T, 1, BigDecimal.ROUND_HALF_UP)));
					}
					
					result.put("TW_T_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
	
				}
				
				if(prodType.equals("P")) {
					result.put("TW_P_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("TW_P_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("TW_P_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_P.intValue() > 0) {
						result.put("TW_P_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_P, 1, BigDecimal.ROUND_HALF_UP)));
					}
				}
	    	}	
	    	
	    	for(int i=0; i<ipqxFactoryMaps.length; i++) {  		
				Map m = ipqxFactoryMaps[i];
				
				if(aaTool.getStr(m.get("廠區名稱")).equals("溪州")) {
					result.put("TW_T_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
				}
				if(aaTool.getStr(m.get("廠區名稱")).equals("斗二")) {
					result.put("TW_P_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
				}	
	    	}	
	     
			return result;
			
			
		} catch(Exception e){
			throw e;
		} 
	}
    
    
    
    
    public Map getProdDataTRFromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target,Map[] ipqxMaps, Map[] ipqxFactoryMaps, Map[] ipq137Map) throws Exception {
      	 
		try {
			Map result = new HashMap();
			
	    	BigDecimal target_P = aaTool.getBigDecimal(target.get("TR_TARGET_PIPEWGT"));
	    	BigDecimal target_T = aaTool.getBigDecimal(target.get("TR_TARGET_TUBEWGT"));
	    	BigDecimal target_C = aaTool.getBigDecimal(target.get("TR_TARGET_SHEETWGT"));
			
	    	for(int i=0; i<ipq137Map.length; i++) {
				Map m = ipq137Map[i];
				
				if(! aaTool.getStr(m.get("區域")).equals("TR")) {
					continue;
				}
				
				result.put("TR_C_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
				result.put("TR_C_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
				result.put("TR_C_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));
				result.put("TR_C_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率")));
				
				if(target_C.intValue() > 0) {
					result.put("TR_C_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
							target_C, 1, BigDecimal.ROUND_HALF_UP)));
				}
	    	}	
	    		
			result.put("TR_TARGET_TUBEWGT", target_T);
			result.put("TR_TARGET_PIPEWGT", target_P);
			result.put("TR_TARGET_SHEETWGT", target_C);
	    	
	    	for(int i=0; i<ipqxMaps.length; i++) {
				Map m = ipqxMaps[i];
				
				if(! aaTool.getStr(m.get("區域")).equals("TR")) {
					continue;
				}
				
				String prodType = aaTool.getStr(m.get("PRODTYPE"));			
				if(prodType.equals("T")) {
					result.put("TR_T_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("TR_T_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("TR_T_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_T.intValue() > 0) {
						result.put("TR_T_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_T, 1, BigDecimal.ROUND_HALF_UP)));
					}
				}
				
				if(prodType.equals("P")) {
					result.put("TR_P_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("TR_P_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("TR_P_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_P.intValue() > 0) {
						result.put("TR_P_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_P, 1, BigDecimal.ROUND_HALF_UP)));
					}
				}
	    	}	
	    	
	    	for(int i=0; i<ipqxFactoryMaps.length; i++) {	
				Map m = ipqxFactoryMaps[i];
				
				if(aaTool.getStr(m.get("廠區名稱")).equals("108")) {
					result.put("TR_T_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
				}
				if(aaTool.getStr(m.get("廠區名稱")).equals("105")) {
					result.put("TR_P_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
				}	
	    	}	
	     
			return result;
			
			
		} catch(Exception e){
			throw e;
		} 
	}
    
    
    
    public Map getProdDataXIZHOUFromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target, Map[] ipqxFactoryMaps, Map[] machCountMaps, 
    		Map[] unitCostTWMaps, Map[] expTWMaps) throws Exception {
		try { 
			Map result = new HashMap();
	    	BigDecimal target_T = aaTool.getBigDecimal(target.get("TW_TARGET_TUBEWGT"));
			result.put("XIZHOU_TARGET_TUBEWGT", target_T);

	    	for(int i=0; i<ipqxFactoryMaps.length; i++) {
				Map m = ipqxFactoryMaps[i];
				if(!aaTool.getStr(m.get("廠區名稱")).equals("溪州")) continue;
					result.put("XIZHOU_T_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("XIZHOU_T_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("XIZHOU_T_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_T.intValue() > 0) {
						result.put("XIZHOU_T_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_T, 1, BigDecimal.ROUND_HALF_UP)));
					}		
					result.put("XIZHOU_T_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
					result.put("XIZHOU_T_MACHWITHP_RATE", aaTool.getBigDecimal(m.get("稼動率")));
		    	}	
	    	
	    	//機台數
	    	for(int i=0; i<machCountMaps.length; i++) {
				Map m = machCountMaps[i];
				if(aaTool.getStr(m.get("廠區名稱")).equals("溪州")) {
					result.put("XIZHOU_MACHCOUNT", aaTool.getBigDecimal(m.get("機台數")));
				}
	    	}
	  
	    	//單位成本
			for(int i=0; i<unitCostTWMaps.length; i++) {
				Map m = unitCostTWMaps[i]; 
				if(aaTool.getStr(m.get("PRODTYPE")).equals("T")) {
					result.put("XIZHOU_UNITCOST", aaTool.getBigDecimal(m.get("單價")));
				}
			}
				    		
			//人工製費			
			for(int i=0; i<expTWMaps.length; i++) {
				Map m = expTWMaps[i]; 
				if(aaTool.getStr(m.get("FACTORY")).equals("B")) {
					result.put("XIZHOU_EXP", aaTool.getBigDecimal(m.get("單價")));
				}
			}

			return result;	
		} catch(Exception e){
			throw e;
		} 
	}
    
    
    
    public Map getProdDataDOU2FromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target, Map[] ipqxFactoryMaps, Map[] machCountMaps, 
    		Map[] unitCostTWMaps, Map[] expTWMaps) throws Exception {
      	 
		try {	 
			Map result = new HashMap();
	    	BigDecimal target_P = aaTool.getBigDecimal(target.get("TW_TARGET_PIPEWGT"));
			result.put("DOU2_TARGET_PIPEWGT", target_P);
	    	for(int i=0; i<ipqxFactoryMaps.length; i++) {
				Map m = ipqxFactoryMaps[i];
				if(!aaTool.getStr(m.get("廠區名稱")).equals("斗二")) continue;
					result.put("DOU2_P_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("DOU2_P_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("DOU2_P_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_P.intValue() > 0) {
						result.put("DOU2_P_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_P, 1, BigDecimal.ROUND_HALF_UP)));
					}
					
					result.put("DOU2_P_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
					result.put("DOU2_P_MACHWITHP_RATE", aaTool.getBigDecimal(m.get("稼動率")));
	    	}	
	    	
	    	//稼動率
	    	Map[] ipq116Maps = new dejcQueryDAO(dsCom, conCIC).getDatas(getIPQ116sql());
	    	for(int i=0; i<ipq116Maps.length; i++) {	
				Map m = ipq116Maps[i];
				if(aaTool.getStr(m.get("廠區")).equals("D")) {
					result.put("TW_P_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
					result.put("TW_P_MACHWITHP_RATE", aaTool.getBigDecimal(m.get("稼動率")));
				}
	    	}	
	    	
	    	//機台數
	    	for(int i=0; i<machCountMaps.length; i++) {
				Map m = machCountMaps[i];
				if(aaTool.getStr(m.get("廠區名稱")).equals("斗二")) {
					result.put("DOU2_MACHCOUNT", aaTool.getBigDecimal(m.get("機台數")));
				}
	    	}
	  
	    	//單位成本
			for(int i=0; i<unitCostTWMaps.length; i++) {
				Map m = unitCostTWMaps[i]; 	
				if(aaTool.getStr(m.get("PRODTYPE")).equals("P")) {
					result.put("DOU2_UNITCOST", aaTool.getBigDecimal(m.get("單價")));
				}
			}
				    		
			//人工製費			
			for(int i=0; i<expTWMaps.length; i++) {
				Map m = expTWMaps[i]; 
				if(aaTool.getStr(m.get("FACTORY")).equals("D")) {
					result.put("DOU2_EXP", aaTool.getBigDecimal(m.get("單價")));
				}
			}  
			return result;

		} catch(Exception e){
			throw e;
		} 
	}
    
    
    
    public Map getProdDataDOU1FromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target, Map[] ipqxMaps, Map[] machCountMaps, 
    		Map[] unitCostTWMaps, Map[] expTWMaps) throws Exception {
      	 
		try {
			
			 
			Map result = new HashMap();
 
			/*
			 * 斗一資料直接抓上面總表 "TW 綜合指標" 的資料
			 */
	    	
	    	//機台數
	    	for(int i=0; i<machCountMaps.length; i++) {
	    		
				Map m = machCountMaps[i];
				
				if(aaTool.getStr(m.get("廠區名稱")).equals("斗一")) {
					result.put("DOU1_MACHCOUNT", aaTool.getBigDecimal(m.get("機台數")));
				}

	    	}
	  
	    	//單位成本
			for(int i=0; i<unitCostTWMaps.length; i++) {
				Map m = unitCostTWMaps[i]; 
				
				if(aaTool.getStr(m.get("PRODTYPE")).equals("C")) {
					result.put("DOU1_UNITCOST", aaTool.getBigDecimal(m.get("單價")));
				}
			}
				    		
			//人工製費			
			for(int i=0; i<expTWMaps.length; i++) {
				Map m = expTWMaps[i]; 
				
				if(aaTool.getStr(m.get("FACTORY")).equals("C")) {
					result.put("DOU1_EXP", aaTool.getBigDecimal(m.get("單價")));
				}
			}
	    	
	     
			return result;
			
			
		} catch(Exception e){
			throw e;
		} 
	}
    
    
    public Map getProdDataF108FromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target, Map[] ipqxFactoryMaps, Map[] machCountMaps ) throws Exception {
      	 
		try {		 
			Map result = new HashMap();
	    	BigDecimal target_T = aaTool.getBigDecimal(target.get("TR_TARGET_TUBEWGT"));
	    	
  
			result.put("F108_TARGET_TUBEWGT", target_T);

	    	
	    	for(int i=0; i<ipqxFactoryMaps.length; i++) {  		
				Map m = ipqxFactoryMaps[i];
				
				if(!aaTool.getStr(m.get("廠區名稱")).equals("108")) continue;
					result.put("F108_T_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("F108_T_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("F108_T_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_T.intValue() > 0) {
						result.put("F108_T_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_T, 1, BigDecimal.ROUND_HALF_UP)));
					}
					
					result.put("F108_T_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
					result.put("F108_T_MACHWITHP_RATE", aaTool.getBigDecimal(m.get("稼動率")));
	    	}	
	    	
	    	//機台數
	    	for(int i=0; i<machCountMaps.length; i++) { 		
				Map m = machCountMaps[i];
				if(aaTool.getStr(m.get("廠區名稱")).equals("108")) {
					result.put("F108_MACHCOUNT", aaTool.getBigDecimal(m.get("機台數")));
				}
	    	}
	  
	    	//單位成本
//	    	if (unitCostTRMaps != null && unitCostTRMaps.length > 0) {
//				for(int i=0; i<unitCostTRMaps.length; i++) {
//					Map m = unitCostTRMaps[i]; 
//					if(aaTool.getStr(m.get("PRODTYPE")).equals("T")) {
//						result.put("F108_UNITCOST", aaTool.getBigDecimal(m.get("單價")));
//					}
//				}
//	    	}
//
//				    		
//			//人工製費	
//	    	if (expTRMaps != null && expTRMaps.length > 0) {
//				for(int i=0; i<expTRMaps.length; i++) {
//					Map m = expTRMaps[i]; 	
//					if(aaTool.getStr(m.get("FACTORY")).equals("A")) {
//						result.put("F108_EXP", aaTool.getBigDecimal(m.get("單價")));
//					}
//				}
//	    	}   
			return result;	
		} catch(Exception e){
			throw e;
		} 
	}
    
    
    public Map getProdDataF105FromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target, Map[] ipqxFactoryMaps, Map[] machCountMaps) throws Exception {
      	 
		try { 
			Map result = new HashMap();
	    	BigDecimal target_P = aaTool.getBigDecimal(target.get("TR_TARGET_PIPEWGT"));

			result.put("F105_TARGET_PIPEWGT", target_P);
	    	for(int i=0; i<ipqxFactoryMaps.length; i++) {
				Map m = ipqxFactoryMaps[i];
				if(!aaTool.getStr(m.get("廠區名稱")).equals("105")) continue;
					result.put("F105_P_PROD_TON", aaTool.getBigDecimal(m.get("產量")));
					result.put("F105_P_SHARP_RATE", aaTool.getBigDecimal(m.get("成材率")));
					result.put("F105_P_YIELD_RATE", aaTool.getBigDecimal(m.get("良品率")));

					if(target_P.intValue() > 0) {
						result.put("F105_P_TARGET_RATE", aaTool.getBigDecimal(aaTool.getBigDecimal(m.get("產量")).multiply(new BigDecimal(100)).divide(
								target_P, 1, BigDecimal.ROUND_HALF_UP)));
					}	
					result.put("F105_P_MACH_RATE", aaTool.getBigDecimal(m.get("稼動率_含無人待料")));
					result.put("F105_P_MACHWITHP_RATE", aaTool.getBigDecimal(m.get("稼動率")));
	    	}	

	    	//機台數
	    	for(int i=0; i<machCountMaps.length; i++) {
				Map m = machCountMaps[i];
				if(aaTool.getStr(m.get("廠區名稱")).equals("105")) {
					result.put("F105_MACHCOUNT", aaTool.getBigDecimal(m.get("機台數")));
				}
	    	}
	  
	    	//單位成本
//	    	if (unitCostTRMaps != null && unitCostTRMaps.length > 0) {
//				for(int i=0; i<unitCostTRMaps.length; i++) {
//					Map m = unitCostTRMaps[i]; 	
//					if(aaTool.getStr(m.get("PRODTYPE")).equals("P")) {
//						result.put("F105_UNITCOST", aaTool.getBigDecimal(m.get("單價")));
//					}
//				}
//	    	}
//
//				    		
//			//人工製費		
//	    	if (expTRMaps != null && expTRMaps.length > 0) {
//				for(int i=0; i<expTRMaps.length; i++) {
//					Map m = expTRMaps[i]; 		
//					if(aaTool.getStr(m.get("FACTORY")).equals("C")) {
//						result.put("F105_EXP", aaTool.getBigDecimal(m.get("單價")));
//					}
//				}
//	    	}
	    	
			return result;

		} catch(Exception e){
			throw e;
		} 
	}
    
    
    public Map getProdDataF109FromIPQX(dsjccom dsCom,Connection conCIC, String endDate, Map target, Map[] ipqxMaps, Map[] machCountMaps) throws Exception {
      	 
		try { 
			Map result = new HashMap();
	    	BigDecimal target_C = aaTool.getBigDecimal(target.get("TR_TARGET_SHEETWGT"));
			result.put("F109_TARGET_SHEETWGT", target_C);
 
			/*
			 * 109資料直接抓上面總表 "TR 綜合指標" 的資料
			 */
	    	
	    	//機台數
	    	for(int i=0; i<machCountMaps.length; i++) {    		
				Map m = machCountMaps[i];	
				if(aaTool.getStr(m.get("廠區名稱")).equals("109")) {
					result.put("F109_MACHCOUNT", aaTool.getBigDecimal(m.get("機台數")));
				}

	    	}
	  
	    	//單位成本
//			for(int i=0; i<unitCostTRMaps.length; i++) {
//				Map m = unitCostTRMaps[i]; 
//				if(aaTool.getStr(m.get("PRODTYPE")).equals("C")) {
//					result.put("F109_UNITCOST", aaTool.getBigDecimal(m.get("單價")));
//				}
//			}
//				    		
//			//人工製費			
//			for(int i=0; i<expTRMaps.length; i++) {
//				Map m = expTRMaps[i]; 	
//				if(aaTool.getStr(m.get("FACTORY")).equals("C")) {
//					result.put("F109_EXP", aaTool.getBigDecimal(m.get("單價")));
//				}
//			}
	    	
	     
			return result;
			
			
		} catch(Exception e){
			throw e;
		} 
	}
    
    //TW人力
    public Map gethumandata(dsjccom dsCom, Connection conCIC, Map[] humanMaps) throws Exception {
        
        try { 

            Map factoryKeyMap = new HashMap();
            
            if (humanMaps != null && humanMaps.length > 0) {
                
                for (int i = 0; i < humanMaps.length; i++) {
                    Map HUM = humanMaps[i];
                    
                    String factoryName = (String) HUM.get("廠別");
                    if (factoryName == null || "".equals(factoryName)) {
                        factoryName = "未知廠別_" + i; // 防呆，避免 key 是空的
                    }
                    
                    // 抓取原本 SQL 查出來的台籍、外籍人數
                    java.math.BigDecimal mTaiwan    = aaTool.getBigDecimal(HUM.get("製造台籍人數"));
                    java.math.BigDecimal mForeign   = aaTool.getBigDecimal(HUM.get("製造外籍人數"));
                    java.math.BigDecimal pTaiwan    = aaTool.getBigDecimal(HUM.get("加工台籍人數"));
                    java.math.BigDecimal pForeign   = aaTool.getBigDecimal(HUM.get("加工外籍人數"));
                    java.math.BigDecimal mbTaiwan   = aaTool.getBigDecimal(HUM.get("廠務台籍人數"));
                    java.math.BigDecimal mbForeign  = aaTool.getBigDecimal(HUM.get("廠務外籍人數"));
                    java.math.BigDecimal eTaiwan    = aaTool.getBigDecimal(HUM.get("生管成品台籍人數"));
                    java.math.BigDecimal eForeign   = aaTool.getBigDecimal(HUM.get("生管成品外籍人數"));
                    java.math.BigDecimal m41Taiwan  = aaTool.getBigDecimal(HUM.get("設備台籍人數"));
                    java.math.BigDecimal m41Foreign = aaTool.getBigDecimal(HUM.get("設備外籍人數"));
                    java.math.BigDecimal elseTaiwan = aaTool.getBigDecimal(HUM.get("其他台籍人數"));
                    java.math.BigDecimal elseForeign= aaTool.getBigDecimal(HUM.get("其他外籍人數"));
                    
                    // 計算各分類的 小計 (台籍 + 外籍)
                    java.math.BigDecimal mTotal    = mTaiwan.add(mForeign);
                    java.math.BigDecimal pTotal    = pTaiwan.add(pForeign);
                    java.math.BigDecimal mbTotal   = mbTaiwan.add(mbForeign);
                    java.math.BigDecimal eTotal    = eTaiwan.add(eForeign);
                    java.math.BigDecimal m41Total  = m41Taiwan.add(m41Foreign);
                    java.math.BigDecimal elseTotal = elseTaiwan.add(elseForeign);

                    // 計算 國籍加總
                    java.math.BigDecimal allTaiwan  = mTaiwan.add(pTaiwan).add(mbTaiwan).add(eTaiwan).add(m41Taiwan).add(elseTaiwan);
                    java.math.BigDecimal allForeign = mForeign.add(pForeign).add(mbForeign).add(eForeign).add(m41Foreign).add(elseForeign);
                    
                    // 計算 該廠全廠總人數
                    java.math.BigDecimal grandTotal = allTaiwan.add(allForeign);

                    // 把計算好的結果，塞回當前這個廠別的 Map 裡面
                    HUM.put("製造總人數", mTotal);
                    HUM.put("加工總人數", pTotal);
                    HUM.put("廠務總人數", mbTotal);
                    HUM.put("生管成品總人數", eTotal);
                    HUM.put("設備總人數", m41Total);
                    HUM.put("其他總人數", elseTotal);
                    
                    HUM.put("台籍總人數", allTaiwan);
                    HUM.put("外籍總人數", allForeign);
                    HUM.put("全廠總人數", grandTotal);
                                      
                    factoryKeyMap.put(factoryName, HUM);
                }
            }
                    
            // 回傳這個以廠別為 Key 的大 Map
            return factoryKeyMap; 
            
        } catch(Exception e){
            throw e;
        } 
    }
    
	    public Map<String, Map<String, Object>> getALLhumandata(dsjccom dsCom, Connection conCIC, Map[] ALLhumanMaps) throws Exception {
	        try {
	            Map<String, Map<String, Object>> resultMap = new HashMap<>();
	
	            if (ALLhumanMaps != null && ALLhumanMaps.length > 0) {
	                // 建立一個總表 Map
	                Map<String, Object> totalMap = new HashMap<>();
	
	                BigDecimal allTaiwan = BigDecimal.ZERO;
	                BigDecimal allForeign = BigDecimal.ZERO;
	
	                for (int i = 0; i < ALLhumanMaps.length; i++) {
	                    Map HUM = ALLhumanMaps[i];
	
	                    String category = (String) HUM.get("分類");
	                    if (category == null || "".equals(category)) {
	                        category = "其他";
	                    }
	
	                    BigDecimal taiwan = aaTool.getBigDecimal(HUM.get("台籍人數"));
	                    BigDecimal foreign = aaTool.getBigDecimal(HUM.get("外籍人數"));
	                    BigDecimal total = taiwan.add(foreign);
	
	                    // 塞回原本的固定欄位名稱
	                    totalMap.put(category + "台籍人數", taiwan);
	                    totalMap.put(category + "外籍人數", foreign);
	                    totalMap.put(category + "總人數", total);
	
	                    // 累加總計
	                    allTaiwan = allTaiwan.add(taiwan);
	                    allForeign = allForeign.add(foreign);
	                }
	
	                // 全部總計
	                BigDecimal grandTotal = allTaiwan.add(allForeign);
	                totalMap.put("台籍總人數", allTaiwan);
	                totalMap.put("外籍總人數", allForeign);
	                totalMap.put("全廠總人數", grandTotal);
	
	                // 因為這個 SQL 是三個廠的總合，所以 key 就用 "全部廠別"
	                resultMap.put("全部廠別", totalMap);
	            }
	
	            return resultMap;
	        } catch (Exception e) {
	            throw e;
	        }
	    }

    
    public static String getIPQXsql(String endDateYM){
		 
 		String sql = " SELECT                                                                                                                "+       
 				"    區域,PRODTYPE, FIN_廠區 AS 廠區,                                                                                   "+           
 				" 	sum(a.成材重量/1000) AS 產量,                                                                                       "+    
 				" 	round(sum(a.原料重量-a.餘退重量-a.接頭重量-a.原料不良重量-a.廢管重量)*100/sum(a.原料重量-a.餘退重量), 2) AS 成材率, "+    
 				" 	round(sum(a.Q型態良品重量)*100/sum(a.原料重量-a.餘退重量), 2) AS 良品率                                             "+    
 				" FROM(                                                                                                                 "+      
 				" 	SELECT                                                                                                              "+    
 				" 		 CASE WHEN b.財務型態 = '配管' THEN 'P'                                                                           "+  
 				" 			   WHEN b.財務型態 = '構造管' THEN 'T'                                                                          "+
 				" 			   WHEN b.財務型態 IN ('鋼捲','鋼板') THEN 'C'                                                                  "+
 				" 		  ELSE '其他' END AS PRODTYPE                                                                                     "+  
 				" 		, CASE WHEN b.財務型態 = '配管' THEN 'D'                                                                          "+  
 				" 			   WHEN b.財務型態 = '構造管' THEN 'B'                                                                          "+
 				" 			   WHEN b.財務型態 IN ('鋼捲','鋼板') THEN 'C'                                                                  "+
 				" 		  ELSE '其他' END AS FIN_廠區                                                                                     "+
 				" 		, CASE WHEN  a.廠區名稱 IN ('105','108') THEN 'TR' ELSE 'TW' END AS 區域                                          "+                                           
 				" 		, a.成材重量                                                                                                      "+  
 				" 		, a.原料重量, a.接頭重量, a.原料不良重量, a.廢管重量, a.餘退重量                                                  "+  
 				" 		,  CASE WHEN  a.廠區名稱 IN ('105','108')THEN a.良品重量 ELSE a.Q型態良品重量 END AS Q型態良品重量                "+                                                                                  
 				" 	FROM dbo.[IPQ111_製造日報] a                                                                                        "+    
 				" 	LEFT JOIN dbo.[ITP3_產品型態] b                                                                                     "+    
 				" 	ON a.型態 = b.產品型態                                                                                              "+  
 			    "   AND (    (a.廠區名稱 IN ('溪州','斗二') AND b.區域 = 'TW') OR                                                            "+
 			    "       (a.廠區名稱 IN ('105','108') AND b.區域 = 'TR') )                                                               "+
 				" 	WHERE a.完工日期 LIKE '"+ endDateYM +"%'  AND a.廠區名稱 IN ('溪州','斗二','105','108')                               "+
 				"   AND b.財務型態 IN ('配管','構造管')                                                                   "+
 				" )a GROUP BY  PRODTYPE, FIN_廠區, 區域                                                                                 ";       
 			
 		return sql;
 	}
    
    
    
    public static String getIPQXbyFactorysql(String endDateYM){
		 
 		String sql = " SELECT a.廠區, a.廠區名稱, a.產量, a.成材率, a.良品率, b.稼動率, b.稼動率_含無人待料 FROM (                                                                                                       "+
 				"         SELECT a.廠區                                                                                                                                  "+
 				"         , a.廠區名稱                                                                                                                                   "+
 				"         , sum(a.成材重量/1000) AS 產量                                                                                                                 "+
 				"         , round(sum(a.原料重量-a.餘退重量-a.接頭重量-a.原料不良重量-a.廢管重量)*100/sum(a.原料重量-a.餘退重量), 2) AS 成材率                           "+
 				"         , round(sum( CASE WHEN  a.廠區名稱 IN ('溪州','斗二') THEN a.Q型態良品重量 ELSE a.良品重量 END )*100/sum(a.原料重量-a.餘退重量), 2) AS 良品率  "+
 				"         FROM dbo.IPQ111_製造日報 a                                                                                                                     "+
 				"         WHERE a.完工日期 LIKE '"+ endDateYM +"%'   AND a.廠區名稱 IN ('溪州','斗二','105','108')                                                                "+
 				"         GROUP BY a.廠區, a.廠區名稱                                                                                                                    "+
 				" ) a                                                                                                                                                    "+
 				" LEFT JOIN (                                                                                                                                            "+
 				"         SELECT a.廠區                                                                                                                                  "+
 				"         , a.廠區名稱                                                                                                                                   "+
 				"         , round(sum(a.開機時數)*100.00/sum(a.上班時數), 0) AS 稼動率                                                                                   "+
 				"         , round(sum(a.開機時數)*100.00/sum(a.上班時數+a.無人+a.待料), 0) AS 稼動率_含無人待料                                                          "+
 				"         FROM dbo.IPQ116 a                                                                                                                              "+
 				"         WHERE a.年月='"+ endDateYM +"' AND a.廠區名稱 IN ('溪州','斗二','105','108')                                                                            "+
 				"        GROUP BY a.廠區, a.廠區名稱                                                                                                                     "+ 
 				" ) b ON a.廠區=b.廠區                                                                                                                                   ";
 			
 			
 		return sql;
 	}
    
    
    public static String getIPQ116sql(){
		 
 		String sql =" SELECT a.區域, a.廠區                                                                  "+   
 				" , a.廠區名稱                                                                           "+
 				" , round(sum(a.開機時數)*100.00/sum(a.上班時數), 0) AS 稼動率                           "+
 				" , round(sum(a.開機時數)*100.00/sum(a.上班時數+a.無人+a.待料), 0) AS 稼動率_含無人待料  "+
 				" FROM dbo.IPQ116 a                                                                      "+
 				" WHERE a.年月='202605' AND a.區域 IN ('TW','TR')                                     "+
 				" GROUP BY a.區域, a.廠區, a.廠區名稱                                                    ";
 			
 			
 		return sql;
 	}
    
    
    public static String getTW_UnitCostsql(String endDateYM){
		 
 		String sql = " SELECT                                                                                            "+
 				"           SUBSTR(A.TRANDATE,1,6) AS YM,                                                           "+
 				"           CASE WHEN e.FINACIALTYPE IN ( '配管','無縫配管') THEN 'P'                               "+
 				"                WHEN  e.FINACIALTYPE = '構造管' THEN 'T'                                           "+
 				"                WHEN e.PRODCLASSNO='H' THEN 'F/L'                                                  "+
 				"                WHEN f.PRODTYPE IN ('X','Y','K') AND f.SURFCODE NOT LIKE 'N%' THEN 'CR_Secondary'  "+
 				"                WHEN e.PRODCLASSNO='Y' THEN 'By product'                                           "+
 				"                WHEN e.PRODCLASSNO='Z' THEN 'Scrap'                                                "+
 				"                WHEN f.型態分類 IN ('C1-鋼板CR','D1-鋼捲CR','C2-鋼板HR','D2-鋼捲HR') THEN 'C'      "+
 				"           ELSE a.MATNO END AS PRODTYPE,                                                           "+
 				"           ROUND(SUM(A.重量),0) AS 庫存量,                                                         "+
 				"           ROUND(SUM(A.金額),0) AS 庫存金額,                                                       "+
 				"           ROUND(SUM(A.金額),1)*1.0 / ROUND(SUM(A.重量),0) AS 單價                                 "+
 				" FROM DB.VIEWIGF交易明細含期初期末 a                                                               "+
 				" JOIN DB.TBIGFB02 b ON b.COMPID='yc' AND a.MATNO=b.MATNO                                           "+
 				" LEFT JOIN DB.TBWYSM019_SALES f ON f.MATRLNO=b.PRODMATRLNO                                         "+
 				" LEFT JOIN DB.TBTP02 e ON e.COMPID='yc' AND f.INVTYPE = e.PRODTYPENO                               "+
 				" WHERE  A.TRANDATE LIKE '"+ endDateYM +"%'                                                           "+
 				" AND b.OWNER='yc'                                                                                  "+
 				" AND A.TALLYITEM ='99'                                                                             "+
 				" GROUP BY SUBSTR(A.TRANDATE,1,6),                                                                  "+
 				"           CASE WHEN e.FINACIALTYPE IN ( '配管','無縫配管') THEN 'P'                               "+
 				"                WHEN  e.FINACIALTYPE = '構造管' THEN 'T'                                           "+
 				"                WHEN e.PRODCLASSNO='H' THEN 'F/L'                                                  "+
 				"                WHEN f.PRODTYPE IN ('X','Y','K') AND f.SURFCODE NOT LIKE 'N%' THEN 'CR_Secondary'  "+
 				"                WHEN e.PRODCLASSNO='Y' THEN 'By product'                                           "+
 				"                WHEN e.PRODCLASSNO='Z' THEN 'Scrap'                                                "+
 				"                WHEN f.型態分類 IN ('C1-鋼板CR','D1-鋼捲CR','C2-鋼板HR','D2-鋼捲HR') THEN 'C'      "+
 				"           ELSE a.MATNO END                                                                        "; 
 			
 		return sql;
 	}
    
    
    public static String getTR_UnitCostsql(String endDateYM){
		 
 		String sql = " SELECT                                                                                            "+
 				"           SUBSTR(A.TRANDATE,1,6) AS YM,                                                           "+
 				"           CASE WHEN e.FINACIALTYPE IN ( '配管','無縫配管') THEN 'P'                               "+
 				"                WHEN  e.FINACIALTYPE = '構造管' THEN 'T'                                           "+
 				"                WHEN e.PRODCLASSNO='H' THEN 'F/L'                                                  "+
 				"                WHEN f.PRODTYPE IN ('X','Y','K') AND f.SURFCODE NOT LIKE 'N%' THEN 'CR_Secondary'  "+
 				"                WHEN e.PRODCLASSNO='Y' THEN 'By product'                                           "+
 				"                WHEN e.PRODCLASSNO='Z' THEN 'Scrap'                                                "+
 				"                WHEN f.型態分類 IN ('C1-鋼板CR','D1-鋼捲CR','C2-鋼板HR','D2-鋼捲HR') THEN 'C'      "+
 				"           ELSE a.MATNO END AS PRODTYPE,                                                           "+
 				"           ROUND(SUM(A.重量),0) AS 庫存量,                                                         "+
 				"           ROUND(SUM(A.金額),0) AS 庫存金額,                                                       "+
 				"           ROUND(SUM(A.金額),1)*1.0 / ROUND(SUM(A.重量),0) AS 單價                                 "+
 				" FROM DB.VIEWIGF交易明細含期初期末 a                                                               "+
 				" JOIN DB.TBIGFB02 b ON b.COMPID='yc' AND a.MATNO=b.MATNO                                           "+
 				" LEFT JOIN DB.TBWYSM019_SALES f ON f.MATRLNO=b.PRODMATRLNO                                         "+
 				" LEFT JOIN DB.TBTP02 e ON e.COMPID='yc' AND f.INVTYPE = e.PRODTYPENO                               "+
 				" WHERE  A.TRANDATE LIKE '"+ endDateYM +"%'                                                                 "+
 				" AND b.OWNER='yc'                                                                                  "+
 				" AND A.TALLYITEM ='99'                                                                             "+
 				" GROUP BY SUBSTR(A.TRANDATE,1,6),                                                                  "+
 				"           CASE WHEN e.FINACIALTYPE IN ( '配管','無縫配管') THEN 'P'                               "+
 				"                WHEN  e.FINACIALTYPE = '構造管' THEN 'T'                                           "+
 				"                WHEN e.PRODCLASSNO='H' THEN 'F/L'                                                  "+
 				"                WHEN f.PRODTYPE IN ('X','Y','K') AND f.SURFCODE NOT LIKE 'N%' THEN 'CR_Secondary'  "+
 				"                WHEN e.PRODCLASSNO='Y' THEN 'By product'                                           "+
 				"                WHEN e.PRODCLASSNO='Z' THEN 'Scrap'                                                "+
 				"                WHEN f.型態分類 IN ('C1-鋼板CR','D1-鋼捲CR','C2-鋼板HR','D2-鋼捲HR') THEN 'C'      "+
 				"           ELSE a.MATNO END                                                                        "; 
 			
 		return sql;
 	}
    
    
    
    public static String getTW_IAC4Nsql(String endDateYM){
		 
 		String sql = " SELECT a.FACTORY, SUM(a.WGT) AS 重量, SUM(a.AMT) AS 金額, SUM(a.AMT)*1.00/SUM(a.WGT) AS 單價 "+
 				" FROM db.TB_BI_AC_WMP_NEW a                                                                   "+
 				" WHERE a.DATEYM like '"+ endDateYM.substring(0, 4) +"%'                                       "+
 				" AND a.LINE LIKE '%製管%' AND a.FACTORY IN ('B','D')                                          "+
 				" GROUP BY a.FACTORY                                                                           "+
 				" UNION ALL                                                                                    "+
 				" SELECT a.FACTORY, SUM(a.WGT) AS 重量, SUM(a.AMT) AS 金額, SUM(a.AMT)*1.00/SUM(a.WGT) AS 單價 "+
 				" FROM db.TB_BI_AC_WMS_NEW a                                                                   "+
 				" WHERE a.DATEYM like '"+ endDateYM.substring(0, 4) +"%'                                       "+
 				" AND a.LINE = '切板' AND a.FACTORY IN ('C')                                                   "+
 				" GROUP BY a.FACTORY                                                                           "; 
 			
 		return sql;
 	}
    
    
    public static String getTR_IAC4Nsql(String endDateYM){
		 
 		String sql = " SELECT a.FACTORY, SUM(a.WGT) AS 重量, SUM(a.AMT) AS 金額, SUM(a.AMT)*1.00/SUM(a.WGT) AS 單價 "+
 				" FROM db.TB_BI_AC_WMP_NEW a                                                                   "+
 				" WHERE a.DATEYM like '"+ endDateYM.substring(0, 4) +"%'                                   "+
 				" AND a.LINE LIKE '%製管%' AND a.FACTORY IN ('A','C')                                   "+
 				" GROUP BY a.FACTORY                                                                           "+
 				" UNION ALL                                                                                    "+
 				" SELECT a.FACTORY, SUM(a.WGT) AS 重量, SUM(a.AMT) AS 金額, SUM(a.AMT)*1.00/SUM(a.WGT) AS 單價 "+
 				" FROM db.TB_BI_AC_WMS_NEW a                                                                   "+
 				" WHERE a.DATEYM like '"+ endDateYM.substring(0, 4) +"%'                                       "+
 				" AND a.LINE = '切板' AND a.FACTORY IN ('B')                                                   "+
 				" GROUP BY a.FACTORY                                                                           "; 
 			
 		return sql;
 	}
    
    
    
    public static String getIPQ137sql(String endDateYM){
		 
// 		String sql =" SELECT a.區域,a.廠區,a.產量,a.成材率,a.良品率, b.稼動率 FROM (                                                                                                    "+                          
// 				"         SELECT a.區域,a.廠區                                                                                                                                      "+                     
// 				"                 , a.廠區名稱                                                                                                                                      "+              
// 				"                 , round(sum(a.產出重量/1000), 0) AS 產量                                                                                                          "+              
// 				"                 , round(sum(a.原料重量-a.退庫重量-a.頭尾重量-a.ENDCOIL重量-a.修邊重量-a.中料重量-窄幅重量)*100/sum(a.原料重量-a.退庫重量), 2) AS 成材率           "+              
// 				"                 , round(sum(a.原料重量-a.退庫重量-a.頭尾重量-a.ENDCOIL重量-a.修邊重量-a.中料重量-窄幅重量-次級重量)*100/sum(a.原料重量-a.退庫重量), 2) AS 良品率  "+              
// 				"         FROM (                                                                                                                                                    "+              
// 				"                 SELECT a.區域, a.廠區, a.廠區名稱, a.裁剪單號, a.原料重量, a.退庫重量, a.頭尾重量, a.ENDCOIL重量, a.修邊重量, a.中料重量                          "+                      
// 				"                         , SUM(CASE WHEN a.產出類別='A3' THEN a.產出重量 ELSE 0 END) AS 次級重量                                                                   "+              
// 				"                         , SUM(CASE WHEN a.產出類別='A4' THEN a.產出重量 ELSE 0 END) AS 窄幅重量                                                                   "+              
// 				"                         , SUM(CASE WHEN a.產出分類='成品產出' THEN a.產出重量 ELSE 0 END) AS 產出重量                                                             "+              
// 				"                 FROM dbo.[IPQ137_裁剪日報] a                                                                                                                      "+              
// 				"                 WHERE a.[生產日期] LIKE '"+ endDateYM +"%' AND a.配料種類='1'  AND a.廠區名稱 IN('斗一','109')                                                    "+
// 				"                 GROUP BY a.區域, a.廠區, a.廠區名稱, a.裁剪單號, a.原料重量, a.退庫重量, a.頭尾重量, a.ENDCOIL重量, a.修邊重量, a.中料重量                        "+                      
// 				"         ) a                                                                                                                                                       "+              
// 				"         GROUP BY a.區域, a.廠區, a.廠區名稱                                                                                                                       "+                      
// 				" ) a                                                                                                                                                               "+              
// 				" LEFT JOIN (                                                                                                                                                       "+              
// 				"         SELECT a.區域, a.廠別 AS 廠區                                                                                                                             "+                      
// 				"                 , a.廠別名稱 AS 廠區名稱                                                                                                                          "+              
// 				"                 , round(sum(a.開機時數)*100.00/sum(a.上班時數), 0) AS 稼動率                                                                                      "+              
// 				"         FROM dbo.IPQ13I a                                                                                                                                         "+              
// 				"         WHERE a.年月 LIKE '"+ endDateYM +"%'  AND a.廠別名稱 IN('斗一廠','109')                                                                                                  "+           
// 				"         GROUP BY a.區域,a.廠別, a.廠別名稱                                                                                                                        "+                     
// 				" ) b ON a.區域 = b.區域 AND a.廠區=b.廠區                                                                                                                          ";
 			
    	String sql = " SELECT a.區域,a.廠區,a.產量,a.成材率,a.良品率, b.稼動率 FROM(                                                                              "+
    	"                                                                                                                                            "+
    	" 	SELECT 區域, 廠區, 廠區名稱,                                                                                                             "+
    	" 	round(sum(a.產出重量/1000), 0) AS 產量 ,                                                                                                 "+
    	" 	round(sum(成材量)*100/sum(原料重量- 餘退重量),2) AS 成材率,                                                                              "+
    	" 	round(sum(良品量 )*100/sum(原料重量- 餘退重量),2) AS 良品率                                                                              "+
    	" 	                                                                                                                                         "+
    	" 	FROM (                                                                                                                                   "+
    	" 			SELECT a.區域,a.廠區                                                                                                                 "+                    
    	" 			        , a.廠區名稱                                                                                                                 "+
    	" 			        ,sum(a.原料重量) AS 原料重量 ,sum(a.退庫重量) AS 餘退重量                                                                    "+                                                               
    	" 			        , sum(a.產出重量) AS 產出重量                                                                                                "+         
    	" 			        , sum(a.原料重量-a.退庫重量-a.頭尾重量-a.ENDCOIL重量-a.修邊重量-a.中料重量-窄幅重量) AS 成材量                               "+
    	" 			        , sum(a.原料重量-a.退庫重量-a.頭尾重量-a.ENDCOIL重量-a.修邊重量-a.中料重量-窄幅重量-次級重量)  AS 良品量                     "+
    	" 			FROM (                                                                                                                               "+                    
    	" 			        SELECT a.區域, a.廠區, a.廠區名稱, a.裁剪單號, a.原料重量, a.退庫重量, a.頭尾重量, a.ENDCOIL重量, a.修邊重量, a.中料重量     "+                    
    	" 			                , SUM(CASE WHEN a.產出類別='A3' THEN a.產出重量 ELSE 0 END) AS 次級重量                                              "+                    
    	" 			                , SUM(CASE WHEN a.產出類別='A4' THEN a.產出重量 ELSE 0 END) AS 窄幅重量                                              "+                    
    	" 			                , SUM(CASE WHEN a.產出分類='成品產出' THEN a.產出重量 ELSE 0 END) AS 產出重量                                        "+                    
    	" 			        FROM dbo.[IPQ137_裁剪日報] a                                                                                                 "+                    
    	" 			        WHERE a.[生產日期] LIKE '"+ endDateYM +"%'AND a.配料種類='1'  AND a.廠區名稱 IN('斗一','109')                                        "+           
    	" 			        GROUP BY a.區域, a.廠區, a.廠區名稱, a.裁剪單號, a.原料重量, a.退庫重量, a.頭尾重量, a.ENDCOIL重量, a.修邊重量, a.中料重量   "+                     
    	" 			) a                                                                                                                                  "+                    
    	" 			GROUP BY a.區域, a.廠區, a.廠區名稱                                                                                                  "+
    	" 			                                                                                                                                     "+
    	" 			UNION ALL                                                                                                                            "+
    	" 			                                                                                                                                     "+
    	" 			SELECT                                                                                                                               "+
    	" 			    區域 , FIN_廠區 AS 廠區, a.廠區名稱, sum(a.原料重量) AS 原料重量, sum(a.餘退重量) AS 餘退重量,                                   "+                                                           
    	" 			   	sum(a.成材重量) AS 產出重量,                                                                                                     "+
    	" 			   	sum(a.原料重量-a.餘退重量-a.接頭重量-a.原料不良重量-a.廢管重量) AS 成材量,                                                       "+
    	" 			   	sum(a.Q型態良品重量) AS 良品量                                                                                                   "+
    	" 			FROM(                                                                                                                                "+
    	" 			   	SELECT                                                                                                                           "+
    	" 			   		 CASE WHEN b.財務型態 IN ('扁鐵','角鐵') THEN 'C' ELSE '其他' END AS PRODTYPE                                                  "+                                
    	" 			   		, CASE  WHEN b.財務型態 IN ('扁鐵','角鐵') THEN 'C' ELSE '其他' END AS FIN_廠區                                                "+
    	" 			   		, a.廠區名稱                                                                                                                   "+
    	" 			   		, CASE WHEN  a.廠區名稱 IN ('斗一') THEN 'TW' ELSE '其他' END AS 區域                                                          "+           
    	" 			   		, a.成材重量                                                                                                                   "+
    	" 			   		, a.原料重量, a.接頭重量, a.原料不良重量, a.廢管重量, a.餘退重量                                                               "+
    	" 			   		,  CASE WHEN  a.廠區名稱 IN ('105','108')THEN a.良品重量 ELSE a.Q型態良品重量 END AS Q型態良品重量                             "+                                                     
    	" 			   	FROM dbo.[IPQ111_製造日報] a                                                                                                     "+
    	" 			   	LEFT JOIN dbo.[ITP3_產品型態] b                                                                                                  "+
    	" 			   	ON a.型態 = b.產品型態                                                                                                           "+
    	" 			    AND ( (a.廠區名稱 IN ('斗一') AND b.區域 = 'TW') )                                                                               "+
    	" 			   	WHERE a.完工日期 LIKE '"+ endDateYM +"%'  AND a.廠區名稱 IN ('斗一')                                                                      "+
    	" 			    AND b.財務型態 IN  ('扁鐵','角鐵')                                                                                               "+
    	" 			)a GROUP BY 區域 , FIN_廠區 , a.廠區名稱                                                                                             "+
    	" 	) a GROUP BY 區域, 廠區, 廠區名稱                                                                                                        "+
    	" )a LEFT JOIN (                                                                                                                             "+                         
    	"          SELECT a.區域, a.廠別 AS 廠區                                                                                                     "+                       
    	"                  , a.廠別名稱 AS 廠區名稱                                                                                                  "+                       
    	"                  , round(sum(a.開機時數)*100.00/sum(a.上班時數), 0) AS 稼動率                                                              "+                       
    	"          FROM dbo.IPQ13I a                                                                                                                 "+                       
    	"          WHERE a.年月 LIKE '"+ endDateYM +"%'  AND a.廠別名稱 IN('斗一廠','109')                                                                    "+              
    	"          GROUP BY a.區域,a.廠別, a.廠別名稱                                                                                                "+                       
    	" ) b ON a.區域 = b.區域 AND a.廠區=b.廠區                                                                                                   ";
    	
    	
    	
 		return sql;
 	}
    
    
    
    public static String getMachCountsql(){
		 
 		String sql =" SELECT a.廠區                                                                                                                                            "+
 				"         , a.廠區名稱                                                                                                                                     "+
 				"         , sum(a.裁剪機台數+a.製管機台數) AS 機台數                                                                                                       "+
 				" FROM (                                                                                                                                                   "+
 				"         SELECT a.廠區                                                                                                                                    "+
 				"                 , a.廠區名稱                                                                                                                             "+
 				"                 , 0 AS 裁剪機台數                                                                                                                        "+
 				"                 , SUM(CASE WHEN a.機台特性='A' THEN 1 ELSE 0 END) AS 製管機台數                                                                          "+
 				"         , SUM(CASE WHEN a.機台特性='B' THEN 1 ELSE 0 END) AS 加工機台數                                                                                  "+
 				"         , SUM(CASE WHEN a.機台特性='C' THEN 1 ELSE 0 END) AS 包裝機台數                                                                                  "+
 				"                                                                                                                                                          "+
 				"         FROM (                                                                                                                                           "+
 				"                 SELECT DISTINCT CASE WHEN a.廠區 IN ('108','埔心') THEN 'A' WHEN a.廠區 IN ('109','溪州') THEN 'B' WHEN a.廠區 IN ('105','斗一') THEN 'C'"+
 				"                        WHEN a.廠區 IN ('斗二') THEN 'D' END AS 廠區                                                                                      "+
 				"                 , a.廠區 AS 廠區名稱                                                                                                                     "+
 				"                 /* 機台特性為製管機台線外機台通通視為唯一組 */                                                                                           "+
 				"                 , CASE WHEN a.機台代號='DI0A' THEN 'A' WHEN a.機台特性='A' AND a.機台代號 LIKE 'DI%' THEN 'Z' ELSE a.機台特性 END AS 機台特性            "+
 				"                 , CASE WHEN a.共用機台='' THEN a.機台代號 ELSE a.共用機台 END AS 機台碼                                                                  "+
 				"                 FROM dbo.IWZPC1_製管機台 a                                                                                                               "+
 				"                 WHERE a.是否委外<>'Y' AND a.是否停用<>'Y'                                                                                             "+
 				"         ) a                                                                                                                                              "+
 				"         GROUP BY a.廠區, a.廠區名稱                                                                                                                      "+
 				"         UNION ALL                                                                                                                                        "+
 				"         SELECT a.廠區                                                                                                                                    "+
 				"                 , a.廠區名稱                                                                                                                             "+
 				"                 , count(DISTINCT a.機台代號) AS 裁剪機台數                                                                                               "+
 				"                 , 0 AS 製管機台數                                                                                                                        "+
 				"                 , 0 AS 加工機台數                                                                                                                        "+
 				"                 , 0 AS 包裝機台數                                                                                                                        "+
 				"         FROM dbo.IWZSAA_板捲機台 a                                                                                                                       "+
 				"         WHERE a.區域 IN('TW','TR') AND a.廠區名稱 IN ('斗一','109' ) AND a.是否委外<>'Y' AND a.狀態='Y'                                                  "+
 				"         GROUP BY a.廠區, a.廠區名稱                                                                                                                      "+
 				" ) a                                                                                                                                                      "+
 				" GROUP BY a.廠區, a.廠區名稱                                                                                                                              "; 
 		
 		return sql;
 	}
    
    public static String getTW_humansql(){
		 
 		
 		String sql = "	SELECT    廠別, "+
		 	  "  SUM(CASE WHEN 分類 = '廠務'     AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 廠務台籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '廠務'     AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 廠務外籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '生管成品' AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 生管成品台籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '生管成品' AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 生管成品外籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '製造'     AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 製造台籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '製造'     AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 製造外籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '加工'     AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 加工台籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '加工'     AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 加工外籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '設備'     AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 設備台籍人數, "+
		 	  "  SUM(CASE WHEN 分類 = '設備'     AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 設備外籍人數, "+
		 	  "  SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備','行政') AND empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 其他台籍人數, "+
		 	  "  SUM(CASE WHEN 分類 NOT IN ('廠務','生管成品','製造','加工','設備','行政') AND empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 其他外籍人數 "+
		 	  "	 FROM dbo.H01_人力結構 WHERE 服務 = '在職' "+
		 	  "  AND 廠別 IN ('斗六一廠', '斗六二廠', '總公司(溪州廠)') GROUP BY 廠別;    ";			
 		return sql;
 	}
     
    public static String getTW_ALLhumansql(){
		 
 		
  		String sql = "	SELECT    分類, "+
 		 	  "  SUM(CASE WHEN empno NOT LIKE '%Z%' THEN 1 ELSE 0 END) AS 台籍人數, "+
 		 	  "  SUM(CASE WHEN empno LIKE '%Z%'     THEN 1 ELSE 0 END) AS 外籍人數 "+

 		 	  "  FROM dbo.H01_人力結構 WHERE 服務 = '在職'  "+
 		 	  "  AND 廠別 IN ('斗六一廠', '斗六二廠', '總公司(溪州廠)') GROUP BY 分類; ";
 		 	 	
  		return sql;
  	}
      
    
}
