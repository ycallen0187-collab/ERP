<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="java.util.*" %>
<%
    Map dashboardData = (Map) request.getAttribute("dashboardData");
    Map dl1Data = (Map) (dashboardData != null ? dashboardData.get("dl1Data") : new HashMap());
    if (dl1Data == null) dl1Data = new HashMap();
    System.out.println("d11Data==="+dl1Data.get("CR_SUB_RATE"));

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
  
  /* 統一所有大區塊外部標題 (20px / 900極粗體) */
  .section-label { font-size: 20px !important; font-weight: 900 !important; color: #111827; margin: 24px 0 12px 4px; letter-spacing: 0.05em; }
  .section-label:first-child { margin-top: 12px; }

  /* 圓角白瓷卡片外框 */
  .card { background-color: #ffffff; border-radius: 24px; padding: 22px; margin-bottom: 16px; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.03); border: 1px solid #e2e8f0; }
  .data-row { display: flex; justify-content: space-between; align-items: center; padding: 20px 4px; border-bottom: 1.5px solid #e2e8f0; }
  .data-row:last-child { border-bottom: none; }
  
  /* 白框內所有中文欄位名稱：一律常規細字，不用粗體 */
  .data-label { font-size: 18px !important; color: #1e293b; font-weight: normal !important; }
  
  /* 右側包裝容器：垂直堆疊 (Column)，靠右對齊 (flex-end) */
  .data-value-wrapper { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; }
  
  /* 右側數據實績：精確保留 24px 極粗體 */
  .data-value { font-size: 24px !important; font-weight: 900 !important; text-align: right; font-family: 'Inter', sans-serif; color: #1e293b; line-height: 1.1; }
  
  /* 目標值樣式優化：常規細字，緊貼置於大數值下方 */
  .data-target-lbl { font-size: 14px; color: #64748b; font-weight: normal !important; margin-top: 2px; text-align: right; }

  /* 高對比輔助色彩 */
  .text-red { color: #ef4444 !important; }
</style>

<div class="tab-order-wrap">
  
  <div class="section-label">關鍵品質績效指標</div>
  <div class="card">
      
      <div class="data-row">
          <div class="data-label">CR 切板次級率</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("CR_SUB_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_CR_SUB_RATE"), "0.00") %>'><%= nvl(dl1Data.get("CR_SUB_RATE"), "0.00") %>% </div>
                      <div class="data-trend">
                <span class="trend-arrow"></span>
                <span class="trend-text"></span>
              </div>
              <div class="data-target-lbl" data-limit="3.58">提列改善 ≧3.58%</div>
          </div>
      </div>
      
       <div class="data-row">
          <div class="data-label">CR 切板中料率</div>
          <div class="data-value-wrapper">
          	<div class="data-value text-red" data-num='<%= nvl(dl1Data.get("CR_MID_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_CR_MID_RATE"), "0.00") %>'><%= nvl(dl1Data.get("CR_MID_RATE"), "0.00") %>% </div>
          		<div class="data-trend">
                	<span class="trend-arrow"></span>
                	<span class="trend-text"></span>
          		</div>
          <div class="data-target-lbl" data-limit="0.68">提列改善 ≧0.68%</div>
          </div>
      </div>

      <div class="data-row">
          <div class="data-label">CR 分條中料率</div>
          <div class="data-value-wrapper">
           	  <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("CR_SLIT_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_CR_SLIT_RATE"), "0.00") %>'><%= nvl(dl1Data.get("CR_SLIT_RATE"), "0.00") %>% </div>
        	  <div class="data-trend">
                	<span class="trend-arrow"></span>
                	<span class="trend-text"></span>
          	  </div>
          <div class="data-target-lbl" data-limit="1.51">提列改善 ≧1.51%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">鏡面研磨次級率</div>
          <div class="data-value-wrapper">
           	  <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("GRIND_SUB_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_GRIND_SUB_RATE"), "0.00") %>'><%= nvl(dl1Data.get("GRIND_SUB_RATE"), "0.00") %>% </div>
              <div class="data-trend">
                	<span class="trend-arrow"></span>
                	<span class="trend-text"></span>
          	  </div>
          <div class="data-target-lbl" data-limit="1.75">提列改善 ≧1.75%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">停剪機2B次級率</div>
          <div class="data-value-wrapper">
               <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("CUT_SUB_2B_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_CUT_SUB_2B_RATE"), "0.00") %>'><%= nvl(dl1Data.get("CUT_SUB_2B_RATE"), "0.00") %>% </div>
               <div class="data-trend">
                	<span class="trend-arrow"></span>
                	<span class="trend-text"></span>
          	  </div>
          <div class="data-target-lbl" data-limit="7.0">提列改善 ≧7.0%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">停剪機2B中料率</div>
          <div class="data-value-wrapper">
              <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("CUT_MID_2B_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_CUT_MID_2B_RATE"), "0.00") %>'><%= nvl(dl1Data.get("CUT_MID_2B_RATE"), "0.00") %>% </div>
              <div class="data-trend">
                	<span class="trend-arrow"></span>
                	<span class="trend-text"></span>
          	  </div>
          <div class="data-target-lbl" data-limit="0.36">提列改善 ≧0.36%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">厚板NO1中料率</div>
          <div class="data-value-wrapper">
                 <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("CUT_MID_NO1_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_CUT_MID_NO1_RATE"), "0.00") %>'><%= nvl(dl1Data.get("CUT_MID_NO1_RATE"), "0.00") %>% </div>         
                       <div class="data-trend">
                	<span class="trend-arrow"></span>
                	<span class="trend-text"></span>
          	  </div>
          <div class="data-target-lbl" data-limit="2.44">提列改善 ≧2.44%</div>
          </div>
      </div>
      
      <div class="data-row">
          <div class="data-label">停機痕零片率</div>
          <div class="data-value-wrapper">
           <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("停機痕_RATE"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_停機痕_RATE"), "0.00") %>'><%= nvl(dl1Data.get("停機痕_RATE"), "0.00") %>% </div>         
       	   <div class="data-trend">
                	<span class="trend-arrow"></span>
                	<span class="trend-text"></span>
          	  </div>
          <div class="data-target-lbl" data-limit="65">提列改善 ≦65%</div>
          </div>
      </div>
      
 <div class="section-label">核心製程損耗明細</div>
  <div class="card">

      <div class="data-row">
          <div class="data-label">CR飛剪</div>
          <div class="data-value-wrapper">
             
           <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("CR_FLY_LOSS"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_CR_FLY_LOSS"), "0.00") %>'><%= nvl(dl1Data.get("CR_FLY_LOSS"), "0.00") %>% </div>         
       	   <div class="data-trend">
                	<span class="trend-arrow-y"></span>
                	<span class="trend-text-y"></span>
          	  </div>
          </div>
      </div>

      <div class="data-row">
          <div class="data-label">HR製程-2B</div>
          <div class="data-value-wrapper">
            <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("HR_2B_LOSS"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_HR_2B_LOSS"), "0.00") %>'><%= nvl(dl1Data.get("HR_2B_LOSS"), "0.00") %>% </div>         
    		<div class="data-trend">
                	<span class="trend-arrow-y"></span>
                	<span class="trend-text-y"></span>
          	</div>
            
          </div>
      </div>

      <div class="data-row">
          <div class="data-label">HR製程-No.1</div>
          <div class="data-value-wrapper">
            
          <div class="data-value text-red" data-num='<%= nvl(dl1Data.get("HR_NO1_LOSS"), "0.00") %>' data-last='<%= nvl(dl1Data.get("LAST_HR_NO1_LOSS"), "0.00") %>'><%= nvl(dl1Data.get("HR_NO1_LOSS"), "0.00") %>% </div>         
    	  <div class="data-trend">
                	<span class="trend-arrow-y"></span>
                	<span class="trend-text-y"></span>
          </div>
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
