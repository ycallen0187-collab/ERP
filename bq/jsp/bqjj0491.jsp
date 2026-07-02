<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="java.util.*" %>
<%
    Map dashboardData = (Map) request.getAttribute("dashboardData");
    Map xzData = (Map) (dashboardData != null ? dashboardData.get("xzData") : new HashMap());
    if (xzData == null) xzData = new HashMap();
    
    String mainYield = (String) xzData.get("MAIN_YIELD");
    if (mainYield == null) mainYield = "0.00";
    String avgQuality = (String) xzData.get("AVG_QUALITY");
    if (avgQuality == null) avgQuality = "0.00";

    // ── 【歷史趨勢數據動態轉化邏輯】 ──
    List trendMonths = (List) xzData.get("TREND_MONTHS");
    List trendYield = (List) xzData.get("TREND_YIELD_LIST");
    List trendQuality = (List) xzData.get("TREND_QUALITY_LIST");

    if (trendMonths == null) trendMonths = new ArrayList();
    if (trendYield == null) trendYield = new ArrayList();
    if (trendQuality == null) trendQuality = new ArrayList();
    // 【修改】擴增為 6 個 X 座標點，間距 56 (45, 101, 157, 213, 269, 325)
    int[] xCoords = {45, 101, 157, 213, 269, 325};

    StringBuilder pathYield = new StringBuilder();
    StringBuilder areaYield = new StringBuilder();   
    StringBuilder pathQuality = new StringBuilder();

    areaYield.append("M 45 140");
    // 【修改】迴圈上限從 4 改為 6
    for (int i = 0; i < 6; i++) {
        double yVal = (i < trendYield.size()) ? ((Double) trendYield.get(i)).doubleValue() : 80.0;
        double qVal = (i < trendQuality.size()) ? ((Double) trendQuality.get(i)).doubleValue() : 80.0;
        double yPos = 140.0 - ((yVal - 80.0) / 20.0) * 120.0;
        double qPos = 140.0 - ((qVal - 80.0) / 20.0) * 120.0;
        if (i == 0) {
            pathYield.append("M ").append(xCoords[i]).append(" ").append(yPos);
            pathQuality.append("M ").append(xCoords[i]).append(" ").append(qPos);
        } else {
            pathYield.append(" L ").append(xCoords[i]).append(" ").append(yPos);
            pathQuality.append(" L ").append(xCoords[i]).append(" ").append(qPos);
        }
        areaYield.append(" L ").append(xCoords[i]).append(" ").append(yPos);
    }
    areaYield.append(" L 325 140 Z");//【修改】陰影區域封閉點移至最後一個點的 X 座標 (325)

    double lastYieldY = 69.0;
    double lastQualityY = 105.0;
    // 【修改】判斷最後一個數據改為第 6 個點 (索引為 5)
    if (trendYield.size() >= 6) {
        double val = ((Double) trendYield.get(5)).doubleValue();
        lastYieldY = 140.0 - ((val - 80.0) / 20.0) * 120.0;
    }
    if (trendQuality.size() >= 6) {
        double val = ((Double) trendQuality.get(5)).doubleValue();
        lastQualityY = 140.0 - ((val - 80.0) / 20.0) * 120.0;
    }
%>
<%!
    // ── 【空值安全防護線：杜絕 null 髒字】 ──
    private String nvl(Object obj, String defaultStr) {
        if (obj == null) return defaultStr;
        String s = obj.toString().trim();
        return "null".equalsIgnoreCase(s) ? defaultStr : s;
    }
