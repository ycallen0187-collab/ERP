<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.ds.dsjccom"%>
<%@ page import="com.icsc.bq.core.bqjc0424" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ042"; %>

<%
  
    // 從主控檔傳下來的資料取出
    aajcYCATool aaTool = new aajcYCATool();
    String updateDate = request.getParameter("updateDate");
  
	dejc300 _de300 = new dejc300();
	dsjccom _dsCom = _de300.run(_AppId, this, request, response);
	if(_dsCom==null){ return ;
	}

    bqjc0424 bq0424 = new bqjc0424(_dsCom);
    Map dashboardData = bq0424.getDashboardDataDL2(_dsCom, request);
    
    Map showData = (Map) (dashboardData != null ? dashboardData.get("DL2Data") : new HashMap());
    if (showData == null) showData = new HashMap();
   
%>

<div id="ajax-target-content">
<%
//out.println("<pre style='background:#2d2d2d; color:#7ec699; padding:15px; border-radius:5px;'>");
//out.println("====== [DEBUG XZ 繞過 500 成功拿到連線] ======");
//out.println("接收到的 updateDate -> " + updateDate);
//out.println("撈出來的待加工 -> " + showData.get("待加工"));

//out.println("==============================================");
//out.println("</pre>");
%>
  <style>
  #ajax-target-content{
  -webkit-text-size-adjust: 100% !important;
    text-size-adjust: 100% !important;
  }
    /* 斗二廠專屬設計系統與色彩變數 (Scoped to Xizhou) */
    .dl2-wrap {
      --dl2-ink: #172033;
      --dl2-muted: #6a778b;
      --dl2-line: #dbe2eb;
      --dl2-card: #ffffff;
      --dl2-track: #edf1f5;
      --dl2-green: #45a64a;
      --dl2-green-soft: #e6f5e8;
      --dl2-red: #e33151;
      --dl2-red-soft: #ffe2e8;
      --dl2-amber: #f0bd14;
      --dl2-amber-soft: #fff3c9;
      --dl2-blue: #5a91e6;
      --dl2-blue-soft: #e7effd;
      --dl2-orange: #ff6b1a;
      --dl2-orange-soft: #ffe8d9;
      --dl2-purple: #a65bd4;
      --dl2-purple-soft: #f1e4fa;
      --dl2-teal: #18a999;
      
      font-family: "Segoe UI", "Noto Sans TC", "Microsoft JhengHei", Arial, sans-serif;
      color: var(--dl2-ink);
      padding: 4px 0 24px 0;
    }

    .dl2-wrap * { box-sizing: border-box; }
    
    /* 基礎橫列佈局 */
    .dl2-meta-row, .dl2-kpi-topline, .dl2-section-title, .dl2-bar-head, .dl2-reason-row, .dl2-people-row, .dl2-dept-title {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }

    .dl2-hero { padding: 8px 2px 10px; }
    .dl2-eyebrow { margin: 0; color: var(--dl2-muted); font-size: 12px; font-weight: 750; }
    
    /* 狀態標籤 */
    .dl2-live-pill, .dl2-risk-pill, .dl2-delta,.dl2-delta-lower{
      display: inline-flex;
      align-items: center;
      min-height: 24px;
      padding: 0 8px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 850;
      white-space: nowrap;
    }
    .dl2-live-pill { color: #176a38; background: var(--dl2-green-soft); }
    .dl2-live-pill::before { content: ""; width: 7px; height: 7px; margin-right: 5px; border-radius: 50%; background: var(--dl2-green); }

    .dl2-lead { margin: 6px 0 0 0; color: var(--dl2-muted); font-size: 13px; line-height: 1.55; font-weight: 650; }
    .dl2-summary-strip { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin: 12px 0; }

    /* 卡片設計 */
    .dl2-hero-card, .dl2-insight, .dl2-dept-card, .dl2-kpi-card, .dl2-chart-card, .dl2-reason-card, .dl2-people-card {
      border: 1px solid var(--dl2-line);
      border-radius: 12px;
      background: var(--dl2-card);
      box-shadow: 0 4px 12px rgba(35, 48, 70, 0.05);
      padding: 12px;
    }

    .dl2-hero-card.wide {
      grid-column: 1 / -1;
      color: #fff;
      border-color: #243756;
      background: #243653;
    }
    .dl2-label { margin: 0; color: var(--dl2-muted); font-size: 12px; font-weight: 750; }
    .dl2-hero-card.wide .dl2-label, .dl2-hero-card.wide .dl2-sub { color: rgba(255, 255, 255, 0.76); }
    
    .dl2-value { margin-top: 8px; color: var(--dl2-ink); font-size: 26px; line-height: 1; font-weight: 850; }
    .dl2-hero-card.wide .dl2-value { color: #fff; font-size: 30px; }
    .dl2-sub { margin: 8px 0 0; color: var(--dl2-muted); font-size: 12px; line-height: 1.35; font-weight: 700; }

    /* 風險與色塊標籤 */
    .dl2-risk-pill { color: #a90f2c; background: var(--dl2-red-soft); }
    .dl2-risk-pill.orange { color: #a54200; background: var(--dl2-orange-soft); }
    .dl2-risk-pill.blue { color: #2450b8; background: var(--dl2-blue-soft); }

    /* 錨點導航列 */
    .dl2-local-nav {
      position: sticky;
      top: 0;
      z-index: 5;
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 4px;
      padding: 8px 0;
      background: rgba(242, 242, 247, 0.92);
      backdrop-filter: blur(12px);
      margin-bottom: 12px;
    }
    .dl2-local-nav a {
      display: grid;
      place-items: center;
      height: 32px;
      border: 1px solid var(--dl2-line);
      border-radius: 8px;
      color: #334155;
      background: #fff;
      text-decoration: none;
      font-size: 11px;
      font-weight: 850;
    }

    /* 區塊標題 */
    .dl2-section { margin-top: 16px; scroll-margin-top: 48px; }
    .dl2-section-title { margin-bottom: 8px; }
    .dl2-section-title h2 { margin: 0; font-size: 17px; line-height: 1.2; font-weight: 850; }
    .dl2-section-title small { color: var(--dl2-muted); font-size: 12px; font-weight: 750; }

    /* 重點洞察 (四個重點) */
    .dl2-insights, .dl2-dept-grid, .dl2-kpi-grid, .dl2-bar-list, .dl2-reason-list, .dl2-people-grid { display: grid; gap: 8px; }
    .dl2-insight { display: grid; grid-template-columns: 5px 1fr; gap: 10px; padding: 11px 12px 11px 0; overflow: hidden; }
    .dl2-insight::before { content: ""; width: 5px; height: 100%; border-radius: 0 3px 3px 0; background: var(--dl2-orange); }
    .dl2-insight.red::before { background: var(--dl2-red); }
    .dl2-insight.blue::before { background: var(--dl2-blue); }
    .dl2-insight.green::before { background: var(--dl2-green); }
    .dl2-insight b { display: block; margin-bottom: 3px; font-size: 14px; line-height: 1.25; }
    .dl2-insight span { display: block; color: var(--dl2-muted); font-size: 12px; line-height: 1.45; font-weight: 650; }

    /* 課別快覽 */
    .dl2-dept-grid { grid-template-columns: 1fr; }
    .dl2-dept-title b { font-size: 15px; font-weight: 850; }
    .dl2-dept-title span { color: var(--dl2-muted); font-size: 12px; font-weight: 750; }
    
    .dl2-metric-row { display: flex; justify-content: space-between; align-items: baseline; min-height: 34px; padding: 8px 0; border-top: 1px solid #edf1f5; }
    .dl2-metric-row:first-of-type { border-top: 0; }
    .dl2-metric-row span { color: var(--dl2-muted); font-size: 12px; font-weight: 750; }
    .dl2-metric-row strong { color: var(--c, var(--dl2-ink)); font-size: 17px; font-weight: 850; }

    /* 進度條與 KPI */
    .dl2-kpi-title { font-size: 14px; font-weight: 850; }
    .dl2-kpi-value { color: var(--c, var(--dl2-ink)); font-size: 22px; font-weight: 850; }
    .dl2-track { position: relative; height: 10px; overflow: hidden; border-radius: 999px; background: var(--dl2-track); margin: 6px 0; }
    .dl2-fill { width: var(--w); min-width: 3px; height: 100%; border-radius: inherit; background: var(--c); }
    .dl2-kpi-meta, .dl2-bar-meta { display: flex; justify-content: space-between; gap: 8px; color: var(--dl2-muted); font-size: 11px; font-weight: 700; }
    
    .dl2-delta { color: #a90f2c; background: var(--dl2-red-soft); }
    .dl2-delta-lower { color: #176a38; background: var(--dl2-green-soft); }
    .dl2-delta.good { color: #176a38; background: var(--dl2-green-soft); }
    .dl2-delta.warn { color: #8a6200; background: var(--dl2-amber-soft); }

    /* 長條圖型態排版 */
    .dl2-split { display: grid; grid-template-columns: 50px 1fr 42px; gap: 16px; align-items: center; margin-top: 6px; color: var(--dl2-muted); font-size: 12px; font-weight: 750; }
    .dl2-split .dl2-track { height: 8px; margin: 0; }
    .dl2-split b { text-align: right; color: var(--dl2-ink); }

    /* 圓餅圖/甜甜圈面板 */
    .dl2-donut-panel { display: grid; grid-template-columns: 100px 1fr; gap: 12px; align-items: center; margin-top: 10px; }
    .dl2-donut { position: relative; width: 100px; aspect-ratio: 1; border-radius: 50%; background: conic-gradient(var(--segments)); }
    .dl2-donut::after { content: ""; position: absolute; inset: 24px; border-radius: 50%; background: var(--dl2-card); }
    .dl2-donut-label { position: absolute; z-index: 2; inset: 0; display: grid; place-items: center; text-align: center; font-size: 11px; font-weight: 850; }
    .dl2-donut-label strong { display: block; font-size: 16px; line-height: 1; }

    /* 停機細項列表 */
    .dl2-reason-row { min-height: 28px; padding: 4px 0; border-bottom: 1px solid #edf1f5; font-size: 12px; font-weight: 800; }
    .dl2-reason-row:last-child { border-bottom: 0; }
    .dl2-reason-name { display: flex; align-items: center; gap: 6px; min-width: 0; }
    .dl2-reason-name i { flex: 0 0 auto; width: 8px; height: 8px; border-radius: 3px; background: var(--c); }
    .dl2-reason-name span { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .dl2-reason-num { text-align: right; white-space: nowrap; color: var(--dl2-muted); }

    /* 人力板塊 */
    .dl2-people-grid { 
    	grid-template-columns: 1fr 1fr;
    	margin-top:10px; 
    }
    .dl2-people-card strong { display: block; margin-top: 4px; color: var(--dl2-purple); font-size: 30px; font-weight: 850; }
    .dl2-people-row { padding: 10px 0; border-top: 1px solid #edf1f5; color: var(--dl2-muted); font-size: 12px; font-weight: 750; }
    .dl2-people-row b { color: var(--dl2-ink); font-size: 15px; }
    
    /*重拋率展開*/
	.dl2-kpi-card .dl2-expand-content {
    max-height: 0;
    opacity: 0;
    overflow: hidden;
    border-top: 1px dashed transparent; 
    padding-top: 0;
    transition: max-height 0.28s ease-out, opacity 0.2s ease, border-color 0.2s ease, padding 0.2s ease;
	}
	.dl2-kpi-card.open .dl2-expand-content {
	    max-height: 1000px;         
	    opacity: 1;
	    border-top-color: #d1d1d6;  
	    padding-top: 12px;  
	    margin-top: 18px;      
	}
	.dl2-kpi-card.open .toggle-icon {
    transform: rotate(180deg);
	}
	
  </style>
  <div class="dl2-wrap">
    <header class="dl2-hero">
      <div class="dl2-meta-row">
        <p class="dl2-eyebrow">斗二廠∣製造課 + 加工課</p>
        <span class="dl2-live-pill">本月摘要</span>
      </div>
      <p class="dl2-lead">集中檢視瓶頸與課別生產細項。</p>
    </header>

    <nav class="dl2-local-nav">
      <a href="javascript:document.getElementById('dl2-summary').scrollIntoView({behavior:'smooth'});">概覽</a>
      <a href="javascript:document.getElementById('dl2-make').scrollIntoView({behavior:'smooth'});">製造</a>
      <a href="javascript:document.getElementById('dl2-process').scrollIntoView({behavior:'smooth'});">加工</a>
      <a href="javascript:document.getElementById('dl2-downtime').scrollIntoView({behavior:'smooth'});">停機</a>
      <a href="javascript:document.getElementById('dl2-people').scrollIntoView({behavior:'smooth'});">人力</a>
    </nav>

    <div class="dl2-summary-strip" id="dl2-summary">
      <article class="dl2-hero-card wide" style="display:none" >
        <p class="dl2-label">共同最大停機原因</p>
        <div class="dl2-kpi-topline">
          <div class="dl2-value">無人操作</div>
          <span class="dl2-risk-pill orange">1,376 小時</span>
        </div>
        <p class="dl2-sub">製造 691 小時、加工 685 小時，兩課別皆為第一大設備損失。</p>
      </article>

      <article class="dl2-hero-card">
       <p class="dl2-label">製造課產量</p>
        <div class="dl2-value"><%= showData.get("當月產量") %> t</div>
        <p class="dl2-sub">成材率 <%= showData.get("當月成材率") %>%</p>
        <p class="dl2-sub">良品率 <%= showData.get("良品率") %>%</p>
      </article>

      <article class="dl2-hero-card">
        <p class="dl2-label">加工課產量</p>
        <div class="dl2-value"> <%= showData.get("酸洗總量") %> t</div>
        <p class="dl2-sub">自動酸洗 <%= showData.get("自動酸洗") %> t</p>
        <p class="dl2-sub">線上酸洗 <%= showData.get("線上酸洗") %> t</p>
      </article>
    
    </div>

    <section class="dl2-section" style="display:none" >
      <div class="dl2-section-title">
        <h2>關鍵洞察</h2>
        <small>4 個重點</small>
      </div>
      <div class="dl2-insights">
        <div class="dl2-insight red">
          <div>
            <b>無人操作是最大設備損失</b>
            <span>製造 691 小時、加工 685 小時，皆高於機故與換模。</span>
          </div>
        </div>
        <div class="dl2-insight">
          <div>
            <b>製造廢重集中在 BF72、BF59</b>
            <span>前兩台廢重 13,331，占前 10 名約 47.5%，優先改善。</span>
          </div>
        </div>
        <div class="dl2-insight blue">
          <div>
            <b>加工重拋率偏高</b>
            <span>重拋率 33.9%，同時待手工矯直 2,154 支，存在產線瓶頸。</span>
          </div>
        </div>
        <div class="dl2-insight green">
          <div>
            <b>兩課移動率同為 76.78%</b>
            <span>可用同一個節奏指標追進度，改善重點在停機與返工。</span>
          </div>
        </div>
      </div>
    </section>

    <section class="dl2-section">
      <div class="dl2-section-title">
        <h2>課別快覽</h2>
        <small>當月 KPI</small>
      </div>
      <div class="dl2-dept-grid">
        <article class="dl2-dept-card" style="margin-bottom:8px;">
          <div class="dl2-dept-title">
            <b>製造課</b> <span>產量與品質</span>
          </div>
         <div class="dl2-metric-row"><span>目標產量</span><strong style="color:var(--dl2-purple)"><%= showData.get("目標產量") %>MT</strong></div>   
         <div class="dl2-metric-row"><span>實際產量</span><strong style="color:var(--dl2-purple)"><%= showData.get("當月產量") %> MT</strong></div>
         <div class="dl2-metric-row"><span>產量完成率</span><strong style="color:var(--dl2-purple)">
          <%= 
        		showData.get("目標產量") != null && showData.get("當月產量") != null && ((java.math.BigDecimal)showData.get("目標產量")).compareTo(java.math.BigDecimal.ZERO) > 0 ? 
        		((java.math.BigDecimal)showData.get("當月產量")).divide((java.math.BigDecimal)showData.get("目標產量"), 4, java.math.RoundingMode.HALF_UP).multiply(new java.math.BigDecimal("100")).setScale(1, java.math.RoundingMode.HALF_UP) + "%" : "0.0%"
		  %>
         </strong></div>
        </article>

        <article class="dl2-dept-card">
          <div class="dl2-dept-title">
            <b>加工課</b> <span>加工與返工</span>
          </div>
         
         <div class="dl2-metric-row"><span>目標酸洗總量</span><strong style="color:var(--dl2-red)"><%= showData.get("目標酸洗總量") %>MT</strong></div>
         <div class="dl2-metric-row"><span>實際酸洗總量</span><strong style="color:var(--dl2-red)"><%= showData.get("酸洗總量") %> MT</strong></div>
         <div class="dl2-metric-row"><span>產量完成率</span><strong style="color:var(--dl2-red)">
         <%= 
        		showData.get("目標酸洗總量") != null && showData.get("酸洗總量") != null && ((java.math.BigDecimal)showData.get("目標酸洗總量")).compareTo(java.math.BigDecimal.ZERO) > 0 ?
        		((java.math.BigDecimal)showData.get("酸洗總量")).divide((java.math.BigDecimal)showData.get("目標酸洗總量"), 4, java.math.RoundingMode.HALF_UP).multiply(new java.math.BigDecimal("100")).setScale(1, java.math.RoundingMode.HALF_UP) + "%" : "0.0%"
		  %>
        </strong></div>
         
        </article>
      </div>
    </section>

    <section class="dl2-section" id="dl2-make">
      <div class="dl2-section-title">
        <h2>製造課細項</h2>
        <small>產量 / 廢重 / 機故</small>
      </div>
     <div class="dl2-kpi-grid">
  
        <article class="dl2-kpi-card">
          <div class="dl2-kpi-topline"><span class="dl2-kpi-title">光退占產量</span><span class="dl2-kpi-value" style="color:var(--dl2-red)"><%= showData.get("光退占產量") %>%</span></div>
          <div class="dl2-track"><div class="dl2-fill" style="--w:<%= showData.get("光退占產量") %>%;--c:var(--dl2-red)"></div></div>
          <div class="dl2-kpi-meta"><span><%= showData.get("光退產量") %> t / <%= showData.get("當月產量") %> t</span><span class="dl2-delta good">成材率 <%= showData.get("當月成材率") %>%</span></div>
        </article>
      </div>
		<%
		//日產量高峰
		java.util.List rList = (java.util.List) showData.get("日產量");
	    java.util.Map firstRow = (rList != null && !rList.isEmpty()) ? (java.util.Map) rList.get(0) : null;
	    double maxW = (firstRow != null) ? aaTool.getBigDecimal(firstRow.get("每日成材重量")).doubleValue() : 0.0;
	    
	    //廢重機台
	   java.util.List wasteList = (java.util.List) showData.get("廢重機台");    
	   java.util.Map wasteFirstRow = (wasteList != null && !wasteList.isEmpty()) ? (java.util.Map) wasteList.get(0) : null;
	   double maxWasteW = (wasteFirstRow != null) ? aaTool.getBigDecimal(wasteFirstRow.get("廢管")).doubleValue() : 0.0;
	   String totalWasteWStr = "0";
		   //計算全部重量 
		if (wasteList != null && !wasteList.isEmpty()) {
	        double totalSum = 0.0;		        
	        for (int i = 0; i < wasteList.size(); i++) {
	            java.util.Map row = (java.util.Map) wasteList.get(i);
	            double currentWeight = aaTool.getBigDecimal(row.get("廢管")).doubleValue();
	            
                totalSum += currentWeight; 
	        }	       
	        totalWasteWStr = aaTool.format(new java.math.BigDecimal(totalSum), "#,##0");
	   }
		
	    //機故時數
		java.util.List faultList = (java.util.List) showData.get("機故時數");    
		java.util.Map faultFirstRow = (faultList != null && !faultList.isEmpty()) ? (java.util.Map) faultList.get(0) : null;

		    // 取得第一名的故障時間作為分母
		    double maxFaultH = 0.0;
		    if (faultFirstRow != null) {
		        Object firstVal = faultFirstRow.get("機故時間") != null ? faultFirstRow.get("機故時間") : faultFirstRow.get("機故障時間");
		        if (firstVal != null) {
		            maxFaultH = aaTool.getBigDecimal(firstVal).setScale(1, java.math.BigDecimal.ROUND_HALF_UP).doubleValue();
		        }
		    }
		    
			// 計算總和 (先4捨5入)
		    double totalFaultHours = 0.0;
		    if (faultList != null) {	        
		        for (int i = 0; i < faultList.size(); i++) {	  
		            java.util.Map row = (java.util.Map) faultList.get(i);
		            if (row == null) continue;	         
		            Object rowVal = row.get("機故時間") != null ? row.get("機故時間") : row.get("機故障時間");
		            if (rowVal != null) {
		                double roundedVal = aaTool.getBigDecimal(rowVal).setScale(1, java.math.BigDecimal.ROUND_HALF_UP).doubleValue();
		                totalFaultHours += roundedVal; 
		            }
		        }
		    }
		  
	   %>
      	<article class="dl2-kpi-card" style="margin-top:8px">
		    <div class="dl2-bar-head">
		        <span class="dl2-kpi-title">日產量高峰</span>
		        <span class="dl2-kpi-value" style="color:var(--dl2-purple); font-size: 11pt; font-weight: bold;">
		            最高 <%= firstRow == null ? "0" : aaTool.format(aaTool.getBigDecimal(firstRow.get("每日成材重量")), "#,##0") %>
		        </span>
		    </div>
		    
		    <div class="dl2-bar-list">
		    <% 
		        if (rList != null) {

		            for (int i = 0; i < Math.min(rList.size(), 5); i++) {
		                java.util.Map row = (java.util.Map) rList.get(i);
		                String dateStr = row.get("完工日期").toString();               
		                

		                String mDate = dateStr;
		                if (dateStr.contains("-")) {
		                    String[] dateParts = dateStr.split("-");
		                    if (dateParts.length >= 3) {
		                        mDate = Integer.parseInt(dateParts[1]) + "/" + Integer.parseInt(dateParts[2]);
		                    }
		                }
		                
		                double currentW = aaTool.getBigDecimal(row.get("每日成材重量")).doubleValue();
		                double widthPercent = (maxW > 0) ? (currentW / maxW) * 100 : 0.0;		               
		                
		                String barColor;
		                if (currentW >= 88000) {
		                    barColor = "var(--dl2-purple)";
		                } else if (currentW >= 82000) {
		                    barColor = "var(--dl2-red)";
		                } else if (currentW >= 75000) {
		                    barColor = "var(--dl2-amber)";
		                } else {
		                    barColor = "var(--dl2-green)";
		                }
		    %>
		          <div class="dl2-split">
		              <span><%= mDate %></span>
		              <div class="dl2-track">
		                  <div class="dl2-fill" style="--w: <%= aaTool.format(new java.math.BigDecimal(widthPercent), "#0.0") %>%; --c: <%= barColor %>"></div>
		              </div>
		              <b><%= aaTool.format(aaTool.getBigDecimal(row.get("每日成材重量")), "#,##0") %></b>
		          </div>
		    <% 
		            }
		        } 
		    %>
		    </div>
		</article>

		<article class="dl2-kpi-card" style="margin-top:8px">
		    <div class="dl2-kpi-topline">
		        <span class="dl2-kpi-title">廢重機台  Top 5</span>
		        <span class="dl2-kpi-value" style="color:var(--dl2-purple); font-size: 11pt; font-weight: bold;">
		            全部總重 <%= totalWasteWStr %>
		        </span>
		    </div>
    
		    <div class="dl2-bar-list" style="margin-top: 10px;">
		    <% 
		        if (wasteList != null) {
		          
		            for (int i = 0; i < Math.min(wasteList.size(), 5); i++) {
		       
		                java.util.Map row = (java.util.Map) wasteList.get(i);
		                
		                String machineName = row.get("機台") != null ? row.get("機台").toString() : "";	                
		                double currentWasteW = aaTool.getBigDecimal(row.get("廢管")).doubleValue();	          
		                double widthPercent = (maxWasteW > 0) ? (currentWasteW / maxWasteW) * 100 : 0.0;		               
		                
		                String barColor;
		                if (currentWasteW >= 5000) {
		                    barColor = "var(--dl2-purple)";
		                } else if (currentWasteW >= 3000) {
		                    barColor = "var(--dl2-amber)";
		                } else if (currentWasteW >= 1000) {
		                    barColor = "var(--dl2-red)";
		                } else {
		                    barColor = "var(--dl2-green)";
		                }
		    %>
		          <div class="dl2-split">
		              <span><%= machineName %></span>
		              <div class="dl2-track">
		                  <div class="dl2-fill" style="--w: <%= aaTool.format(new java.math.BigDecimal(widthPercent), "#0.0") %>%; --c: <%= barColor %>"></div>
		              </div>
		              <b><%= aaTool.format(aaTool.getBigDecimal(row.get("廢管")), "#,##0") %></b>
		          </div>
		    <% 
		            }
		        } 
		    %>
		    </div>
		</article>
		 
		<article class="dl2-kpi-card" style="margin-top:8px">
		    <div class="dl2-kpi-topline">
		        <span class="dl2-kpi-title">機故時數 Top 5</span>
		        <span class="dl2-kpi-value" style="color:var(--dl2-purple); font-size: 11pt; font-weight: bold;">
		            全部合計 <%= aaTool.format(new java.math.BigDecimal(totalFaultHours), "#,##0.0") %> 小時
		        </span>
		    </div>
		    
		    <div class="dl2-bar-list" style="margin-top: 10px;">
		    <% 
		        if (faultList != null) {
		
		            for (int i = 0; i < Math.min(faultList.size(), 5); i++) {
		               
		                java.util.Map row = (java.util.Map) faultList.get(i); 
		                
		                String machineName = row.get("機台") != null ? row.get("機台").toString() : "";
		                Object loopVal = row.get("機故時間") != null ? row.get("機故時間") : row.get("機故障時間");
		                double currentFaultH = aaTool.getBigDecimal(loopVal).doubleValue();

		                double widthPercent = (maxFaultH > 0) ? (currentFaultH / maxFaultH) * 100 : 0.0;

		                String barColor;
		                if (currentFaultH >= 40.0) {
		                    barColor = "var(--dl2-purple)";
		                } else if (currentFaultH >= 30.0) {
		                    barColor = "var(--dl2-amber)";
		                } else if (currentFaultH >= 20.0) {
		                    barColor = "var(--dl2-red)";
		                } else {
		                    barColor = "var(--dl2-green)";
		                }
		    %>
		          <div class="dl2-split">
		              <span><%= machineName %></span>
		              <div class="dl2-track">
		                  <div class="dl2-fill" style="--w: <%= aaTool.format(new java.math.BigDecimal(widthPercent), "#0.0") %>%; --c: <%= barColor %>"></div>
		              </div>
		              <b><%= aaTool.format(new java.math.BigDecimal(currentFaultH), "#0.0") %></b>
		          </div>
		    <% 
		            }
		        } 
		    %>
		    </div>
		</article>
		
  </section>
		

	    <section class="dl2-section" id="dl2-process">
      <div class="dl2-section-title">
        <h2>加工課細項</h2>
        <small>加工 / 酸洗 </small>
      </div>
 <article class="dl2-kpi-card" style="margin-top:8px">
    <%
    java.util.List<java.util.Map> wl = (java.util.List<java.util.Map>) showData.get("待加工");
    
    // 寬度與邊距設定
    int W = 600, H = 260, padL = 10, padR = 35, padT = 16, padB = 25;
	int cW = W - padL - padR, cH = H - padT - padB;
    
    long lastVal = 0;
    if (wl != null && !wl.isEmpty()) {
        int n = wl.size();
        Object lastObj = wl.get(n-1).get("VALUE");
        lastVal = lastObj != null ? Math.round(Double.parseDouble(lastObj.toString())) : 0;
    }
    %>
    <div class="dl2-kpi-topline" style="display: flex; justify-content: space-between; align-items: center; width: 100%; font-family: 'Open Sans', 'Microsoft JhengHei', sans-serif;">
        <span class="dl2-kpi-title" style="font-weight: bold;">待加工量(含QC)-T</span>
        <% if (wl != null && !wl.isEmpty()) { %>
            <span style="font-size: 13px; color: #56A64B; font-weight: bold; ">
                待加工 Last*: <%=java.text.NumberFormat.getIntegerInstance().format(lastVal)%> T
            </span>
        <% } %>
    </div>
            
    <%
    if (wl == null || wl.isEmpty()) {
        out.print("<div style='text-align:center;padding:100px 0;color:#999;font-size:13px;'>目前無加工課待處理量數據</div>");
    } else {
       
        double maxV = Double.MIN_VALUE;
        for (java.util.Map m : wl) {
            Object o = m.get("VALUE");
            if (o != null) { 
                double v = Double.parseDouble(o.toString()); 
                if(v > maxV) maxV = v; 
            }
        }
        if (maxV == Double.MIN_VALUE || maxV <= 0) maxV = 500.0;        
        double lo = 0.0;      
        double hi = Math.ceil(maxV / 500.0) * 500.0;
        
        // 級距固定為 500
        double interval = 500.0; 
        
        if (hi <= maxV) hi += interval; 
        
        int n = wl.size();
        StringBuilder pts  = new StringBuilder();
        StringBuilder area = new StringBuilder();
        
        // 繪製折線與漸層
        double xLast = padL;
        for (int i = 0; i < n; i++) {
            Object o = wl.get(i).get("VALUE");
            double v = o!=null ? Double.parseDouble(o.toString()) : lo;
            double x = padL + (n==1 ? cW/2.0 : (double)i/(n-1)*cW);
            double y = padT + cH - (v-lo)/(hi-lo)*cH; 
            
            if(i==0){ 
                area.append((int)x + "," + (H-padB) + " "); 
                area.append((int)x + "," + (int)y + " ");   
            } else { 
                area.append((int)x + "," + (int)y + " "); 
            }
            pts.append((int)x + "," + (int)y + " ");
            if (i == n - 1) xLast = x;
        }
        area.append((int) xLast + "," + (H - padB)); 
        StringBuilder yTicks = new StringBuilder();
        double tickV = lo; 

        while (tickV <= hi) {
            double yy = padT + cH - (tickV-lo)/(hi-lo)*cH;
            yTicks.append("<line x1='").append(padL).append("' y1='").append((int)yy)
                  .append("' x2='").append(W-padR).append("' y2='").append((int)yy)
                  .append("' stroke='#f2f2f2' stroke-width='1'/>");
            
            String tickLabel = "";
            if (tickV == 0) {
                tickLabel = "0";
            } else if (tickV % 1000 == 0) {
                tickLabel = (int)(tickV / 1000.0) + "K"; // 1000 顯示 1K, 2000 顯示 2K
            } else {
                tickLabel = (tickV / 1000.0) + "K";      // 500 顯示 0.5K, 1500 顯示 1.5K
            }
            
            yTicks.append("<text x='").append(W-padR+6).append("' y='").append((int)(yy+5))
                  .append("' font-size='14' fill='#888' font-weight='bold'>")
                  .append(tickLabel).append("</text>");
            
            tickV += interval; 
        }
        
        if ((tickV - interval) < hi) {
            double yy = padT + cH - (hi-lo)/(hi-lo)*cH;
            //String tickLabel = (hi == 0) ? "0" : (int)(hi / 1000.0) + "K";
            String tickLabel = "";
			if (hi == 0) {
			    tickLabel = "0";
			} else if (hi % 1000 == 0) {
			    tickLabel = (int)(hi / 1000.0) + "K";
			} else {
			    tickLabel = (hi / 1000.0) + "K";
			}
            yTicks.append("<line x1='").append(padL).append("' y1='").append((int)yy).append("' x2='").append(W-padR).append("' y2='").append((int)yy).append("' stroke='#f2f2f2' stroke-width='1'/>");
            yTicks.append("<text x='").append(W-padR+6).append("' y='").append((int)(yy+5)).append("' font-size='14' fill='#888' font-weight='bold' >").append(tickLabel).append("</text>");
        }
        StringBuilder xTicks = new StringBuilder();
        int step = 4; // 固定每隔 4 天
        
        for (int i = 2; i < n; i += step) { //  i = 2 代表從第三筆資料開始
    
            Object tObj = wl.get(i).get("TIME");
            String lbl = "";
            if (tObj != null) { 
                String s = tObj.toString(); 
                if (s.length() >= 10) { 
                    lbl = s.substring(5, 7) + "/" + s.substring(8, 10); 
                } 
            }           
            double x = padL + (n == 1 ? cW / 2.0 : (double) i / (n - 1) * cW);
            
            xTicks.append("<text x='").append((int)x - 12 ).append("' y='").append(H - padB + 18)
                  .append("' font-size='14' fill='#888' font-weight='bold' text-anchor='middle' >")
                  .append(lbl).append("</text>");
        }
        
        // 輸出 SVG 畫面
        out.println("<div style='width:100%;margin-top:10px;overflow:hidden;'>");
        out.println("<svg viewBox='0 0 "+W+" "+H+"' preserveAspectRatio='none' style='width:100%;height:300px;display:block;'>");
        out.println("  <defs><linearGradient id='procGrad' x1='0' y1='0' x2='0' y2='1'>");
        out.println("    <stop offset='0%' stop-color='#56A64B' stop-opacity='0.20'/>"); 
        out.println("    <stop offset='100%' stop-color='#56A64B' stop-opacity='0.02'/>"); 
        out.println("  </linearGradient></defs>");
        out.println("<rect x='0' y='0' width='"+W+"' height='"+H+"' fill='#fff'/>"); 
        out.println(yTicks.toString());
        out.println(xTicks.toString());
        out.println("  <polygon points='"+area+"' fill='url(#procGrad)'/>"); 
        out.println("  <polyline points='"+pts+"' fill='none' stroke='#56A64B' stroke-width='2' stroke-linejoin='round'/>"); 
        out.println("</svg></div>");
    }
    %>
</article>

    </section>
   
    
		      <section class="dl2-section" id="dl2-downtime">
		      <div class="dl2-section-title">
		        <h2>設備停機分析</h2>
		        <small>小時 / 佔比</small>
		      </div>
		
		    <%
		    //String[] stopTitles   = { "製造課停機原因", "加工課停機原因" };
		    //String[] stopDataKeys = { "製造停機", "加工停機" };
		    //String[] stopTimeKeys = { "停機時間", "停機時間" };
		    String[] stopTitles   = { "製造課停機原因"  };
		    String[] stopDataKeys = { "製造停機"  };
		    String[] stopTimeKeys = { "停機時間"  };
		    //圓餅圖顏色
		    String[] colorPalette = {
		            "var(--dl2-green)", "var(--dl2-amber)",
		            "#78aef0", "var(--dl2-orange)" ,"var(--dl2-red)","#4e79a7","#b07cf0","var(--dl2-purple)", 
		        };
		  
		    java.util.List stopList = null;
		    java.util.Map stopFirstRow   = null;
		    String maxName = "", maxHStr = "", maxPStr = "", finalSeg = "";
		    double  maxP = 0.0, cum = 0.0, pVal = 0.0;
		    StringBuilder seg = null;
		
		    //for (int g = 0; g < 2; g++) {
		    for (int g = 0; g < 1; g++) {
		        stopList = (java.util.List) showData.get(stopDataKeys[g]);
		        stopFirstRow  = (stopList != null && !stopList.isEmpty()) ? (java.util.Map) stopList.get(0) : null;
		
		        maxName = stopFirstRow  != null && stopFirstRow .get("停機原因") != null ? stopFirstRow .get("停機原因").toString() : "";
		        java.math.BigDecimal maxH = stopFirstRow != null ? aaTool.getBigDecimal(stopFirstRow.get(stopTimeKeys[g])) : java.math.BigDecimal.ZERO;
		        maxP    = stopFirstRow  != null ? aaTool.getBigDecimal(stopFirstRow .get("佔比_百分比")).doubleValue() : 0.0;
		        maxHStr = aaTool.format(maxH.setScale(0, java.math.BigDecimal.ROUND_HALF_UP), "#,##0");
		        maxPStr = aaTool.format(new java.math.BigDecimal(maxP), "#0");
		
		        seg = new StringBuilder();
		        cum = 0.0;
		        if (stopList != null) {
		            for (int i = 0; i < stopList.size(); i++) {
		                java.util.Map row = (java.util.Map) stopList.get(i);
		                pVal = aaTool.getBigDecimal(row.get("佔比_百分比")).doubleValue();
		                if (pVal <= 0) continue;
		                double start = cum;
		                cum += pVal;
		                double end = (cum > 100.0 || i == stopList.size() - 1) ? 100.0 : cum;
		                if (seg.length() > 0) seg.append(", ");
		                seg.append(colorPalette[i % colorPalette.length]).append(" ")
		                   .append(String.format("%.1f", start)).append("% ")
		                   .append(String.format("%.1f", end)).append("%");
		                if (cum >= 100.0) break;
		            }
		        }
		        finalSeg = seg.length() > 0 ? seg.toString() : "#e0e0e0 0% 100%";
		%>
		        <article class="dl2-reason-card" style="margin-bottom:8px;">
		            <div class="dl2-bar-head"  style="font-weight: 850" >
		                <span><%= stopTitles[g] %></span>
		                <span style="color:var(--dl2-green); font-weight:bold;">
		                    <%= maxName %> <%= maxPStr %>%
		                </span>
		            </div>
		            <div class="dl2-donut-panel">
		                <div class="dl2-donut" style="--segments: <%= finalSeg %>">
		                    <div class="dl2-donut-label">
		                        <span>最大</span>
		                        <strong><%= maxHStr %></strong>
		                    </div>
		                </div>
		                <div class="dl2-reason-list">
		                <%
		                    if (stopList != null) {
		                        for (int i = 0; i < Math.min(stopList.size(), 5); i++) {
		                            java.util.Map row = (java.util.Map) stopList.get(i);
		                            String name    = row.get("停機原因") != null ? row.get("停機原因").toString() : "";
		                            java.math.BigDecimal hours = aaTool.getBigDecimal(row.get(stopTimeKeys[g]));
		                            double percent = aaTool.getBigDecimal(row.get("佔比_百分比")).doubleValue();                       
		                %>
		                    <div class="dl2-reason-row">
		                    <hr>
		                        <div class="dl2-reason-name" style="--c:<%= colorPalette[i % colorPalette.length] %>">
		                            <i></i><span><%= name %></span>
		                        </div>
		                        <div class="dl2-reason-num">
		                           <%= aaTool.format(hours.setScale(0, java.math.BigDecimal.ROUND_HALF_UP), "#,##0") %>
		                            | <%= aaTool.format(new java.math.BigDecimal(percent), "#0") %>%
		                        </div>
		                    </div>
		                <%
		                        }
		                    }
		                %>
		                </div>
		            </div>
		        </article>
		<%
		    } 
		%>
		    </section>
    
    
	<section class="dl2-section">
	      <div class="dl2-section-title">
       		<h2>總庫存</h2>    
       		<small><%= showData.get("斗二總庫存") %></small>   
      	  </div>
			 <%
			 //斗二庫存種類
			  String[][] _inv = {
				{"大原料鋼捲","斗二大原料鋼捲","#9b59b6"},
				{"成品鋼板捲","斗二成品鋼板捲","#1abc9c"},
			    {"管料","斗二管料","#e74c3c"},
			    {"次級","斗二次級","#95a5a6"},
			    {"配管","斗二配管","#e67e22"},
			    {"構造管","斗二構造管","#3498db"},			   
			    {"扁鐵","斗二扁鐵","#2ecc71"},
			    {"角鐵","斗二角鐵","#f39c12"},
			    {"無縫管","斗二無縫管","#e91e63"},
			   
			  };

			 
			  double[] _vals = new double[_inv.length];
			  double _total = 0;
			  for (int _i=0;_i<_inv.length;_i++) {
			    Object _o = showData.get(_inv[_i][1]);
			    double _v = 0;
			    if(_o!=null){try{_v=Double.parseDouble(_o.toString().replaceAll(",",""));}catch(Exception _e){}}
			    _vals[_i]=_v; _total+=_v;
			  }
			  if(_total==0) _total=1;
			  
			  
			%>
			
			<article class="dl2-kpi-card" style="margin-top:8px;padding:14px 16px;">
			

			
			  <%-- 橫向比例色條 --%>
			  <div style="display:flex;width:100%;height:12px;border-radius:6px;overflow:hidden;margin-bottom:14px;">
			  <%
			    for(int _i=0;_i<_inv.length;_i++){
			      double _pct=_vals[_i]/_total*100;
			      out.println("<div style='flex:"+String.format("%.4f",_pct)+";background:"+_inv[_i][2]+"'></div>");
			    }
			  %>
			  </div>
			
			<%
			   
				//判斷第一個div 不要分隔線
			    boolean isFirstDisplayed = true;			
			    for(int _i=0;_i<_inv.length;_i++){
			        if (_vals[_i] == 0) {
			            continue;
			        }
			        double _pct=_vals[_i]/_total*100;
			        long _rv=Math.round(_vals[_i]);
			        
			        
			        String borderStyle = isFirstDisplayed ? "border-top:none;" : "border-top:1px solid #f0f2f5;";
			        
			      
			        isFirstDisplayed = false;
			%>
				<div style="display:flex;align-items:center;padding:8px 0;<%= borderStyle %>">
				  <span style="width:10px;height:10px;border-radius:50%;background:<%= _inv[_i][2] %>;flex-shrink:0;margin-right:8px;"></span>
				  <span style="flex:1;font-size:13px; font-weight:800;color:var(--dl2-ink);"><%= _inv[_i][0] %></span>
				  <div style="text-align:right;">
				    <div style="font-size:15px;font-weight:800;color:var(--dl2-ink);"><%= String.format("%,d",_rv) %></div>
				    <div style="font-size:11px;font-weight: 750;color:var(--dl2-muted);"><%= String.format("%.1f",_pct) %>%</div>
				  </div>
				</div>
			<%
			    }
			%>
	    </article>
	</section>
	
  <section class="dl2-section" id="dl2-people">
      <div class="dl2-section-title">
        <h2>人力與追蹤項目</h2>
        <small>現況管理</small>
      </div>
      <article class="dl2-people-card" style="margin-top:8px">
        <div class="dl2-people-row" style="border-top:none;"><span>全廠合計人力</span><b><%= showData.get("全廠總人數") %> 人</b></div>
        <div class="dl2-people-row"><span>台籍 / 外籍總計</span><b><%= showData.get("台籍總人數") %> / <%= showData.get("外籍總人數") %></b></div>
      </article>
      <div class="dl2-people-grid">
        <article class="dl2-people-card">
          <p class="dl2-label">廠務人力</p>
          <strong><%= showData.get("廠務總人數") %>人</strong>
          <p class="dl2-sub">台籍 <%= showData.get("廠務台籍人數") %> / 外籍 <%= showData.get("廠務外籍人數") %></p>
        </article>
        <article class="dl2-people-card">
          <p class="dl2-label">生管成品人力</p>
          <strong style="color:var(--dl2-teal)"><%= showData.get("生管成品總人數") %> 人</strong>
          <p class="dl2-sub">台籍 <%= showData.get("生管成品台籍人數") %> / 外籍 <%= showData.get("生管成品外籍人數") %></p>
        </article>
      </div>
      <div class="dl2-people-grid">
        <article class="dl2-people-card">
          <p class="dl2-label">製造課人力</p>
          <strong><%= showData.get("製造總人數") %>人</strong>
          <p class="dl2-sub">台籍 <%= showData.get("製造台籍人數") %> / 外籍 <%= showData.get("製造外籍人數") %></p>
        </article>
        <article class="dl2-people-card">
          <p class="dl2-label">加工課人力</p>
          <strong style="color:var(--dl2-teal)"><%= showData.get("加工總人數") %> 人</strong>
          <p class="dl2-sub">台籍 <%= showData.get("加工台籍人數") %> / 外籍 <%= showData.get("加工外籍人數") %></p>
        </article>
      </div>
      <div class="dl2-people-grid">
        <article class="dl2-people-card">
          <p class="dl2-label">設備人力</p>
          <strong><%= showData.get("設備總人數") %>人</strong>
          <p class="dl2-sub">台籍 <%= showData.get("設備台籍人數") %> / 外籍 <%= showData.get("設備外籍人數") %></p>
        </article>
        <article class="dl2-people-card">
          <p class="dl2-label">其他人力</p>
          <strong style="color:var(--dl2-teal)"><%= showData.get("其他總人數") %> 人</strong>
          <p class="dl2-sub">台籍 <%= showData.get("其他台籍人數") %> / 外籍 <%= showData.get("其他外籍人數") %></p>
        </article>
      </div>
      	  

    </section>
  </div>
  
 
  
</div>

