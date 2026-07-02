<%@page import="com.icsc.bq.core.bqjc042Factory"%>
<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.ds.dsjccom"%>
<%@ page import="com.icsc.bq.core.bqjc042" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ042"; %>

<%
	// 1. 保留原始邏輯：從主控檔傳下來的資料取出
	aajcYCATool aaTool = new aajcYCATool();
	String updateDate = aaTool.getStr(request.getParameter("updateDate"));
	// 2. 保留原始邏輯：dsCom 初始化
	dejc300 _de300 = new dejc300();
	dsjccom _dsCom = _de300.run(_AppId, this, request, response);
	if(_dsCom==null){ return ;
	}

	// 3. 保留原始邏輯：抓取各廠明細資料
    List factoryList = new ArrayList();
	bqjc042Factory bq042Factory = new bqjc042Factory(_dsCom);
    Map dashboardData = bq042Factory.getDashboardData(_dsCom, request);
     
	Map dashboardDataTR = bq042Factory.getTRDashboardData(_dsCom, request); //透過JSON 連TR
    
    Map tw = new HashMap();
    Map tr = new HashMap();
    Map xizhou = new HashMap();
    Map dou2 = new HashMap();
    Map dou1 = new HashMap();
    Map f108 = new HashMap();
    Map f108TR = new HashMap();
    Map f105 = new HashMap();
    Map f105TR = new HashMap();
    Map f109 = new HashMap(); // 新增 109 廠的資料結構
    Map f109TR = new HashMap();
    Map humanMap = new HashMap();

     
    tw = (Map) (dashboardData != null ? dashboardData.get("TW_PRODData") : new HashMap());
    tr = (Map) (dashboardData != null ? dashboardData.get("TR_PRODData") : new HashMap());
    xizhou = (Map) (dashboardData != null ? dashboardData.get("XIZHOU_PRODData") : new HashMap());
    dou2 = (Map) (dashboardData != null ? dashboardData.get("DOU2_PRODData") : new HashMap());
    dou1 = (Map) (dashboardData != null ? dashboardData.get("DOU1_PRODData") : new HashMap());
    f108 = (Map) (dashboardData != null ? dashboardData.get("F108_PRODData") : new HashMap());
    f108TR = (Map) (dashboardDataTR != null ? dashboardDataTR.get("F108_PRODData") : new HashMap()); //透過JSON 連TR
    f105 = (Map) (dashboardData != null ? dashboardData.get("F105_PRODData") : new HashMap());
    f105TR = (Map) (dashboardDataTR != null ? dashboardDataTR.get("F105_PRODData") : new HashMap());
    f109 = (Map) (dashboardData != null ? dashboardData.get("F109_PRODData") : new HashMap()); // 新增 109 廠 Dashboard 資料抓取
    f109TR = (Map) (dashboardDataTR != null ? dashboardDataTR.get("F109_PRODData") : new HashMap()); //透過JSON 連TR
    humanMap = (Map) (dashboardData != null ? dashboardData.get("humanList") : new HashMap());//TW人力
    java.util.Map xzhuman  = (java.util.Map) (humanMap != null ? humanMap.get("總公司(溪州廠)") : new java.util.HashMap());
    java.util.Map dl2human = (java.util.Map) (humanMap != null ? humanMap.get("斗六二廠") : new java.util.HashMap());
    java.util.Map dl1human = (java.util.Map) (humanMap != null ? humanMap.get("斗六一廠") : new java.util.HashMap());
    
  //TW三廠總人力
	java.util.Map ALLhumanMap = (java.util.Map) (dashboardData != null ? dashboardData.get("ALLhumanList") : new java.util.HashMap());
    java.util.Map allhuman = (java.util.Map) (ALLhumanMap != null ? ALLhumanMap.get("全部廠別") : new java.util.HashMap());
    
    for(int i = 0; i < factoryList.size(); i++) {
        Map tmp = (Map) factoryList.get(i);
        if(tmp == null) continue;
        String fId = tmp.get("factoryId") != null ? tmp.get("factoryId").toString().trim() : "";
        String fName = tmp.get("factoryName") != null ? tmp.get("factoryName").toString().trim() : "";
        
        if("TW".equals(fId) || fName.indexOf("TW") > -1) { tw = tmp; }
        else if("TR".equals(fId) || fName.indexOf("TR") > -1) { tr = tmp; }
        else if(fName.indexOf("溪州") > -1) { xizhou = tmp; }
        else if(fName.indexOf("斗二") > -1) { dou2 = tmp; }
        else if(fName.indexOf("斗一") > -1) { dou1 = tmp; }
        else if(fName.indexOf("108") > -1) { f108 = tmp; }
        else if(fName.indexOf("109") > -1) { f109 = tmp; } // 新增 109 廠的清單分流判斷
        else if(fName.indexOf("105") > -1) { f105 = tmp; }
    }
%>

