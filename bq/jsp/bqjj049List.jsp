<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.bq.core.bqjc049" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ049"; 
%>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>

<%
    bqjc049 bq049 = new bqjc049(_dsCom);
    Map dashboardData = bq049.getDashboardData(_dsCom, request);
    aajcYCATool aaTool = new aajcYCATool();
    
    String updateDate = (String) dashboardData.get("updateDate");
    if (updateDate == null) updateDate = "2026/06/04";

    request.setAttribute("dashboardData", dashboardData);
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="cp950">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>營運總覽-品質監控</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&family=Noto+Sans+TC:wght@400;700;900&display=swap');

  * { 
    box-sizing: border-box;
    margin: 0; 
    padding: 0;
  }

  html {
    height: 100%;
    background: #e8e8ed; 
  }
  
  body {
    font-family: 'Inter', 'Noto Sans TC', -apple-system, sans-serif;
    background: #e8e8ed;
    display: flex;
    justify-content: center;
    padding: 16px 0;
    min-height: 100dvh;
    overflow-y: auto;
    -webkit-text-size-adjust: 100% !important;
    text-size-adjust: 100% !important;
  }

  .phone {
    width: 100%;
    max-width: 430px;
    margin: 0 auto;
    background: #f2f2f7;
    border-radius: 20px;
    overflow: hidden;
    border: 1px solid #c8c8cc;
    flex-shrink: 0;
    height: max-content;
    min-height: 700px;
    display: flex;
    flex-direction: column;
  }
  
  .topbar { 
    background: #fff; 
    border-bottom: 1px solid #d1d1d6;
    padding: 20px 16px 0; 
    position: relative;
  }

  .topbar-row { 
    display: flex;
    justify-content: space-between; 
    align-items: center;
    margin-bottom: 16px; 
    position: relative; 
    height: 36px;
    gap: 8px; 
  }

  .topbar-title { 
    font-size: 20px !important;
    font-weight: 900 !important; 
    color: #111827;
    white-space: nowrap; 
    flex: 1;            
    text-align: center;
    padding-left: 12px;
    overflow: hidden;
    text-overflow: ellipsis; 
  }

  .topbar-date {
    font-size: 13px !important; 
    font-weight: 700 !important;
    color: #64748b;
    background: #f1f5f9;
    border: 1px solid #e2e8f0;
    padding: 6px 14px;
    border-radius: 20px;
    z-index: 5;
    flex-shrink: 0; 
  }
  
  .tabs { 
    display: flex; 
    overflow-x: auto; 
    scrollbar-width: none; 
    -webkit-overflow-scrolling: touch;
  }
  
  .tabs::-webkit-scrollbar { 
    display: none;
  }
  
  .tab {
    flex: 1; 
    text-align: center; 
    font-size: 17px !important;
    padding: 14px 14px !important;
    color: #64748b;
    border-bottom: 4px solid transparent; 
    cursor: pointer;
    background: none; 
    border-top: none; 
    border-left: none; 
    border-right: none;
    font-family: inherit; 
    white-space: nowrap; 
    flex-shrink: 0;
    font-weight: 700;
  }
  
  .tab.active { 
    color: #0066ff !important; 
    border-bottom-color: #0066ff !important; 
    font-weight: 900 !important;
  }
  
  .tab-content { 
    flex: 1;
    overflow-y: auto;
    width: 100% !important;
    max-width: 100% !important;
    box-sizing: border-box !important;
  }

  /* 隱藏面板樣式 */
  .panel-pane {
    display: none;
    width: 100%;
  }
  .panel-pane.active {
    display: block;
  }

  @media (max-width: 450px) {
    html {
      background: #f2f2f7 !important;
    }
    body {
      background: #f2f2f7 !important;
      padding: 0 !important;
      margin: 0 !important;
    }
    .phone {
      border-radius: 0 !important;
      border: none !important;
      min-height: 100dvh !important;
      box-shadow: none !important;
    }
  }
</style>
</head>

