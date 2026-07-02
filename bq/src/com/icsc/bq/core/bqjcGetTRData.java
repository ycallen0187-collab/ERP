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

import java.util.Iterator;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.icsc.aa.yc.util.aajcYCATool;
import com.icsc.dpms.de.dejc318;
import com.icsc.dpms.ds.dsjccom;

public class bqjcGetTRData{
	private static final String PROCID = "BQJCGETTRDATA";
	public final static String CLASS_VERSION = "$Id: bqjcGetTRData.java,v 1.1 2026/06/15 00:08:56 yc13 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjcGetTRData(dsjccom dsCom) {
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
     * 隨時想加什麼參數，直接 put 進Map就好！
		Map queryMap = new HashMap();
		queryMap.put("FORMID", "BQ051");
		queryMap.put("ERPUSERID", "00859");
		queryMap.put("endDate_qry", "20260610");
     */
    public Map getDashboard(Map queryMap)throws Exception{
		//連接網址
		StringBuilder sb = new StringBuilder();
        //1.拼接 URL 前綴與 JSON 的開頭
        sb.append("http://172.21.0.1/erp/event/put/unitech/MES01.run.go?data=json&j={");
        sb.append("\"i\":{");
        
        //2.自動拆解 Map
        Iterator it = queryMap.entrySet().iterator();
        while (it.hasNext()) {
            // 傳統寫法：手動轉成 Map.Entry
            Map.Entry entry = (Map.Entry) it.next();
            
            //使用 String.valueOf 防呆，萬一有 value 不是 String 也不會當機
            String key = String.valueOf(entry.getKey());
            String value = String.valueOf(entry.getValue());
            
            //拼裝 JSON 欄位
            sb.append("\"").append(key).append("\":\"").append(value).append("\"");
            
            //如果後面還有資料，才補上逗號
            if (it.hasNext()) {
                sb.append(",");
            }
        }
        
        //3.補上 JSON 結尾與固定的 "t":"map"
        sb.append("},\"t\":\"map\"}");
		String locate = sb.toString();
		
		//URL相關設定
		long startTime = System.currentTimeMillis();
		System.out.println("[DEBUG TIME] 1.準備連線: " + (System.currentTimeMillis() - startTime));
		startTime = System.currentTimeMillis();
		//System.out.println("連接網址");
		java.net.URL url = new java.net.URL(locate);
		java.net.HttpURLConnection HUConn = (java.net.HttpURLConnection) url.openConnection() ;
		HUConn.setDoInput(true);
		HUConn.setDoOutput(true);
		HUConn.setRequestMethod("POST");
		
		System.out.println("[DEBUG TIME] 2.執行 connect: " + (System.currentTimeMillis() - startTime));
		startTime = System.currentTimeMillis();
		HUConn.connect();

		//執行url
        System.out.println("執行url");
        System.out.println("[DEBUG TIME] 3.取得 InputStream: " + (System.currentTimeMillis() - startTime));
		startTime = System.currentTimeMillis();
		java.io.BufferedReader br = new java.io.BufferedReader( new java.io.InputStreamReader(HUConn.getInputStream(),"UTF-8"));
		
		//執行結果
//        System.out.println("執行結果");
//		String buf = "";
//		while((buf=br.readLine())!=null){
//			System.out.println(buf);
//		}
		StringBuilder sbr = new StringBuilder();
		String buf = "";
		System.out.println("[DEBUG TIME] 4.開始讀取資料: " + (System.currentTimeMillis() - startTime));
		startTime = System.currentTimeMillis();
		while((buf=br.readLine())!=null){
			System.out.println(buf);
			sbr.append(buf);
		}
		System.out.println("[DEBUG TIME] 5.讀取資料結束: " + (System.currentTimeMillis() - startTime));
		startTime = System.currentTimeMillis();
		
        ObjectMapper mapper = new ObjectMapper();
        System.out.println("[DEBUG TIME] 6.開始 Jackson 解析: " + (System.currentTimeMillis() - startTime));
		startTime = System.currentTimeMillis();
        Map resultMap = mapper.readValue(sbr.toString(), Map.class);		//轉換為 Map
        System.out.println("[DEBUG TIME] 7.解析結束: " + (System.currentTimeMillis() - startTime));
		startTime = System.currentTimeMillis();
        //讀取測試
        //Map orderData = (Map) resultMap.get("orderData");
        //System.out.println("外銷管_銷貨量: " + orderData.get("外銷管_銷貨量"));
		
		//關閉連線
        System.out.println("關閉連線");
		br.close();
		HUConn.disconnect();
		
		return resultMap;
	}
}
