<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.ds.dsjccom"%>
<%@ page import="com.icsc.bq.core.bqjc0421" %>
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

    bqjc0421 bq0421 = new bqjc0421(_dsCom);
    Map dashboardData = bq0421.getDashboardDataXZ(_dsCom, request);
    
    Map showData = (Map) (dashboardData != null ? dashboardData.get("XZData") : new HashMap());
    if (showData == null) showData = new HashMap();
   
%>

<div id="ajax-target-content">
<%
//out.println("<pre style='background:#2d2d2d; color:#7ec699; padding:15px; border-radius:5px;'>");
//out.println("====== [DEBUG XZ 繞過 500 成功拿到連線] ======");
//out.println("接收到的 updateDate -> " + updateDate);
//out.println("撈出來的製造資料 -> " + dashboardData);
//out.println("撈出來的待加工 -> " + showData.get("總庫存"));
//out.println("==============================================");
//out.println("</pre>");
%>
  <style>
  #ajax-target-content{
  -webkit-text-size-adjust: 100% !important;
    text-size-adjust: 100% !important;
  }
    /* 溪州廠專屬設計系統與色彩變數 (Scoped to Xizhou) */
    .xz-wrap {
      --xz-ink: #172033;
      --xz-muted: #6a778b;
      --xz-line: #dbe2eb;
      --xz-card: #ffffff;
      --xz-track: #edf1f5;
      --xz-green: #45a64a;
      --xz-green-soft: #e6f5e8;
      --xz-red: #e33151;
      --xz-red-soft: #ffe2e8;
      --xz-amber: #f0bd14;
      --xz-amber-soft: #fff3c9;
      --xz-blue: #5a91e6;
      --xz-blue-soft: #e7effd;
      --xz-orange: #ff6b1a;
      --xz-orange-soft: #ffe8d9;
      --xz-purple: #a65bd4;
      --xz-purple-soft: #f1e4fa;
      --xz-teal: #18a999;
      
      font-family: "Segoe UI", "Noto Sans TC", "Microsoft JhengHei", Arial, sans-serif;
      color: var(--xz-ink);
      padding: 4px 0 24px 0;
    }

    .xz-wrap * { box-sizing: border-box; }
    
    /* 基礎橫列佈局 */
    .xz-meta-row, .xz-kpi-topline, .xz-section-title, .xz-bar-head, .xz-reason-row, .xz-people-row, .xz-dept-title {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }

    .xz-hero { padding: 8px 2px 10px; }
    .xz-eyebrow { margin: 0; color: var(--xz-muted); font-size: 12px; font-weight: 750; }
    
    /* 狀態標籤 */
    .xz-live-pill, .xz-risk-pill, .xz-delta,.xz-delta-lower{
      display: inline-flex;
      align-items: center;
      min-height: 24px;
      padding: 0 8px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 850;
      white-space: nowrap;
    }
    .xz-live-pill { color: #176a38; background: var(--xz-green-soft); }
    .xz-live-pill::before { content: ""; width: 7px; height: 7px; margin-right: 5px; border-radius: 50%; background: var(--xz-green); }

    .xz-lead { margin: 6px 0 0 0; color: var(--xz-muted); font-size: 13px; line-height: 1.55; font-weight: 650; }
    .xz-summary-strip { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin: 12px 0; }

    /* 卡片設計 */
    .xz-hero-card, .xz-insight, .xz-dept-card, .xz-kpi-card, .xz-chart-card, .xz-reason-card, .xz-people-card {
      border: 1px solid var(--xz-line);
      border-radius: 12px;
      background: var(--xz-card);
      box-shadow: 0 4px 12px rgba(35, 48, 70, 0.05);
      padding: 12px;
    }

    .xz-hero-card.wide {
      grid-column: 1 / -1;
      color: #fff;
      border-color: #243756;
      background: #243653;
    }
    .xz-label { margin: 0; color: var(--xz-muted); font-size: 12px; font-weight: 750; }
    .xz-hero-card.wide .xz-label, .xz-hero-card.wide .xz-sub { color: rgba(255, 255, 255, 0.76); }
    
    .xz-value { margin-top: 8px; color: var(--xz-ink); font-size: 26px; line-height: 1; font-weight: 850; }
    .xz-hero-card.wide .xz-value { color: #fff; font-size: 30px; }
    .xz-sub { margin: 8px 0 0; color: var(--xz-muted); font-size: 12px; line-height: 1.35; font-weight: 700; }

    /* 風險與色塊標籤 */
    .xz-risk-pill { color: #a90f2c; background: var(--xz-red-soft); }
    .xz-risk-pill.orange { color: #a54200; background: var(--xz-orange-soft); }
    .xz-risk-pill.blue { color: #2450b8; background: var(--xz-blue-soft); }

    /* 錨點導航列 */
    .xz-local-nav {
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
    .xz-local-nav a {
      display: grid;
      place-items: center;
      height: 32px;
      border: 1px solid var(--xz-line);
      border-radius: 8px;
      color: #334155;
      background: #fff;
      text-decoration: none;
      font-size: 11px;
      font-weight: 850;
    }

    /* 區塊標題 */
    .xz-section { margin-top: 16px; scroll-margin-top: 48px; }
    .xz-section-title { margin-bottom: 8px; }
    .xz-section-title h2 { margin: 0; font-size: 17px; line-height: 1.2; font-weight: 850; }
    .xz-section-title small { color: var(--xz-muted); font-size: 12px; font-weight: 750; }

    /* 重點洞察 (四個重點) */
    .xz-insights, .xz-dept-grid, .xz-kpi-grid, .xz-bar-list, .xz-reason-list, .xz-people-grid { display: grid; gap: 8px; }
    .xz-insight { display: grid; grid-template-columns: 5px 1fr; gap: 10px; padding: 11px 12px 11px 0; overflow: hidden; }
    .xz-insight::before { content: ""; width: 5px; height: 100%; border-radius: 0 3px 3px 0; background: var(--xz-orange); }
    .xz-insight.red::before { background: var(--xz-red); }
    .xz-insight.blue::before { background: var(--xz-blue); }
    .xz-insight.green::before { background: var(--xz-green); }
    .xz-insight b { display: block; margin-bottom: 3px; font-size: 14px; line-height: 1.25; }
    .xz-insight span { display: block; color: var(--xz-muted); font-size: 12px; line-height: 1.45; font-weight: 650; }

    /* 課別快覽 */
    .xz-dept-grid { grid-template-columns: 1fr; }
    .xz-dept-title b { font-size: 15px; font-weight: 850; }
    .xz-dept-title span { color: var(--xz-muted); font-size: 12px; font-weight: 750; }
    
    .xz-metric-row { display: flex; justify-content: space-between; align-items: baseline; min-height: 34px; padding: 8px 0; border-top: 1px solid #edf1f5; }
    .xz-metric-row:first-of-type { border-top: 0; }
    .xz-metric-row span { color: var(--xz-muted); font-size: 12px; font-weight: 750; }
    .xz-metric-row strong { color: var(--c, var(--xz-ink)); font-size: 17px; font-weight: 850; }

    /* 進度條與 KPI */
    .xz-kpi-title { font-size: 14px; font-weight: 850; }
    .xz-kpi-value { color: var(--c, var(--xz-ink)); font-size: 22px; font-weight: 850; }
    .xz-track { position: relative; height: 10px; overflow: hidden; border-radius: 999px; background: var(--xz-track); margin: 6px 0; }
    .xz-fill { width: var(--w); min-width: 3px; height: 100%; border-radius: inherit; background: var(--c); }
    .xz-kpi-meta, .xz-bar-meta { display: flex; justify-content: space-between; gap: 8px; color: var(--xz-muted); font-size: 11px; font-weight: 700; }
    
    .xz-delta { color: #a90f2c; background: var(--xz-red-soft); }
    .xz-delta-lower { color: #176a38; background: var(--xz-green-soft); }
    .xz-delta.good { color: #176a38; background: var(--xz-green-soft); }
    .xz-delta.warn { color: #8a6200; background: var(--xz-amber-soft); }

    /* 長條圖型態排版 */
    .xz-split { display: grid; grid-template-columns: 50px 1fr 42px; gap: 16px; align-items: center; margin-top: 6px; color: var(--xz-muted); font-size: 12px; font-weight: 750; }
    .xz-split .xz-track { height: 8px; margin: 0; }
    .xz-split b { text-align: right; color: var(--xz-ink); }

    /* 圓餅圖/甜甜圈面板 */
    .xz-donut-panel { display: grid; grid-template-columns: 100px 1fr; gap: 12px; align-items: center; margin-top: 10px; }
    .xz-donut { position: relative; width: 100px; aspect-ratio: 1; border-radius: 50%; background: conic-gradient(var(--segments)); }
    .xz-donut::after { content: ""; position: absolute; inset: 24px; border-radius: 50%; background: var(--xz-card); }
    .xz-donut-label { position: absolute; z-index: 2; inset: 0; display: grid; place-items: center; text-align: center; font-size: 11px; font-weight: 850; }
    .xz-donut-label strong { display: block; font-size: 16px; line-height: 1; }

    /* 停機細項列表 */
    .xz-reason-row { min-height: 28px; padding: 4px 0; border-bottom: 1px solid #edf1f5; font-size: 12px; font-weight: 800; }
    .xz-reason-row:last-child { border-bottom: 0; }
    .xz-reason-name { display: flex; align-items: center; gap: 6px; min-width: 0; }
    .xz-reason-name i { flex: 0 0 auto; width: 8px; height: 8px; border-radius: 3px; background: var(--c); }
    .xz-reason-name span { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .xz-reason-num { text-align: right; white-space: nowrap; color: var(--xz-muted); }

    /* 人力板塊 */
    .xz-people-grid { 
    grid-template-columns: 1fr 1fr; 
    margin-top:10px; 
    }
    .xz-people-card strong { display: block; margin-top: 4px; color: var(--xz-purple); font-size: 30px; font-weight: 850; }
    .xz-people-row { padding: 10px 0; border-top: 1px solid #edf1f5; color: var(--xz-muted); font-size: 12px; font-weight: 750; }
    .xz-people-row b { color: var(--xz-ink); font-size: 15px; }
    
    /*重拋率展開*/
	.xz-kpi-card .xz-expand-content {
    max-height: 0;
    opacity: 0;
    overflow: hidden;
    border-top: 1px dashed transparent; 
    padding-top: 0;
    transition: max-height 0.28s ease-out, opacity 0.2s ease, border-color 0.2s ease, padding 0.2s ease;
	}
	.xz-kpi-card.open .xz-expand-content {
	    max-height: 1000px;         
	    opacity: 1;
	    border-top-color: #d1d1d6;  
	    padding-top: 12px;  
	    margin-top: 18px;      
	}
	.xz-kpi-card.open .toggle-icon {
    transform: rotate(180deg);
	}
	
  </style>
  <div class="xz-wrap">
    <header class="xz-hero">
      <div class="xz-meta-row">
        <p class="xz-eyebrow">溪州廠∣製造課 + 加工課</p>
        <span class="xz-live-pill">本月摘要</span>
      </div>
      <p class="xz-lead">集中檢視瓶頸與課別生產細項。</p>
    </header>

    <nav class="xz-local-nav">
      <a href="javascript:document.getElementById('xz-summary').scrollIntoView({behavior:'smooth'});">概覽</a>
      <a href="javascript:document.getElementById('xz-make').scrollIntoView({behavior:'smooth'});">製造</a>
      <a href="javascript:document.getElementById('xz-process').scrollIntoView({behavior:'smooth'});">加工</a>
      <a href="javascript:document.getElementById('xz-downtime').scrollIntoView({behavior:'smooth'});">停機</a>
      <a href="javascript:document.getElementById('xz-people').scrollIntoView({behavior:'smooth'});">人力</a>
    </nav>

    <div class="xz-summary-strip" id="xz-summary">
      <article class="xz-hero-card wide" style="display:none" >
        <p class="xz-label">共同最大停機原因</p>
        <div class="xz-kpi-topline">
          <div class="xz-value">無人操作</div>
          <span class="xz-risk-pill orange">1,376 小時</span>
        </div>
        <p class="xz-sub">製造 691 小時、加工 685 小時，兩課別皆為第一大設備損失。</p>
      </article>

      <article class="xz-hero-card">
       <p class="xz-label">製造課產量</p>
        <div class="xz-value"><%= showData.get("當月產量") %> t</div>
        <p class="xz-sub">成材率<%= showData.get("當月成材率") %>%<br>Q良品率 <%= showData.get("Q良品率") %>%</p>
      </article>

      <article class="xz-hero-card">
        <p class="xz-label">加工課產量</p>
        <div class="xz-value"><%=showData.get("加工產量") %> t</div>
        <p class="xz-sub"><%= aaTool.format(showData.get("支數"),"#,##0") %> 支<br>重拋率 <%=showData.get("重拋率") %>%</p>
      </article>
    </div>

    <section class="xz-section" style="display:none" >
      <div class="xz-section-title">
        <h2>關鍵洞察</h2>
        <small>4 個重點</small>
      </div>
      <div class="xz-insights">
        <div class="xz-insight red">
          <div>
            <b>無人操作是最大設備損失</b>
            <span>製造 691 小時、加工 685 小時，皆高於機故與換模。</span>
          </div>
        </div>
        <div class="xz-insight">
          <div>
            <b>製造廢重集中在 BF72、BF59</b>
            <span>前兩台廢重 13,331，占前 10 名約 47.5%，優先改善。</span>
          </div>
        </div>
        <div class="xz-insight blue">
          <div>
            <b>加工重拋率偏高</b>
            <span>重拋率 33.9%，同時待手工矯直 2,154 支，存在產線瓶頸。</span>
          </div>
        </div>
        <div class="xz-insight green">
          <div>
            <b>兩課移動率同為 76.78%</b>
            <span>可用同一個節奏指標追進度，改善重點在停機與返工。</span>
          </div>
        </div>
      </div>
    </section>

    <section class="xz-section">
      <div class="xz-section-title">
        <h2>課別快覽</h2>
        <small>當月 KPI</small>
      </div>
      <div class="xz-dept-grid">
        <article class="xz-dept-card" style="margin-bottom:8px;">
          <div class="xz-dept-title">
            <b>製造課</b> <span>產量與品質</span>
          </div>
         <div class="xz-metric-row"><span>當月產量</span><strong style="color:var(--xz-red)"><%= showData.get("當月產量") %> t</strong></div>
          <div class="xz-metric-row"><span>Q型態 / 光退產量</span><strong><%= showData.get("Q產量") %> t / <%= showData.get("光退產量") %> t</strong></div>
          <div class="xz-metric-row"><span>成材率 / Q成材率</span><strong style="color:var(--xz-green)"><%= showData.get("當月成材率") %>% / <%= showData.get("Q型態成材率") %>%</strong></div>
          <div class="xz-metric-row"><span>Q型態良品率</span><strong style="color:var(--xz-amber)"><%= showData.get("Q良品率") %>%</strong></div>
          <div class="xz-metric-row"><span>廢管重量</span><strong style="color:var(--xz-purple)"><%= showData.get("廢管重量") %> t</strong></div>
        </article>

        <article class="xz-dept-card">
          <div class="xz-dept-title">
            <b>加工課</b> <span>加工與返工</span>
          </div>
         <div class="xz-metric-row"><span>加工產量</span><strong style="color:var(--xz-red)"><%= showData.get("加工產量") %> t</strong></div>
          <div class="xz-metric-row"><span>加工支數</span><strong style="color:var(--xz-red)"><%= aaTool.format(showData.get("支數"),"#,##0") %></strong></div>
          <div class="xz-metric-row"><span>重拋率</span><strong style="color:var(--xz-purple)"><%= showData.get("重拋率") %>%</strong></div>
          <div class="xz-metric-row"><span>可用噴槍庫存</span><strong style="color:var(--xz-green)"><%= aaTool.format(showData.get("可用噴槍庫存"),"#,##0") %></strong></div>
          <div class="xz-metric-row"><span>待手工矯直</span><strong style="color:var(--xz-red)"><%= aaTool.format(showData.get("待手工矯直"),"#,##0") %> 支</strong></div>
        </article>
      </div>
    </section>

    <section class="xz-section" id="xz-make">
      <div class="xz-section-title">
        <h2>製造課細項</h2>
        <small>產量 / 廢重 / 機故</small>
      </div>
     <div class="xz-kpi-grid">
        <article class="xz-kpi-card">
          <div class="xz-kpi-topline"><span class="xz-kpi-title">Q型態占產量</span><span class="xz-kpi-value" style="color:var(--xz-red)">
				<%= showData.get("Q型態占產量") %>%</span></div>
          <div class="xz-track"><div class="xz-fill" style="--w:<%= showData.get("Q型態占產量") %>%;--c:var(--xz-red)"></div></div>
          <div class="xz-kpi-meta"><span><%= showData.get("Q產量") %> t / <%= showData.get("當月產量") %> t</span><span class="xz-delta warn">良率 <%= showData.get("Q良品率") %>%</span></div>
        </article>
        <article class="xz-kpi-card">
          <div class="xz-kpi-topline"><span class="xz-kpi-title">光退占產量</span><span class="xz-kpi-value" style="color:var(--xz-red)"><%= showData.get("光退占產量") %>%</span></div>
          <div class="xz-track"><div class="xz-fill" style="--w:<%= showData.get("光退占產量") %>%;--c:var(--xz-red)"></div></div>
          <div class="xz-kpi-meta"><span><%= showData.get("光退產量") %> t / <%= showData.get("當月產量") %> t</span><span class="xz-delta good">成材率 <%= showData.get("當月成材率") %>%</span></div>
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
	   String topTwoRatioStr = "0.0";
		   //計算前2占比 
		   if (wasteList != null && !wasteList.isEmpty()) {
		        double topTwoSum = 0.0;
		        double totalSum = 0.0;		        
		        for (int i = 0; i < wasteList.size(); i++) {
		            java.util.Map row = (java.util.Map) wasteList.get(i);
		            double currentWeight = aaTool.getBigDecimal(row.get("廢管")).doubleValue();
		            totalSum += currentWeight; // 累加全機台總重		            
		            if (i < 2) {
		                topTwoSum += currentWeight; // 累加前兩名重量
		            }
		        }
		        
		        // 防除以 0 計算百分比
		        if (totalSum > 0) {
		            double ratio = (topTwoSum / totalSum) * 100;
		            topTwoRatioStr = aaTool.format(new java.math.BigDecimal(ratio), "#0.0");
		        }
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
      	<article class="xz-kpi-card" style="margin-top:8px">
		    <div class="xz-bar-head">
		        <span class="xz-kpi-title">日產量高峰</span>
		        <span class="xz-kpi-value" style="color:var(--xz-purple); font-size: 11pt; font-weight: bold;">
		            最高 <%= firstRow == null ? "0" : aaTool.format(aaTool.getBigDecimal(firstRow.get("每日成材重量")), "#,##0") %>
		        </span>
		    </div>
		    
		    <div class="xz-bar-list">
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
		                    barColor = "var(--xz-purple)";
		                } else if (currentW >= 82000) {
		                    barColor = "var(--xz-red)";
		                } else if (currentW >= 75000) {
		                    barColor = "var(--xz-amber)";
		                } else {
		                    barColor = "var(--xz-green)";
		                }
		    %>
		          <div class="xz-split">
		              <span><%= mDate %></span>
		              <div class="xz-track">
		                  <div class="xz-fill" style="--w: <%= aaTool.format(new java.math.BigDecimal(widthPercent), "#0.0") %>%; --c: <%= barColor %>"></div>
		              </div>
		              <b><%= aaTool.format(aaTool.getBigDecimal(row.get("每日成材重量")), "#,##0") %></b>
		          </div>
		    <% 
		            }
		        } 
		    %>
		    </div>
		</article>

		<article class="xz-kpi-card" style="margin-top:8px">
		    <div class="xz-kpi-topline">
		        <span class="xz-kpi-title">廢重機台 Top 5</span>
		        <span class="xz-kpi-value" style="color:var(--xz-purple); font-size: 11pt; font-weight: bold;">
		            前二 <%= topTwoRatioStr %>%
		        </span>
		    </div>
    
		    <div class="xz-bar-list" style="margin-top: 10px;">
		    <% 
		        if (wasteList != null) {
		          
		            for (int i = 0; i < Math.min(wasteList.size(), 5); i++) {
		       
		                java.util.Map row = (java.util.Map) wasteList.get(i);
		                
		                String machineName = row.get("機台") != null ? row.get("機台").toString() : "";	                
		                double currentWasteW = aaTool.getBigDecimal(row.get("廢管")).doubleValue();	          
		                double widthPercent = (maxWasteW > 0) ? (currentWasteW / maxWasteW) * 100 : 0.0;		               
		                
		                String barColor;
		                if (currentWasteW >= 5000) {
		                    barColor = "var(--xz-purple)";
		                } else if (currentWasteW >= 3000) {
		                    barColor = "var(--xz-amber)";
		                } else if (currentWasteW >= 1000) {
		                    barColor = "var(--xz-red)";
		                } else {
		                    barColor = "var(--xz-green)";
		                }
		    %>
		          <div class="xz-split">
		              <span><%= machineName %></span>
		              <div class="xz-track">
		                  <div class="xz-fill" style="--w: <%= aaTool.format(new java.math.BigDecimal(widthPercent), "#0.0") %>%; --c: <%= barColor %>"></div>
		              </div>
		              <b><%= aaTool.format(aaTool.getBigDecimal(row.get("廢管")), "#,##0") %></b>
		          </div>
		    <% 
		            }
		        } 
		    %>
		    </div>
		</article>
		 
		<article class="xz-kpi-card" style="margin-top:8px">
		    <div class="xz-kpi-topline">
		        <span class="xz-kpi-title">機故時數 Top 5</span>
		        <span class="xz-kpi-value" style="color:var(--xz-purple); font-size: 11pt; font-weight: bold;">
		            合計 <%= aaTool.format(new java.math.BigDecimal(totalFaultHours), "#,##0.0") %> 小時
		        </span>
		    </div>
		    
		    <div class="xz-bar-list" style="margin-top: 10px;">
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
		                    barColor = "var(--xz-purple)";
		                } else if (currentFaultH >= 30.0) {
		                    barColor = "var(--xz-amber)";
		                } else if (currentFaultH >= 20.0) {
		                    barColor = "var(--xz-red)";
		                } else {
		                    barColor = "var(--xz-green)";
		                }
		    %>
		          <div class="xz-split">
		              <span><%= machineName %></span>
		              <div class="xz-track">
		                  <div class="xz-fill" style="--w: <%= aaTool.format(new java.math.BigDecimal(widthPercent), "#0.0") %>%; --c: <%= barColor %>"></div>
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
		<%

		String[] subTitles = { "圓管重拋率", "方管重拋率", "0-50.8圓管重拋率","0-50.8方管重拋率","50.8~76.2圓管重拋率","60↑方管重拋率","76.2~101.6圓管重拋率","114以上圓管重拋率" };
		String[] subKeys   = { "圓管重拋率", "方管重拋率", "圓管重拋率_50以下","方管重拋率_58以下","圓管重拋率_50_8到76_2","方管重拋率_60以上","圓管重拋率_76_2到101_6","圓管重拋率_114以上" };
		double[] subTargets = { 15, 33, 22, 25, 35, 50, 40, 50 }; //  每個細項可以有各自不同的 KPI 目標值


		
		// 1. 計算最外層「總重拋率」
		double rVal = aaTool.getBigDecimal(showData.get("重拋率")).doubleValue();
		String ratioColor = (rVal >= 25) ? "var(--xz-purple)" : 
		                    (rVal >= 20) ? "var(--xz-red)" : 
		                    (rVal >= 15) ? "var(--xz-green)" : 
		                    (rVal >= 10) ? "var(--xz-blue)" : "var(--xz-green)";
		%>
		
    <section class="xz-section" id="xz-process">
      <div class="xz-section-title">
        <h2>加工課細項</h2>
        <small>加工 / 重拋 / 呆滯</small>
      </div>
      <div class="xz-kpi-grid">
		<article class="xz-kpi-card" onclick="this.classList.toggle('open');" style="cursor: pointer; user-select: none;">
		    
		    <%-- 外層：顯示總重拋率 (維持原樣) --%>
		    <div class="xz-kpi-topline">
            <span class="xz-kpi-title">
                <svg id="target-icon" class="toggle-icon" style="color: #333; transition: transform 0.3s ease; margin-right: 8px; vertical-align: middle;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                  <polyline points="6 9 12 15 18 9"></polyline>
                </svg>
                重拋率
            </span>
            <span class="xz-kpi-value" style="color:<%= ratioColor %>">
                <%= showData.get("重拋率") %> %
            </span>
        </div>
		
		    <div class="xz-track">
		        <div class="xz-fill" style="--w:<%= rVal %>%;--c:<%= ratioColor %>"></div>
		    </div>
		
		    <div class="xz-kpi-meta">
		        <span>目標：20%↓</span>
		        <% if (rVal > 20) { %>
		            <span class="xz-delta">高於標示</span>
		        <% } else { %>
		            <span class="xz-delta-lower">低於標示</span>
		        <% } %>
		    </div>
		
		    
		   <div class="xz-expand-content" onclick="event.stopPropagation();" >
		        <%
		        for (int i = 0; i < subKeys.length; i++) {	  
		            Object rawVal = showData.get(subKeys[i]);
		            double currentRatio = 0.0;
		            if (rawVal != null) {
		                currentRatio = Double.parseDouble(String.valueOf(rawVal).replace("%", ""));
		            }

		            String currentBgColor = (currentRatio >= 25) ? "var(--xz-purple)" : 
		                                    (currentRatio >= 20) ? "var(--xz-red)" : 
		                                    (currentRatio >= 15) ? "var(--xz-green)" : 
		                                    (currentRatio >= 10) ? "var(--xz-blue)" : "var(--xz-green)";
		            double targetVal = subTargets[i];
		        %>
		          
		            <div class="xz-sub-kpi-item" style="margin-bottom: 12px; margin-top: 8px;">
		                <div class="xz-kpi-topline">
		                    <span class="xz-kpi-title" ><%= subTitles[i] %></span>
		                    <span class="xz-kpi-value" style="font-size:1.05em; color:<%= currentBgColor %>">
		                        <%= aaTool.format(java.math.BigDecimal.valueOf(currentRatio), "#0.0") %> %
		                    </span>
		                </div>
		
		                <div class="xz-track" > 
		                    <div class="xz-fill" style="--w:<%= currentRatio %>%;--c:<%= currentBgColor %>"></div>
		                </div>
		
		                <div class="xz-kpi-meta" style="font-size: 11px;">
		                    <span>目標：<%= aaTool.format(java.math.BigDecimal.valueOf(targetVal), "#0") %>%↓</span>
		                    <% if (currentRatio > targetVal) { %>
		                        <span class="xz-delta">高於標示</span>
		                    <% } else { %>
		                        <span class="xz-delta-lower">低於標示</span>
		                    <% } %>
		                </div>
		            </div>
		        <%
		        }  
		        %>
		    </div>
		</article>
        <article class="xz-kpi-card">
          <div class="xz-kpi-topline"><span class="xz-kpi-title">呆滯品支數</span><span class="xz-kpi-value" style="color:var(--xz-green)"><%= aaTool.format(showData.get("總呆滯品支數"),"#,##0") %></span></div>
          <div class="xz-track"><div class="xz-fill" style="--w:99.9%;--c:var(--xz-green)"></div></div>
          <div class="xz-kpi-meta"><span>&lt;90天:<%= aaTool.format(showData.get("小於90天"),"#,##0") %>  ;90~180天:<%= aaTool.format(showData.get("從90到180天"),"#,##0") %></span><span class="xz-delta good">&gt;180天:<%= aaTool.format(showData.get("大於180天"),"#,##0") %> </span></div>
        </article>
      </div>

		 <%
		    String[] sizeLabels = {"10~30","30~50","50~60","60~70","70~90","90~120","120~180","180~220"};
		    String[] sizeKeys   = {"佔比_10到30","佔比_30到50","佔比_50到60","佔比_60到70","佔比_70到90","佔比_90到120","佔比_120到180","佔比_180到220"};
		    String[] matKeys    = {"材積_10到30","材積_30到50","材積_50到60","材積_60到70","材積_70到90","材積_90到120","材積_120到180","材積_180到220"};
		
		    // 顏色固定依排名，不參與排序
		    String[] rankColors = {"#4e79a7","#7b68ee","var(--xz-amber)","var(--xz-red)","var(--xz-green)","var(--xz-orange)","#78aef0","#b07cf0"};
		    double[] vals = new double[sizeKeys.length];
		    for (int i = 0; i < sizeKeys.length; i++) {
		        vals[i] = aaTool.getBigDecimal(showData.get(sizeKeys[i])).doubleValue();
		    }
		
		    // 泡沫排序，只交換 vals / sizeLabels / sizeKeys / matKeys，不動 rankColors
		    for (int i = 0; i < sizeKeys.length - 1; i++) {
		        for (int j = 0; j < sizeKeys.length - 1 - i; j++) {
		            if (vals[j] < vals[j+1]) {
		                double tmpV = vals[j];       vals[j] = vals[j+1];             vals[j+1] = tmpV;
		                String tmpL = sizeLabels[j]; sizeLabels[j] = sizeLabels[j+1]; sizeLabels[j+1] = tmpL;
		                String tmpK = sizeKeys[j];   sizeKeys[j] = sizeKeys[j+1];     sizeKeys[j+1] = tmpK;
		                String tmpM = matKeys[j];    matKeys[j] = matKeys[j+1];       matKeys[j+1] = tmpM;
		            }
		        }
		    }
		
		    // 動態產生 donut segments，用 rankColors[i] 依排名取色
		    StringBuilder segments = new StringBuilder();
		    double cumulative = 0.0;
		    for (int i = 0; i < sizeLabels.length; i++) {
		        if (vals[i] <= 0) continue;
		        double end = cumulative + vals[i];
		        if (segments.length() > 0) segments.append(", ");
		        segments.append(rankColors[i])
		                .append(" ")
		                .append(String.format("%.1f", cumulative))
		                .append("% ")
		                .append(String.format("%.1f", end))
		                .append("%");
		        cumulative = end;
		    }
		%>


		<article class="xz-chart-card" style="margin-top:8px">
		    <div class="xz-bar-head"  style="font-weight: 850" >
		        <span>圓管待拋材積尺寸分佈</span>
		        <span style="color:#4e79a7"><%= sizeLabels[0] %> 最大</span>
		    </div>
		    <div class="xz-donut-panel">
		        <div class="xz-donut" style="--segments: <%= segments.toString() %>">
		            <div class="xz-donut-label">主尺寸<strong><%= aaTool.format(new java.math.BigDecimal(vals[0]), "#0") %>%</strong></div>
		        </div>
		        <div class="xz-reason-list">
		        <%
		            int rank = 0;
		            for (int i = 0; i < 4; i++) {
		                if (vals[i] <= 0) continue;		                
		                java.math.BigDecimal matVol = aaTool.getBigDecimal(showData.get(matKeys[i]));
		        %>
		            <div class="xz-reason-row">
		                <div class="xz-reason-name" style="--c:<%= rankColors[rank] %>">
		                    <i></i><span><%= sizeLabels[i] %></span>
		                </div>
		                <div class="xz-reason-num">
		                    <%= aaTool.format(matVol.setScale(3, java.math.BigDecimal.ROUND_HALF_UP), "#,##0.000") %>
		                    &nbsp;|&nbsp;
		                    <%= aaTool.format(new java.math.BigDecimal(vals[i]), "#0") %>%
		                </div>
		            </div>
		        <%
		                rank++;
		            }
		        %>
		        </div>
		    </div>
		</article>
<article class="xz-kpi-card" style="margin-top:8px">
<%
java.util.List<java.util.Map> wl = (java.util.List<java.util.Map>) showData.get("待加工");

int W = 600, H = 260, padL = 10, padR = 35, padT = 16, padB = 20;
int cW = W - padL - padR, cH = H - padT - padB;


long lastVal = 0;
if (wl != null && !wl.isEmpty()) {
    int n = wl.size();
    Object lastObj = wl.get(n-1).get("不含品檢");
    lastVal = lastObj != null ? Math.round(Double.parseDouble(lastObj.toString())) : 0;
}
%>
    <div class="xz-kpi-topline" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
        <span class="xz-kpi-title" style="font-weight: bold;">加工課待處理量/T</span>
        <% if (wl != null && !wl.isEmpty()) { %>
            <span style="font-size: 13px; color: #4e79a7; font-weight: bold; ">
                不含品檢 Last*: <%=lastVal%> T
            </span>
        <% } %>
    </div>
		    
<%
if (wl == null || wl.isEmpty()) {
    out.print("<div style='text-align:center;padding:100px 0;color:#999;font-size:13px;'>目前無加工課待處理量數據</div>");
} else {
   
    double maxV = Double.MIN_VALUE;
    for (java.util.Map m : wl) {
        Object o = m.get("不含品檢");
        if (o != null) { 
            double v = Double.parseDouble(o.toString()); 
            if(v > maxV) maxV = v; 
        }
    }
    

    double lo = 0.0;
    
 
    double hi = Math.ceil(maxV / 100.0) * 100.0;
    if (hi <= 0) hi = 100.0; 
    
    int n = wl.size();
 
    StringBuilder pts  = new StringBuilder();
    StringBuilder area = new StringBuilder();
 
    double x0 = padL;
    double y0 = 0;
    for (int i = 0; i < n; i++) {
        Object o = wl.get(i).get("不含品檢");
        double v = o!=null ? Double.parseDouble(o.toString()) : lo;
        double x = padL + (n==1 ? cW/2.0 : (double)i/(n-1)*cW);
        double y = padT + cH - (v-lo)/(hi-lo)*cH; 
        if(i==0){ x0=x; y0=y; area.append((int)x+","+(H-padB)+" ").append((int)x+","+(int)y+" "); }
        else { area.append((int)x+","+(int)y+" "); }
        pts.append((int)x+","+(int)y+" ");
    }
    double xLast = padL + cW;
    area.append((int)xLast+","+(H-padB));

 
    StringBuilder yTicks = new StringBuilder();
    double tickV = 0.0; 
    while (tickV <= hi) {
        double yy = padT + cH - (tickV-lo)/(hi-lo)*cH;
        yTicks.append("<line x1='").append(padL).append("' y1='").append((int)yy)
              .append("' x2='").append(W-padR).append("' y2='").append((int)yy)
              .append("' stroke='#eee' stroke-width='1'/>");
        yTicks.append("<text x='").append(W-padR+4).append("' y='").append((int)(yy+4))
              .append("' font-size='14' fill='#888' font-weight='bold'>").append((int)tickV).append("</text>");
        tickV += 100.0; 
    }

    // X軸日期處理 (從第二筆資料 i = 1 開始抽樣，每 10 天秀一次，最多顯示 9 個)
    StringBuilder xTicks = new StringBuilder();
    int step = 10;
    if (n / step > 9) {
        step = (int) Math.ceil((double) n / 9.0);
    }
    if (step < 1) step = 1;

    int displayCount = 0; 
    for (int i = 1; i < n; i += step) {
        if (displayCount >= 9) break; 

        Object tObj = wl.get(i).get("TIME");
        String lbl = "";
        if (tObj != null) { 
            String s = tObj.toString(); 
            if (s.length() >= 10) { 
                lbl = s.substring(5, 7) + "/" + s.substring(8, 10); 
            } 
        }
        
        double x = padL + (n == 1 ? cW / 2.0 : (double) i / (n - 1) * cW);
        
       
        xTicks.append("<text x='").append((int)x).append("' y='").append(H - padB + 16)
              .append("' font-size='14' fill='#888' font-weight='bold' >")
              .append(lbl).append("</text>");
              
        displayCount++; 
    }
    
    // 輸出 SVG 畫面
    out.println("<div style='width:100%;margin-top:10px;overflow:hidden;'>");
    out.println("<svg viewBox='0 0 "+W+" "+H+"' preserveAspectRatio='none' style='width:100%;height:280px;display:block;'>");
    out.println("  <defs><linearGradient id='procGrad' x1='0' y1='0' x2='0' y2='1'>");
    out.println("    <stop offset='0%' stop-color='#0052cc' stop-opacity='0.20'/>"); 
    out.println("    <stop offset='100%' stop-color='#0052cc' stop-opacity='0'/>"); 
    out.println("  </linearGradient></defs>");
    out.println(yTicks.toString());
    out.println(xTicks.toString());
    out.println("  <polygon points='"+area+"' fill='url(#procGrad)'/>"); 
    out.println("  <polyline points='"+pts+"' fill='none' stroke='#0052cc' stroke-width='2' stroke-linejoin='round'/>"); 
    out.println("</svg></div>");
}
%>
		 
		</article>
    </section>

    <section class="xz-section" id="xz-downtime">
      <div class="xz-section-title">
        <h2>設備停機分析</h2>
        <small>小時 / 佔比</small>
      </div>

    <%
    String[] stopTitles   = { "製造課停機原因", "加工課停機原因" };
    String[] stopDataKeys = { "製造停機", "加工停機" };
    String[] stopTimeKeys = { "停機時間", "停機時間" };

    //圓餅圖顏色
    String[] colorPalette = {
            "var(--xz-green)", "var(--xz-amber)",
            "#78aef0", "var(--xz-orange)" ,"var(--xz-red)","#4e79a7","#b07cf0","var(--xz-purple)", 
        };
  
    java.util.List stopList = null;
    java.util.Map stopFirstRow   = null;
    String maxName = "", maxHStr = "", maxPStr = "", finalSeg = "";
    double  maxP = 0.0, cum = 0.0, pVal = 0.0;
    StringBuilder seg = null;

    for (int g = 0; g < 2; g++) {
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
        <article class="xz-reason-card" style="margin-bottom:8px;">
            <div class="xz-bar-head"  style="font-weight: 850" >
                <span><%= stopTitles[g] %></span>
                <span style="color:var(--xz-green); font-weight:bold;">
                    <%= maxName %> <%= maxPStr %>%
                </span>
            </div>
            <div class="xz-donut-panel">
                <div class="xz-donut" style="--segments: <%= finalSeg %>">
                    <div class="xz-donut-label">
                        <span>最大</span>
                        <strong><%= maxHStr %></strong>
                    </div>
                </div>
                <div class="xz-reason-list">
                <%
                    if (stopList != null) {
                        for (int i = 0; i < Math.min(stopList.size(), 5); i++) {
                            java.util.Map row = (java.util.Map) stopList.get(i);
                            String name    = row.get("停機原因") != null ? row.get("停機原因").toString() : "";
                            java.math.BigDecimal hours = aaTool.getBigDecimal(row.get(stopTimeKeys[g]));
                            double percent = aaTool.getBigDecimal(row.get("佔比_百分比")).doubleValue();                       
                %>
                    <div class="xz-reason-row">
                    <hr>
                        <div class="xz-reason-name" style="--c:<%= colorPalette[i % colorPalette.length] %>">
                            <i></i><span><%= name %></span>
                        </div>
                        <div class="xz-reason-num">
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
    
	<section class="xz-section">
	      <div class="xz-section-title">
       		<h2>總庫存</h2>    
       		<small><%= showData.get("溪州總庫存") %></small>   
      	  </div>
			 <%
			 //溪州庫存種類
			  String[][] _inv = {
				{"大原料鋼捲","溪州大原料鋼捲","#9b59b6"},
				{"成品鋼板捲","溪州成品鋼板捲","#1abc9c"},
			    {"管料","溪州管料","#e74c3c"},
			    {"次級","溪州次級","#95a5a6"},
			    {"配管","溪州配管","#e67e22"},
			    {"構造管","溪州構造管","#3498db"},			   
			    {"扁鐵","溪州扁鐵","#2ecc71"},
			    {"角鐵","溪州角鐵","#f39c12"},
			    {"無縫管","溪州無縫管","#e91e63"},
			   
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
			
			<article class="xz-kpi-card" style="margin-top:8px;padding:14px 16px;">
			

			
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
				  <span style="flex:1;font-size:13px; font-weight:800;color:var(--xz-ink);"><%= _inv[_i][0] %></span>
				  <div style="text-align:right;">
				    <div style="font-size:15px;font-weight:800;color:var(--xz-ink);"><%= String.format("%,d",_rv) %></div>
				    <div style="font-size:11px;font-weight: 750;color:var(--xz-muted);"><%= String.format("%.1f",_pct) %>%</div>
				  </div>
				</div>
			<%
			    }
			%>
	    </article>
	</section>
	
  <section class="xz-section" id="xz-people">
      <div class="xz-section-title">
        <h2>人力與追蹤項目</h2>
        <small>現況管理</small>
      </div>
            <article class="xz-people-card" style="margin-top:8px">
        <div class="xz-people-row" style="border-top:none;"><span>全廠合計人力</span><b><%= showData.get("全廠總人數") %> 人</b></div>
        <div class="xz-people-row"><span>台籍 / 外籍總計</span><b><%= showData.get("台籍總人數") %> / <%= showData.get("外籍總人數") %></b></div>
        <div class="xz-people-row"><span>待手工矯直</span><b><%= showData.get("待手工筆數") %> 筆 / <%= aaTool.format(showData.get("待手工矯直"),"#,##0") %> 支</b></div>
        <div class="xz-people-row"><span>呆滯 &gt;180 天</span><b style="color:var(--xz-green)"><%= aaTool.format(showData.get("大於180天"),"#,##0") %> 筆</b></div>
      </article>
      <div class="xz-people-grid">
        <article class="xz-people-card">
          <p class="xz-label">廠務人力</p>
          <strong><%= showData.get("廠務總人數") %>人</strong>
          <p class="xz-sub">台籍 <%= showData.get("廠務台籍人數") %> / 外籍 <%= showData.get("廠務外籍人數") %></p>
        </article>
        <article class="xz-people-card">
          <p class="xz-label">生管成品人力</p>
          <strong style="color:var(--xz-teal)"><%= showData.get("生管成品總人數") %> 人</strong>
          <p class="xz-sub">台籍 <%= showData.get("生管成品台籍人數") %> / 外籍 <%= showData.get("生管成品外籍人數") %></p>
        </article>
      </div>
            <div class="xz-people-grid">
        <article class="xz-people-card">
          <p class="xz-label">製造課人力</p>
          <strong><%= showData.get("製造總人數") %>人</strong>
          <p class="xz-sub">台籍 <%= showData.get("製造台籍人數") %> / 外籍 <%= showData.get("製造外籍人數") %></p>
        </article>
        <article class="xz-people-card">
          <p class="xz-label">加工課人力</p>
          <strong style="color:var(--xz-teal)"><%= showData.get("加工總人數") %> 人</strong>
          <p class="xz-sub">台籍 <%= showData.get("加工台籍人數") %> / 外籍 <%= showData.get("加工外籍人數") %></p>
        </article>
      </div>
            <div class="xz-people-grid">
        <article class="xz-people-card">
          <p class="xz-label">設備課人力</p>
          <strong><%= showData.get("設備總人數") %>人</strong>
          <p class="xz-sub">台籍 <%= showData.get("設備台籍人數") %> / 外籍 <%= showData.get("設備外籍人數") %></p>
        </article>
        <article class="xz-people-card">
          <p class="xz-label">其他課人力</p>
          <strong style="color:var(--xz-teal)"><%= showData.get("其他總人數") %> 人</strong>
          <p class="xz-sub">台籍 <%= showData.get("其他台籍人數") %> / 外籍 <%= showData.get("其他外籍人數") %></p>
        </article>
      </div>

      	  

    </section>
  </div>
  
 
  
</div>