<body>
<div class="phone">
  <div class="topbar">
    <div class="topbar-row">
	  <jsp:include page="bqjjHamBtn.jsp">
	      <jsp:param name="hambGroup" value="IY18" />
	  </jsp:include>
      <span class="topbar-title">品質監控</span>
      <span class="topbar-date"><%= aaTool.getCrntDateWFmt2(updateDate) %> 更新</span>
    </div>
    
    <div class="tabs">
      <button class="tab active" onclick="switchTab('XZ')">溪州廠</button>
      <button class="tab" onclick="switchTab('DL1')">斗一廠</button>
      <button class="tab" onclick="switchTab('DL2')">斗二廠</button>
    </div>
  </div>

  <div id="ajax-target-content" class="tab-content">
    <div id="pane-XZ" class="panel-pane active">
        <jsp:include page="bqjj0491.jsp" />
    </div>
    <div id="pane-DL1" class="panel-pane">
        <jsp:include page="bqjj0492.jsp" />
    </div>
    <div id="pane-DL2" class="panel-pane">
        <jsp:include page="bqjj0493.jsp" />
    </div>
  </div>
</div>

<script>
var currentTabIndex = 0;
var tabsList = ['XZ', 'DL1', 'DL2'];

/* 【修改區域】優化 switchTab：拋棄不穩定的 fetch 機制，改為純前端高流暢度隱藏切換 */
function switchTab(name) {
    // 1. 切換頁籤按鈕高亮狀態
    document.querySelectorAll('.tab').forEach(function(btn) {
        btn.classList.remove('active');
    });
    var targetBtn = document.querySelector('.tab[onclick="switchTab(\'' + name + '\')"]');
    if (targetBtn) {
        targetBtn.classList.add('active');
    }

    // 2. 切換廠區資料面板顯示/隱藏
    document.querySelectorAll('.panel-pane').forEach(function(pane) {
        pane.classList.remove('active');
    });
    var targetPane = document.getElementById('pane-' + name);
    if (targetPane) {
        targetPane.classList.add('active');
    }

    currentTabIndex = tabsList.indexOf(name);
}
/* 左右滑動切換頁面 ,先停用 因新版UI 從左往右滑會觸發返回上一頁功能
var touchstartX = 0;
var touchendX = 0;
var swipeZone = document.querySelector('.phone');
swipeZone.addEventListener('touchstart', function(e) { touchstartX = e.changedTouches[0].screenX; }, { passive: true });
swipeZone.addEventListener('touchend', function(e) { touchendX = e.changedTouches[0].screenX; handleSwipe(); }, { passive: true });

function handleSwipe() {
    var swipeThreshold = 50;
    if (touchendX < touchstartX - swipeThreshold) {
        if (currentTabIndex < tabsList.length - 1) switchTab(tabsList[currentTabIndex + 1]);
    }
    if (touchendX > touchstartX + swipeThreshold) {
        if (currentTabIndex > 0) switchTab(tabsList[currentTabIndex - 1]);
    }
}
*/
//判斷數值跟提列改善的大小，決定顏色是紅色還是藍色，以及上個月資料的顯示，寫在049.jsp，可以通用到0491~0493 include進來的子JSP
function checkAllRatios() {
	// 密技 1：用逗號隔開，同時抓取「data-value-wrapper外殼」與「grid-item外殼」
    var wrappers = document.querySelectorAll('.data-value-wrapper, .grid-item');
    wrappers.forEach(function(wrapper, index) {
    	// 密技 2：數值元件可能叫 .data-value 或 .item-val，同樣用逗號一次抓取
        var valDiv = wrapper.querySelector('.data-value, .item-val');
        var targetDiv = wrapper.querySelector('.data-target-lbl'); // 如果沒有，這會是 null
        var trendArrow = wrapper.querySelector('.trend-arrow');
        var trendText = wrapper.querySelector('.trend-text');
        
        //防呆第一步：只要有主要的當月數值 div 就可以開始跑
        if (valDiv) {
            var currentNum = parseFloat(valDiv.dataset.num);
            var lastNum = parseFloat(valDiv.dataset.last);
            // ----------------------------------------------------
            // 獨立邏輯 A：【判斷是否達標】（只有在「有目標欄位」時才執行）
            // ----------------------------------------------------
            if (targetDiv && !isNaN(currentNum)) {
                var limitNum = parseFloat(targetDiv.dataset.limit);
                if (!isNaN(limitNum)) {
                	// 改用 classList 增刪，安全不破壞原本的 class
                    if (currentNum > limitNum) {
                        valDiv.classList.remove("text-red");
                        valDiv.classList.add("text-blue");
                    } else {
                        valDiv.classList.remove("text-blue");
                        valDiv.classList.add("text-red");
                    }
                }
            }
            // ----------------------------------------------------
            // 獨立邏輯 B：【計算上月趨勢】（不論有沒有目標欄位，都會執行）
            // ----------------------------------------------------
            if (trendArrow && trendText && !isNaN(currentNum) && !isNaN(lastNum)) {
                // 使用上一回推薦的「兩位小數字串比較法」，安全又乾淨
                var diffStr = (currentNum - lastNum).toFixed(2); 
                if (diffStr === "0.00") {
                    trendArrow.textContent = "─";
                    trendArrow.style.color = "#9ca3af"; // 灰色
                    //trendText.textContent = "持平 (上月 " + lastNum.toFixed(2) + "%)";
                } else if (diffStr.indexOf("-") === 0) {
                    trendArrow.textContent = "▼";
                    trendArrow.style.color = "#ef4444"; // 紅色
                    //trendText.textContent = diffStr + "% (上月 " + lastNum.toFixed(2) + "%)";
                } else {
                    trendArrow.textContent = "▲";
                    trendArrow.style.color = "#0066ff"; // 藍色
                    //trendText.textContent = "+" + diffStr + "% (上月 " + lastNum.toFixed(2) + "%)";
                }
                trendText.textContent = "上月 " + lastNum.toFixed(2) + "%";
            }
        }
    });
}
// 網頁載入完成後自動執行
window.addEventListener('load', checkAllRatios);