%>
<style>
  .tab-order-wrap { padding: 16px; font-family: 'Inter', 'Noto Sans TC', -apple-system, sans-serif; }
  
  /* 全域外部大標題：20px 搭配 900 極粗體 */
  .section-label { font-size: 20px !important; font-weight: 900 !important; color: #111827; margin: 24px 0 12px 4px; letter-spacing: 0.05em; }
  .section-label:first-child { margin-top: 12px; }

  .grid-card { background: #fff; border-radius: 16px; border: 1px solid #d1d1d6; overflow: hidden; margin-bottom: 16px; }
  .grid-row { display: grid; grid-template-columns: 1fr 1fr; }
  .grid-item { padding: 16px 10px; text-align: center; }
  .grid-item-border-right { border-right: 1px solid #d1d1d6; }
  .item-label { font-size: 14px; font-weight: 700; color: #666; }
  .item-val { font-size: 26px; font-weight: 900; line-height: 1.2; }
  
  /* 卡片基本外框 */
  .card { background-color: #ffffff; border-radius: 24px; padding: 22px; margin-bottom: 16px; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.03); border: 1px solid #e2e8f0; }
  
  /* 列表橫列排版 */
  .data-row { display: flex; justify-content: space-between; align-items: center; padding: 20px 4px; border-bottom: 1.5px solid #e2e8f0; }
  
  /* 白框內所有中文字欄位名稱：一律常規細字不加粗 */
  .data-label { font-size: 18px !important; color: #1e293b; font-weight: normal !important; }
  
  /* 【關鍵調整】右側容器全面切換為垂直堆疊 (Column)，靠右對齊 (flex-end) */
  .data-value-wrapper { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; }
  
  /* 右側關鍵指標數據：24px 極粗體 */
  .data-value { font-size: 24px !important; font-weight: 900 !important; text-align: right; font-family: 'Inter', sans-serif; line-height: 1.1; }
  
  /* 延伸數據庫小標題摺疊鈕：常規細字不加粗 */
  .accordion-header { background-color: #f8fafc; padding: 16px 18px; border-radius: 14px; font-size: 18px !important; font-weight: normal !important; color: #1e293b; margin-top: 22px; cursor: pointer; display: flex; justify-content: space-between; border: 1px solid #e2e8f0; user-select: none; }
  .accordion-content { display: none; padding: 10px 18px; background: #ffffff; border: 1px solid #e2e8f0; border-top: none; border-radius: 0 0 14px 14px; }
  
  /* 折疊展開選單內部的橫列排版 */
  .detail-row { display: flex; justify-content: space-between; align-items: center; padding: 16px 4px; border-bottom: 1.5px solid #e2e8f0; }
  .detail-row:last-child { border-bottom: none; }
  
  /* 【關鍵調整】展開選單內部的中文欄位名稱：一律常規細字不加粗 */
  .norm-title { font-size: 16px !important; color: #475569; font-weight: normal !important; }
  
  /* 展開選單內部的數據實績數字：18px 極粗體 */
  .norm-val { font-size: 18px !important; font-weight: 900 !important; font-family: 'Inter', sans-serif; line-height: 1.1; }
  
  /* 【關鍵調整】目標值標籤樣式：12px ~ 14px 灰色常規細字，緊貼在數字下方 */
  .data-target-lbl { font-size: 13px; color: #64748b; font-weight: normal !important; margin-top: 2px; text-align: right; }

  .text-red { color: #ef4444 !important; }
  .text-blue { color: #0066ff !important; }
  .text-green { color: #10b981 !important; }

  .svg-chart-container { width: 100%; margin-top: 15px; position: relative; }
  .trend-curve-yield { stroke: #0066ff; stroke-width: 4; stroke-linecap: round; fill: none; }
  .trend-curve-quality { stroke: #10b981; stroke-width: 4; stroke-linecap: round; fill: none; }
  .chart-grid-line { stroke: #e5e5ea; stroke-width: 1; stroke-dasharray: 2,2; }
  
  .data-trend { font-size: 13px; margin: 4px 0; align-items: center; gap: 2px;}

</style>

<div class="tab-order-wrap">
  
  <div class="section-label">品質綜合趨勢分析</div>
  <div class="grid-card" style="padding-bottom: 20px;">
    <div class="grid-row" style="border-bottom: 1px solid #e5e5ea;">
      <div class="grid-item grid-item-border-right">
        <div class="item-label">本月製造成材率</div>
        <div class="item-val text-blue" data-num="<%= mainYield %>" data-last='<%= nvl(xzData.get("LAST_MAIN_YIELD"), "0.00") %>'><%= mainYield %>%</div>
        <div class="data-trend">
          <span class="trend-arrow"></span>
          <span class="trend-text"></span>
        </div>
        <div class="data-target-lbl" data-limit="95.50"></div>
      </div>
      <div class="grid-item">
        <div class="item-label">本月製造良率</div>
        <div class="item-val text-green" data-num="<%= avgQuality %>" data-last='<%= nvl(xzData.get("LAST_AVG_QUALITY"), "0.00") %>'><%= avgQuality %>%</div>
        <div class="data-trend">
          <span class="trend-arrow"></span>
          <span class="trend-text"></span>
        </div>
      </div>
    </div>

    <div style="padding: 16px 16px 0;">
      <div style="display: flex; gap: 16px; margin-bottom: 12px; font-size: 11px; font-weight: 700;">
        <div style="display: flex; align-items: center; gap: 4px;"><span style="width: 12px; height: 6px; background-color: #0066ff; opacity: 0.3; border-radius: 2px;"></span>製造成材率 (提列改善 ≦95.50%)</div>
      </div>
      
      <div class="svg-chart-container">
        <svg id="trend-svg" viewBox="0 0 360 180" style="width: 100%; height: 180px; overflow: visible;">
            <line x1="20" y1="140" x2="340" y2="140" stroke="#c8c8cc" stroke-width="1"></line>
            <line x1="20" y1="80" x2="340" y2="80" class="chart-grid-line"></line>
            <line x1="20" y1="20" x2="340" y2="20" class="chart-grid-line"></line>

            <defs>
                <linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stop-color="#0066ff" stop-opacity="0.35"/>
                    <stop offset="100%" stop-color="#0066ff" stop-opacity="0.00"/>
                </linearGradient>
            </defs>

            <path d="<%= areaYield.toString() %>" fill="url(#areaGradient)"></path>

            <line x1="15" y1="41" x2="345" y2="41" stroke="#ff3b30" stroke-width="2" stroke-dasharray="4,3"></line>
            <text x="25" y="34" fill="#ff3b30" font-size="11" font-weight="900">成材提列改善 ≦95.50%</text>
            
            <path d="<%= pathYield.toString() %>" class="trend-curve-yield"></path>
            <path d="<%= pathQuality.toString() %>" class="trend-curve-quality"></path>
            
            <% for (int i = 0; i < trendMonths.size() && i < 6; i++) { %>
                <text x="<%= xCoords[i] %>" y="160" fill="#64748b" font-size="11" font-weight="900" text-anchor="middle"><%= trendMonths.get(i) %></text>
            <% } %>
            <%-- 最後一個點的 X 座標315改325 --%>
            <circle cx="325" cy="<%= lastYieldY %>" r="5" fill="#ffffff" stroke="#0066ff" stroke-width="3"></circle>
            <text x="325" y="<%= lastYieldY - 12 %>" fill="#0056b3" font-size="11" font-weight="900" text-anchor="middle"><%= mainYield %>%</text>

            <circle cx="325" cy="<%= lastQualityY %>" r="5" fill="#ffffff" stroke="#10b981" stroke-width="3"></circle>
            <text x="325" y="<%= lastQualityY + 16 %>" fill="#248a3d" font-size="11" font-weight="900" text-anchor="middle"><%= avgQuality %>%</text>
        </svg>
      </div>
    </div>
  </div>

  <div class="section-label">關鍵品質績效指標</div>
  <div class="card">
      <div class="data-row">
          <div class="data-label">Q型態</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("YIELD_Q"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_YIELD_Q"), "0.00") %>'><%= nvl(xzData.get("YIELD_Q"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
              <div class="data-target-lbl" data-limit="85">提列改善 ≦85%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">LASER製程</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("YIELD_LASER"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_YIELD_LASER"), "0.00") %>'><%= nvl(xzData.get("YIELD_LASER"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
              <div class="data-target-lbl" data-limit="91">提列改善 ≦91%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">大方 / 扁管</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("YIELD_SQUARE"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_YIELD_SQUARE"), "0.00") %>'><%= nvl(xzData.get("YIELD_SQUARE"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
              <div class="data-target-lbl" data-limit="90">提列改善 ≦90%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">其他鋼管</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("YIELD_OTHER"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_YIELD_OTHER"), "0.00") %>'><%= nvl(xzData.get("YIELD_OTHER"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
              <div class="data-target-lbl" data-limit="90">提列改善 ≦90%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">PYE型態符合率</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("PYE_5"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_PYE_5"), "0.00") %>'><%= nvl(xzData.get("PYE_5"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
              <div class="data-target-lbl" data-limit="98.30">提列改善 ≦98.30%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">非PYE型態符合率</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("NON_PYE_5"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_NON_PYE_5"), "0.00") %>'><%= nvl(xzData.get("NON_PYE_5"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
              <div class="data-target-lbl" data-limit="98.30">提列改善 ≦98.30%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">規範符合率</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("WELD_EDGE"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_WELD_EDGE"), "0.00") %>'><%= nvl(xzData.get("WELD_EDGE"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">外銷規範符合率</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(xzData.get("EXPORT_STRUCT"), "0.00") %>' data-last='<%= nvl(xzData.get("LAST_EXPORT_STRUCT"), "0.00") %>'><%= nvl(xzData.get("EXPORT_STRUCT"), "0.00") %>%</div>
              <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
          </div>
      </div>
      
  </div>

</div>

<script>
function toggleAccordion(id, headerEl) {
    var content = document.getElementById(id);
    if (!content) return;
    var arrow = headerEl.querySelector('span:last-child');
    if (content.style.display === "block") {
        content.style.display = "none"; 
        arrow.textContent = "▼";
    } else {
        content.style.display = "block"; 
        arrow.textContent = "▲";
    }
}
</script>