<div id="ajax-target-content">

    <style>
      /* 手機版核心 CSS 結構 */
      .card {
        border-radius: 12px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
        background: #ffffff;
        transition: background-color 0.15s ease, transform 0.15s ease;
        position: relative;
        overflow: hidden;
      }
      
      .card:active {
        transform: scale(0.99);
        background-color: #fcfcfd;
      }

      /* 綜合指標與區域加總樣式 */
      .card.theme-region { border-left: 4px solid #8e8e93; margin-bottom: 12px; }
      .card.theme-region .factory-header { background: #f2f2f7; display: flex; align-items: center; padding: 10px 14px; }
      .region-grid { display: grid; grid-template-columns: 1.2fr 1fr 1fr 1fr; border-bottom: 1px solid #e5e5ea; }
      .region-grid.th { background: #f9f9fb; font-size: 11px; color: #555; font-weight: 600; padding: 6px 0; }
      .region-grid > * { padding: 8px 4px; text-align: center; align-self: center; }
      .region-grid > *:not(:last-child) { border-right: 1px solid #e5e5ea; }
      .region-cell-title { font-size: 13px; font-weight: 700; color: #1c1c1e; text-align: center; }
		
      /* 各廠明細手機專屬配色 */
      .card.theme-xizhou { border-left: 4px solid #007aff; margin-bottom: 12px; }
      .card.theme-xizhou .factory-header { background: #ebf5ff; padding: 10px 14px; }
      
      .card.theme-dou2 { border-left: 4px solid #34c759; margin-bottom: 12px; }
      .card.theme-dou2 .factory-header { background: #e8f9ee; padding: 10px 14px; }

      .card.theme-dou1 { border-left: 4px solid #ff9500; margin-bottom: 12px; }
      .card.theme-dou1 .factory-header { background: #fff8ec; padding: 10px 14px; }
      
      .card.theme-f108 { border-left: 4px solid #af52de; margin-bottom: 12px; }
      .card.theme-f108 .factory-header { background: #f9f0ff; padding: 10px 14px; }

      /* 新增 109 廠手機專屬配色 - 使用玫瑰紅做出與108、105的區隔 */
      .card.theme-f109 { border-left: 4px solid #ff2d55; margin-bottom: 12px; }
      .card.theme-f109 .factory-header { background: #fff0f2; padding: 10px 14px; }
      
      .card.theme-f105 { border-left: 4px solid #5856d6; margin-bottom: 12px; }
      .card.theme-f105 .factory-header { background: #f0f0ff; padding: 10px 14px; }

		.flag-img { 
		    width: 24px; 
		    height: 24px;          
		    margin-left: 8px; 
		    display: inline-block;
            vertical-align: middle; 
		    object-fit: cover;      
		    border-radius: 50%;
		    box-shadow: 0 1px 2px rgba(0,0,0,0.1);
		}
	/*人力區塊*/
	  .card.theme-human { border-left: 4px solid lightseagreen; margin-bottom: 12px; }
	  
	  .human-dynamic-collapse {
	  max-height: 0;
	  overflow: hidden;
	  transition: max-height 0.3s ease-out;
	}
	.human-dynamic-collapse.panel-open {
	  max-height: 1000px; /* 足夠容納表格的高度 */
	  transition: max-height 0.4s ease-in;
	}
	/* 點擊選中廠別時的發亮/高亮底色 */
	.factory-header.active-human-click {
	  background-color: #f2f2f7 !important;
	  border-radius: 6px;
	}
	.human-table { width: 100%; border-collapse: collapse; font-size: 13px; }
	.human-table th { padding: 6px 8px; text-align: center; font-weight: 500;  }
	.human-table td { padding: 10px 8px;  }
	.human-table td.labels { color: #666; font-size:16px; line-height: 23px; }
	.human-table td.num { text-align: center; font-weight: 700; }
	.human-table td.num-taiwan { text-align: center; font-weight: 700; color: #007aff; }
	.human-table td.num-foreign { text-align: center; font-weight: 700; color: #ff9500; }  
	.hunman-tr {
	  border-bottom: 1.5px solid #eee;
	  font-size:16px;
	} 
	  /*border-bottom: 1.5px solid #eee;*/
    </style>

    <div class="section-label" style="padding: 4px 4px 8px 4px;">營運數據總覽(<%= aaTool.getWYearMonth(updateDate)%>)</div>
      
      <div class="card theme-region">
      <div class="factory-header">
        <span class="factory-name" style="font-weight: 800; color: #1c1c1e; flex-grow: 1; display: flex; align-items: center;">
          TW 綜合指標
        </span>
      </div>
      
      <div class="region-grid th">
        <div>項目</div>
        <div class="region-cell-title" style="color: #34c759;">P</div>
        <div class="region-cell-title" style="color: #007aff;">T</div>
        <div class="region-cell-title" style="color: #ff9500;">C&H</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">月目標</div>
        <div style="color: #666; font-size: 13px;"><%= aaTool.format(tw.get("TW_TARGET_PIPEWGT"),"#,##0") %> 噸</div>
        <div style="color: #666; font-size: 13px;"><%= aaTool.format(tw.get("TW_TARGET_TUBEWGT"),"#,##0") %> 噸</div>
        <div style="color: #666; font-size: 13px;"><%= aaTool.format(tw.get("TW_TARGET_SHEETWGT"),"#,##0") %> 噸</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">實際產量</div>
        <div style="font-weight: 700; font-size: 13px;"><%= aaTool.format(tw.get("TW_P_PROD_TON"),"#,##0") %> 噸</div>
        <div style="font-weight: 700; font-size: 13px;"><%= aaTool.format(tw.get("TW_T_PROD_TON"),"#,##0") %> 噸</div>
        <div style="font-weight: 700; font-size: 13px;"><%= aaTool.format(tw.get("TW_C_PROD_TON"),"#,##0") %> 噸</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">達成率</div>
        <div class="green" style="font-weight: 800; font-size: 13px;"><%= aaTool.format(tw.get("TW_P_TARGET_RATE"),"#,##0.0")%>%</div>
        <div class="green" style="font-weight: 800; font-size: 13px;"><%= aaTool.format(tw.get("TW_T_TARGET_RATE"),"#,##0.0")%>%</div>
        <div class="amber" style="font-weight: 800; font-size: 13px;"><%= aaTool.format(tw.get("TW_C_TARGET_RATE"),"#,##0.0")%>%</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">成材率</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tw.get("TW_P_SHARP_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tw.get("TW_T_SHARP_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tw.get("TW_C_SHARP_RATE"),"#,##0.0")%>%</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">良品率</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tw.get("TW_P_YIELD_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tw.get("TW_T_YIELD_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tw.get("TW_C_YIELD_RATE"),"#,##0.0")%>%</div>
      </div>
      <%--<div class="region-grid" style="border-bottom: none;">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb; white-space: nowrap;">稼動率(含無人)</div>
        <div style="font-size: 13px; color: #248a3d; font-weight: 700;"><%= aaTool.format(tw.get("TW_T_MACH_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #248a3d; font-weight: 700;"><%= aaTool.format(tw.get("TW_P_MACH_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #248a3d; font-weight: 700;"><%= aaTool.format(tw.get("TW_C_MACH_RATE"),"#,##0.0")%>%</div>
      </div>--%>
    </div>

    <div class="card theme-region">
      <div class="factory-header">
        <span class="factory-name" style="font-weight: 800; color: #1c1c1e; flex-grow: 1; display: flex; align-items: center;">
          TR 綜合指標  
        </span>
      </div>
      <div class="region-grid th">
        <div>項目</div>
        <div class="region-cell-title" style="color: #5856d6;">P</div>
        <div class="region-cell-title" style="color: #af52de;">T</div>
        <div class="region-cell-title" style="color: #5856d6;">C</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">月目標</div>
        <div style="color: #666; font-size: 13px;"><%= aaTool.format(tr.get("TR_TARGET_PIPEWGT"),"#,##0") %>  噸</div>
        <div style="color: #666; font-size: 13px;"><%= aaTool.format(tr.get("TR_TARGET_TUBEWGT"),"#,##0") %> 噸</div>
        <div style="color: #666; font-size: 13px;"><%= aaTool.format(tr.get("TR_TARGET_SHEETWGT"),"#,##0") %> 噸</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">實際產量</div>
        <div style="font-weight: 700; font-size: 13px;"><%= aaTool.format(tr.get("TR_P_PROD_TON"),"#,##0") %>噸</div>
        <div style="font-weight: 700; font-size: 13px;"><%= aaTool.format(tr.get("TR_T_PROD_TON"),"#,##0") %> 噸</div>
        <div style="font-weight: 700; font-size: 13px;"><%= aaTool.format(tr.get("TR_C_PROD_TON"),"#,##0") %> 噸</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">達成率</div>
        <div class="amber" style="font-weight: 800; font-size: 13px;"><%= aaTool.format(tr.get("TR_P_TARGET_RATE"),"#,##0.0")%>%</div>
        <div class="green" style="font-weight: 800; font-size: 13px;"><%= aaTool.format(tr.get("TR_T_TARGET_RATE"),"#,##0.0")%>%</div>
        <div class="amber" style="font-weight: 800; font-size: 13px;"><%= aaTool.format(tr.get("TR_C_TARGET_RATE"),"#,##0.0")%>%</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">成材率</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tr.get("TR_P_SHARP_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tr.get("TR_T_SHARP_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tr.get("TR_C_SHARP_RATE"),"#,##0.0")%>%</div>
      </div>
      <div class="region-grid">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb;">良品率</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tr.get("TR_P_YIELD_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tr.get("TR_T_YIELD_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #1c1c1e;"><%= aaTool.format(tr.get("TR_C_YIELD_RATE"),"#,##0.0")%>%</div>
      </div>
      <%--<div class="region-grid" style="border-bottom: none;">
        <div style="font-size: 11px; color: #555; font-weight: 600; background: #f9f9fb; white-space: nowrap;">稼動率(含無人)</div>
        <div style="font-size: 13px; color: #248a3d; font-weight: 700;"><%= aaTool.format(tr.get("TR_T_MACH_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #248a3d; font-weight: 700;"><%= aaTool.format(tr.get("TR_P_MACH_RATE"),"#,##0.0")%>%</div>
        <div style="font-size: 13px; color: #248a3d; font-weight: 700;"><%= aaTool.format(tr.get("TR_C_MACH_RATE"),"#,##0.0")%>%</div>
      </div>--%>
    </div>


    <div class="section-label" style="padding: 12px 4px 8px 4px;">各廠生產明細</div>

    <%
       double valXZ = 0.0;
       if(xizhou.get("XIZHOU_T_MACHWITHP_RATE") != null) {
           try { valXZ = Double.parseDouble(xizhou.get("XIZHOU_T_MACHWITHP_RATE").toString().trim()); } catch(Exception e){}
       }
    %>
    <div class="card theme-xizhou">
      <div class="factory-header"><span class="factory-name" style="font-weight: 700;">溪州廠
      
        </span>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea; background: #fafafa;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #007aff; font-weight: 700;">實際產量</div>
          <div class="stat-val" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(xizhou.get("XIZHOU_T_PROD_TON"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">月目標</div>
          <div class="stat-val" style="font-size: 13px; color: #555;"><%= aaTool.format(xizhou.get("XIZHOU_TARGET_TUBEWGT"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #34c759; font-weight: 700;">達成率</div>
          <div class="stat-val green" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(xizhou.get("XIZHOU_T_TARGET_RATE"),"#,##0.0")%>%</div>
        </div>
      </div>
      <div class="card-row-split" style="border-bottom: 1px solid #e5e5ea; background: #fffaf5;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #c0392b; font-weight: 700;">單位成本</div>
          <div class="stat-val red" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(xizhou.get("XIZHOU_UNITCOST"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #e67e22; font-weight: 700;">人工製費</div>
          <div class="stat-val amber" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(xizhou.get("XIZHOU_EXP"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">成材率</div><div class="stat-val"><%= aaTool.format(xizhou.get("XIZHOU_T_SHARP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">良品率</div><div class="stat-val"><%= aaTool.format(xizhou.get("XIZHOU_T_YIELD_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">機台數</div><div class="stat-val"><%= aaTool.format(xizhou.get("XIZHOU_MACHCOUNT"),"#,##0") %></div></div>
      </div>
      <div class="card-row-split card-divider-bg" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">稼動率</div><div class="stat-val blue"><%= aaTool.format(xizhou.get("XIZHOU_T_MACHWITHP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">稼動率（含無人）</div><div class="stat-val green"><%= aaTool.format(xizhou.get("XIZHOU_T_MACH_RATE"),"#,##0.0")%>%</div></div>
      </div>
      <div class="progress-section">
        <div class="progress-header"><span>稼動率</span><span style="color: #007aff"><%= aaTool.format(xizhou.get("XIZHOU_T_MACHWITHP_RATE"),"#,##0.0")%>%</span></div>
        <div class="progress-track">
          <div class="progress-fill" style="width: <%= valXZ %>%; background: #007aff;"></div>
        </div>
      </div>
    </div>

    <%
       double valD2 = 0.0;
        if(dou2.get("DOU2_P_MACHWITHP_RATE") != null) {
           try { valD2 = Double.parseDouble(dou2.get("DOU2_P_MACHWITHP_RATE").toString().trim());
        } catch(Exception e){}
       }
    %>
    <div class="card theme-dou2">
      <div class="factory-header"><span class="factory-name" style="font-weight: 700;">斗二廠
      
      </span>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea; background: #fafafa;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #34c759; font-weight: 700;">實際產量</div>
          <div class="stat-val" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(dou2.get("DOU2_P_PROD_TON"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">月目標</div>
          <div class="stat-val" style="font-size: 13px; color: #555;"><%= aaTool.format(dou2.get("DOU2_TARGET_PIPEWGT"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #34c759; font-weight: 700;">達成率</div>
          <div class="stat-val green" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(dou2.get("DOU2_P_TARGET_RATE"),"#,##0.0")%>%</div>
        </div>
      </div>
      <div class="card-row-split" style="border-bottom: 1px solid #e5e5ea; background: #fffaf5;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #c0392b; font-weight: 700;">單位成本</div>
          <div class="stat-val red" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(dou2.get("DOU2_UNITCOST"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #e67e22; font-weight: 700;">人工製費</div>
          <div class="stat-val amber" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(dou2.get("DOU2_EXP"),"#,##0.0")%>  <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">成材率</div><div class="stat-val"><%= aaTool.format(dou2.get("DOU2_P_SHARP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">良品率</div><div class="stat-val"><%= aaTool.format(dou2.get("DOU2_P_YIELD_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">機台數</div><div class="stat-val"><%= aaTool.format(dou2.get("DOU2_MACHCOUNT"),"#,##0") %></div></div>
      </div>
      <div class="card-row-split card-divider-bg" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">稼動率</div><div class="stat-val green"><%= aaTool.format(dou2.get("DOU2_P_MACHWITHP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">稼動率（含無人）</div><div class="stat-val green"><%= aaTool.format(dou2.get("DOU2_P_MACH_RATE"),"#,##0.0")%>%</div></div>
      </div>
      <div class="progress-section">
        <div class="progress-header"><span>稼動率</span><span style="color: #34c759"><%= aaTool.format(dou2.get("DOU2_P_MACHWITHP_RATE"),"#,##0.0")%>%</span></div>
        <div class="progress-track">
          <div class="progress-fill" style="width: <%= valD2 %>%; background: #34c759;"></div>
        </div>
      </div>
    </div>

    <%
       double valD1 = 0.0;
        if(tw.get("TW_C_MACH_RATE") != null) {
           try { valD1 = Double.parseDouble(tw.get("TW_C_MACH_RATE").toString().trim());
        } catch(Exception e){}
       }
    %>
    <div class="card theme-dou1">
      <div class="factory-header"><span class="factory-name" style="font-weight: 700;">斗一廠
        
      </span></div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea; background: #fafafa;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #ff9500; font-weight: 700;">實際產量</div>
          <div class="stat-val" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(tw.get("TW_C_PROD_TON"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">月目標</div>
          <div class="stat-val" style="font-size: 13px; color: #555;"><%= aaTool.format(tw.get("TW_TARGET_SHEETWGT"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #ff9500; font-weight: 700;">達成率</div>
          <div class="stat-val amber" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(tw.get("TW_C_TARGET_RATE"),"#,##0.0")%>%</div>
        </div>
      </div>
      <div class="card-row-split" style="border-bottom: 1px solid #e5e5ea; background: #fffaf5;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #c0392b; font-weight: 700;">單位成本</div>
          <div class="stat-val red" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(dou1.get("DOU1_UNITCOST"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #e67e22; font-weight: 700;">人工製費</div>
          <div class="stat-val amber" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(dou1.get("DOU1_EXP"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">成材率</div><div class="stat-val"><%= aaTool.format(tw.get("TW_C_SHARP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">良品率</div><div class="stat-val"><%= aaTool.format(tw.get("TW_C_YIELD_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">機台數</div><div class="stat-val"><%= aaTool.format(dou1.get("DOU1_MACHCOUNT"),"#,##0") %></div></div>
      </div>
      <div class="card-row-split card-divider-bg" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">稼動率</div><div class="stat-val amber"><%= aaTool.format(tw.get("TW_C_MACH_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">稼動率（含無人）</div><div class="stat-val green"><%= aaTool.format(tw.get("TW_C_MACH_RATE"),"#,##0.0")%>%</div></div>
      </div>
      <div class="progress-section">
        <div class="progress-header"><span>稼動率</span><span style="color: #ff9500"><%= aaTool.format(tw.get("TW_C_MACH_RATE"),"#,##0.0")%>%</span></div>
        <div class="progress-track">
          <div class="progress-fill" style="width: <%= valD1 %>%; background: #ff9500;"></div>
        </div>
      </div>
    </div>

    <%
       double val108 = 0.0;
        if(f108.get("F108_T_MACHWITHP_RATE") != null) {
           try { val108 = Double.parseDouble(f108.get("F108_T_MACHWITHP_RATE").toString().trim());
        } catch(Exception e){}
       }
    %>
    <div class="card theme-f108">
      <div class="factory-header"><span class="factory-name" style="font-weight: 700;">108 廠
       
      </span></div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea; background: #fafafa;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #af52de; font-weight: 700;">實際產量</div>
          <div class="stat-val" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(f108.get("F108_T_PROD_TON"),"#,##0") %>噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">月目標</div>
          <div class="stat-val" style="font-size: 13px; color: #555;"><%= aaTool.format(f108.get("F108_TARGET_TUBEWGT"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #34c759; font-weight: 700;">達成率</div>
          <div class="stat-val green" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(f108.get("F108_T_TARGET_RATE"),"#,##0.0")%>%</div>
        </div>
      </div>
      <div class="card-row-split" style="border-bottom: 1px solid #e5e5ea; background: #fffaf5;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #c0392b; font-weight: 700;">單位成本</div>
          <div class="stat-val red" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(f108TR.get("F108_UNITCOST"),"#,##0.0")%><span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #e67e22; font-weight: 700;">人工製費</div>
          <div class="stat-val amber" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(f108TR.get("F108_EXP"),"#,##0.0")%><span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">成材率</div><div class="stat-val"><%= aaTool.format(f108.get("F108_T_SHARP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">良品率</div><div class="stat-val"><%= aaTool.format(f108.get("F108_T_YIELD_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">機台數</div><div class="stat-val"><%= aaTool.format(f108.get("F108_MACHCOUNT"),"#,##0") %></div></div>
      </div>
      <div class="card-row-split card-divider-bg" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">稼動率</div><div class="stat-val purple"><%= aaTool.format(f108.get("F108_T_MACHWITHP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">稼動率（含無人）</div><div class="stat-val green"><%= aaTool.format(f108.get("F108_T_MACH_RATE"),"#,##0.0")%>%</div></div>
      </div>
      <div class="progress-section">
        <div class="progress-header"><span>稼動率</span><span style="color: #af52de"><%= aaTool.format(f108.get("F108_T_MACHWITHP_RATE"),"#,##0.0")%>%</span></div>
        <div class="progress-track">
          <div class="progress-fill" style="width: <%= val108 %>%; background: #af52de;"></div>
        </div>
      </div>
    </div>



    <%
       double val105 = 0.0;
	    if(f105.get("F105_P_MACHWITHP_RATE") != null) {
	        try { val105 = Double.parseDouble(f105.get("F105_P_MACHWITHP_RATE").toString().trim());        
	    	} catch(Exception e){}
	    }
       
    
       
    %>
    <div class="card theme-f105">
      <div class="factory-header"><span class="factory-name" style="font-weight: 700;">105 廠
        
      </span></div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea; background: #fafafa;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #5856d6; font-weight: 700;">實際產量</div>
          <div class="stat-val" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(f105.get("F105_P_PROD_TON"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">月目標</div>
          <div class="stat-val" style="font-size: 13px; color: #555;"><%= aaTool.format(f105.get("F105_TARGET_PIPEWGT"),"#,##0") %> 噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #ff9500; font-weight: 700;">達成率</div>
          <div class="stat-val amber" style="font-size: 13px; font-weight: 800;"><%= aaTool.format(f105.get("F105_P_TARGET_RATE"),"#,##0.0")%>%</div>
        </div>
      </div>
      <div class="card-row-split" style="border-bottom: 1px solid #e5e5ea; background: #fffaf5;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #c0392b; font-weight: 700;">單位成本</div>
          <div class="stat-val red" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(f105TR.get("F105_UNITCOST"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #e67e22; font-weight: 700;">人工製費</div>
          <div class="stat-val amber" style="font-size: 14px; font-weight: 800;"><%= aaTool.format(f105TR.get("F105_EXP"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span></div>
        </div>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">成材率</div><div class="stat-val"><%= aaTool.format(f105.get("F105_P_SHARP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">良品率</div><div class="stat-val"><%= aaTool.format(f105.get("F105_P_YIELD_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">機台數</div><div class="stat-val"><%= aaTool.format(f105.get("F105_MACHCOUNT"),"#,##0") %></div></div>
      </div>
      <div class="card-row-split card-divider-bg" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell"><div class="stat-label">稼動率</div><div class="stat-val indigo"><%= aaTool.format(f105.get("F105_P_MACHWITHP_RATE"),"#,##0.0")%>%</div></div>
        <div class="stat-cell"><div class="stat-label">稼動率（含無人）</div><div class="stat-val green"><%= aaTool.format(f105.get("F105_P_MACH_RATE"),"#,##0.0")%>%</div></div>
      </div>
      <div class="progress-section">
        <div class="progress-header"><span>稼動率</span><span style="color: #5856d6"><%= aaTool.format(f105.get("F105_P_MACHWITHP_RATE"),"#,##0.0")%>%</span></div>
        <div class="progress-track">
          <div class="progress-fill" style="width: <%= val105 %>%; background: #5856d6;"></div>
        </div>
      </div>
    </div>
    
    
    
        <%-- 這裡全新插入了 109 廠的卡片 --%>
    <%
    double val109 = 0.0;
    if(f109.get("TR_C_MACH_RATE") != null) {
        try { val109 = Double.parseDouble(f109.get("TR_C_MACH_RATE").toString().trim());        
    	} catch(Exception e){}
    }
    %>
    <div class="card theme-f109">
      <div class="factory-header"><span class="factory-name" style="font-weight: 700;">109 廠
       
      </span></div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea; background: #fafafa;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #ff2d55; font-weight: 700;">實際產量</div>
          <div class="stat-val" style="font-size: 13px; font-weight: 800;">
           <%= aaTool.format(tr.get("TR_C_PROD_TON"),"#,##0") %>
          </div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">月目標</div>
          <div class="stat-val" style="font-size: 13px; color: #555;">
           <%= aaTool.format(tr.get("TR_TARGET_SHEETWGT"),"#,##0") %>
          </div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #34c759; font-weight: 700;">達成率</div>
          <div class="stat-val green" style="font-size: 13px; font-weight: 800;">
            <%= aaTool.format(tr.get("TR_C_TARGET_RATE"),"#,##0.0")%>
          </div>
        </div>
      </div>
      <div class="card-row-split" style="border-bottom: 1px solid #e5e5ea; background: #fffaf5;">
        <div class="stat-cell">
          <div class="stat-label" style="color: #c0392b; font-weight: 700;">單位成本</div>
          <div class="stat-val red" style="font-size: 14px; font-weight: 800;">
            <%= aaTool.format(f109TR.get("F109_UNITCOST"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span>
          </div>
        </div>
        <div class="stat-cell">
          <div class="stat-label" style="color: #e67e22; font-weight: 700;">人工製費</div>
          <div class="stat-val amber" style="font-size: 14px; font-weight: 800;">
            <%= aaTool.format(f109TR.get("F109_EXP"),"#,##0.0")%> <span style="font-size: 11px; color: #666; font-weight: 500;">元/KG</span>
          </div>
        </div>
      </div>
      <div class="card-row-3" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell">
          <div class="stat-label">成材率</div>
          <div class="stat-val">
            <%= aaTool.format(tr.get("TR_C_SHARP_RATE"),"#,##0.0")%>
          </div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">良品率</div>
          <div class="stat-val">
            <%= aaTool.format(tr.get("TR_C_YIELD_RATE"),"#,##0.0")%>
          </div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">機台數</div>
          <div class="stat-val">
            <%= aaTool.format(f109.get("F109_MACHCOUNT"),"#,##0") %>
          </div>
        </div>
      </div>
      <div class="card-row-split card-divider-bg" style="border-bottom: 1px solid #e5e5ea;">
        <div class="stat-cell">
          <div class="stat-label">稼動率</div>
          <div class="stat-val" style="color: #ff2d55; font-weight: 700;">
            <%= aaTool.format(tr.get("TR_C_MACH_RATE"),"#,##0.0")%>
          </div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">稼動率（含無人）</div>
          <div class="stat-val green">
           <%= aaTool.format(tr.get("TR_C_MACH_RATE"),"#,##0.0")%>
          </div>
        </div>
      </div>
      <div class="progress-section">
        <div class="progress-header"><span>稼動率</span><span style="color: #ff2d55"><%= aaTool.format(tr.get("TR_C_MACH_RATE"),"#,##0.0")%></span></div>
        <div class="progress-track">
          <div class="progress-fill" style="width: <%= aaTool.format(tr.get("TR_C_MACH_RATE"),"#,##0.0") %>%; background: #ff2d55;"></div>
         
        </div>
      </div>
    </div>
    
    <div class="section-label" style="padding: 12px 4px 8px 4px;">台灣各廠人力現況</div>
    
    <div class="card theme-human">
    
      <div class="factory-header all-hunman" onclick="showHumanData(this)" style="cursor: pointer;"
           data-name="總公司"
           data-total="<%= allhuman.get("全廠總人數") %>"
 		   data-mtaiwan="<%= allhuman.get("製造台籍人數") %>"
		   data-mforeign="<%= allhuman.get("製造外籍人數") %>"
		   data-prodtaiwan="<%= allhuman.get("生產台籍人數") %>"
		   data-prodforeign="<%= allhuman.get("生產外籍人數") %>"
		   data-sataiwan="<%= allhuman.get("安衛台籍人數") %>"
		   data-saforeign="<%= allhuman.get("安衛外籍人數") %>"
		   data-oftaiwan="<%= allhuman.get("行政台籍人數") %>"
		   data-offoreign="<%= allhuman.get("行政外籍人數") %>"
		   data-wataiwan="<%= allhuman.get("保修台籍人數") %>"
		   data-waforeign="<%= allhuman.get("保修外籍人數") %>"
		   data-qtaiwan="<%= allhuman.get("品保台籍人數") %>"
		   data-qforeign="<%= allhuman.get("品保外籍人數") %>"
		   data-rdtaiwan="<%= allhuman.get("研開台籍人數") %>"
		   data-rdforeign="<%= allhuman.get("研開外籍人數") %>"
		   data-ptaiwan="<%= allhuman.get("加工台籍人數") %>"
		   data-pforeign="<%= allhuman.get("加工外籍人數") %>"
		   data-mbtaiwan="<%= allhuman.get("廠務台籍人數") %>"
		   data-mbforeign="<%= allhuman.get("廠務外籍人數") %>"
		   data-etaiwan="<%= allhuman.get("生管成品台籍人數") %>"
		   data-eforeign="<%= allhuman.get("生管成品外籍人數") %>"
		   data-eetaiwan="<%= allhuman.get("生管台籍人數") %>"
		   data-eeforeign="<%= allhuman.get("生管外籍人數") %>"
		   data-m41taiwan="<%= allhuman.get("設備台籍人數") %>"
		   data-m41foreign="<%= allhuman.get("設備外籍人數") %>"
		   data-ctaiwan="<%= allhuman.get("裁剪台籍人數") %>"
		   data-cforeign="<%= allhuman.get("裁剪外籍人數") %>"
		  
        <span class="factory-name" style="font-weight: 800; color: #1c1c1e; flex-grow: 1; display: flex; align-items: center; font-size:16px !important;">
          總公司
        </span>
      </div>

      <div class="factory-header xz-hunman" onclick="showHumanData(this)" style="cursor: pointer;"
           data-name="溪州廠"
           data-total="<%= xzhuman.get("全廠總人數") %>"
 		   data-mtaiwan="<%= xzhuman.get("製造台籍人數") %>"
		   data-mforeign="<%= xzhuman.get("製造外籍人數") %>"
		   data-ptaiwan="<%= xzhuman.get("加工台籍人數") %>"
		   data-pforeign="<%= xzhuman.get("加工外籍人數") %>"
		   data-mbtaiwan="<%= xzhuman.get("廠務台籍人數") %>"
		   data-mbforeign="<%= xzhuman.get("廠務外籍人數") %>"
		   data-etaiwan="<%= xzhuman.get("生管成品台籍人數") %>"
		   data-eforeign="<%= xzhuman.get("生管成品外籍人數") %>"
		   data-m41taiwan="<%= xzhuman.get("設備台籍人數") %>"
		   data-m41foreign="<%= xzhuman.get("設備外籍人數") %>"
		   data-elsetaiwan="<%= xzhuman.get("其他台籍人數") %>"
		   data-elseforeign="<%= xzhuman.get("其他外籍人數") %>"
        <span class="factory-name" style="font-weight: 800; color: #1c1c1e; flex-grow: 1; display: flex; align-items: center; font-size:16px !important;">
          溪州廠
        </span>
      </div>

      <div class="factory-header dl2-human" onclick="showHumanData(this)" style="cursor: pointer;"
           data-name="斗六二廠"
           data-total="<%= dl2human.get("全廠總人數")  %>"
 		   data-mtaiwan="<%= dl2human.get("製造台籍人數") %>"
		   data-mforeign="<%= dl2human.get("製造外籍人數") %>"
		   data-ptaiwan="<%= dl2human.get("加工台籍人數") %>"
		   data-pforeign="<%= dl2human.get("加工外籍人數") %>"
		   data-mbtaiwan="<%= dl2human.get("廠務台籍人數") %>"
		   data-mbforeign="<%= dl2human.get("廠務外籍人數") %>"
		   data-etaiwan="<%= dl2human.get("生管成品台籍人數") %>"
		   data-eforeign="<%= dl2human.get("生管成品外籍人數") %>"
		   data-m41taiwan="<%= dl2human.get("設備台籍人數") %>"
		   data-m41foreign="<%= dl2human.get("設備外籍人數") %>"
		   data-elsetaiwan="<%= dl2human.get("其他台籍人數") %>"
		   data-elseforeign="<%= dl2human.get("其他外籍人數") %>"
        <span class="factory-name" style="font-weight: 800; color: #1c1c1e; flex-grow: 1; display: flex; align-items: center; font-size:16px !important;">
          斗二廠
        </span>
      </div>

      <div class="factory-header dl1-human" onclick="showHumanData(this)" style="cursor: pointer;"
           data-name="斗六一廠"
           data-total="<%= dl1human.get("全廠總人數")  %>"
 		   data-mtaiwan="<%= dl1human.get("製造台籍人數") %>"
		   data-mforeign="<%= dl1human.get("製造外籍人數") %>"
		   data-ptaiwan="<%= dl1human.get("加工台籍人數") %>"
		   data-pforeign="<%= dl1human.get("加工外籍人數") %>"
		   data-mbtaiwan="<%= dl1human.get("廠務台籍人數") %>"
		   data-mbforeign="<%= dl1human.get("廠務外籍人數") %>"
		   data-etaiwan="<%= dl1human.get("生管成品台籍人數") %>"
		   data-eforeign="<%= dl1human.get("生管成品外籍人數") %>"
		   data-m41taiwan="<%= dl1human.get("設備台籍人數") %>"
		   data-m41foreign="<%= dl1human.get("設備外籍人數") %>"
		   data-elsetaiwan="<%= dl1human.get("其他台籍人數") %>"
		   data-elseforeign="<%= dl1human.get("其他外籍人數") %>"
        <span class="factory-name" style="font-weight: 800; color: #1c1c1e; flex-grow: 1; display: flex; align-items: center; font-size:16px !important;">
          斗一廠
        </span>
      </div>

		<div id="shared-human-panel" class="human-dynamic-collapse">
		  <div style="background: #fafafa; border-radius: 8px; margin-top: 12px; border: 1px solid #e5e5ea; padding: 15px;">
		
		    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
		      <h4 id="human-panel-title" style="margin: 0; color: #1c1c1e; font-weight: 800; font-size: 22px;"></h4>
		      <div style="font-size: 22px; color: #666;"><strong id="txt-total" style="color:#1c1c1e;">0</strong>人 </div>
		    </div>
		
		    <table class="human-table">
		      <thead>
		        <tr class="hunman-tr">
		          <th style="text-align: left;"></th>
		          <th>台籍</th>
		          <th>外籍</th>
		        </tr>
		      </thead>
		      <tbody>
		    
		      </tbody>
		    </table>
		
		  </div>
		</div>
	</div>
    
 </div>