//判斷數值跟提列改善的大小，決定顏色是紅色還是藍色，以及上個月資料的顯示，寫在049.jsp，可以通用到0491~0493 include進來的子JSP
function checkAllRatios_Year() {
	// 密技 1：用逗號隔開，同時抓取「data-value-wrapper外殼」與「grid-item外殼」
    var wrappers = document.querySelectorAll('.data-value-wrapper, .grid-item');
    wrappers.forEach(function(wrapper, index) {
    	// 密技 2：數值元件可能叫 .data-value 或 .item-val，同樣用逗號一次抓取
        var valDiv = wrapper.querySelector('.data-value, .item-val');
        var targetDiv = wrapper.querySelector('.data-target-lbl'); // 如果沒有，這會是 null
        var trendArrow = wrapper.querySelector('.trend-arrow-y');
        var trendText = wrapper.querySelector('.trend-text-y');
        
        //防呆第一步：只要有主要的當月數值 div 就可以開始跑
        if (valDiv) {
            var currentNum = parseFloat(valDiv.dataset.num);
            var lastNum = parseFloat(valDiv.dataset.last);
            // ----------------------------------------------------
            // 獨立邏輯 A：【判斷是否達標】（只有在「有目標欄位」時才執行）
            // ----------------------------------------------------
            if (targetDiv && !isNaN(currentNum)) {
                var limitNum = parseFloat(targetDiv.dataset.limit);
                if (!isNaN(limitNum)) {
                	// 改用 classList 增刪，安全不破壞原本的 class
                    if (currentNum > limitNum) {
                        valDiv.classList.remove("text-red");
                        valDiv.classList.add("text-blue");
                    } else {
                        valDiv.classList.remove("text-blue");
                        valDiv.classList.add("text-red");
                    }
                }
            }
            // ----------------------------------------------------
            // 獨立邏輯 B：【計算上月趨勢】（不論有沒有目標欄位，都會執行）
            // ----------------------------------------------------
            if (trendArrow && trendText && !isNaN(currentNum) && !isNaN(lastNum)) {
                // 使用上一回推薦的「兩位小數字串比較法」，安全又乾淨
                var diffStr = (currentNum - lastNum).toFixed(2); 
                if (diffStr === "0.00") {
                    trendArrow.textContent = "─";
                    trendArrow.style.color = "#9ca3af"; // 灰色
                    //trendText.textContent = "持平 (上月 " + lastNum.toFixed(2) + "%)";
                } else if (diffStr.indexOf("-") === 0) {
                    trendArrow.textContent = "▼";
                    trendArrow.style.color = "#ef4444"; // 紅色
                    //trendText.textContent = diffStr + "% (上月 " + lastNum.toFixed(2) + "%)";
                } else {
                    trendArrow.textContent = "▲";
                    trendArrow.style.color = "#0066ff"; // 藍色
                    //trendText.textContent = "+" + diffStr + "% (上月 " + lastNum.toFixed(2) + "%)";
                }
                trendText.textContent = "去年 " + lastNum.toFixed(2) + "%";
            }
        }
    });
}
// 網頁載入完成後自動執行
window.addEventListener('load', checkAllRatios_Year);
</script>
</body>
</html>