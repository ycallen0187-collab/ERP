<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.*" %>
<%@ page import="java.util.*" %> 
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%! public static final String _AppId = "BQJJ052"; %>
<%
	String sessionId = dejcWebUtil.genUniqueId(session.getId()) ;
	aajcYCATool aaTool = new aajcYCATool();
	String updateDate = new dejc308().getCrntDateWFmt1();
    if (updateDate == null) updateDate = "2026/04/08";
%>

<meta name="viewport" content="width=device-width, initial-scale=1.0">
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<title>設備戰情室</title>

<style>
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
  height: 32px;
  gap: 8px; /* 加上安全間距，確保選單、標題、日期之間有最小留白 */
}

.topbar-title { 
  font-size: 14px; 
  font-weight: 800; 
  color: #1c1c1e;
  white-space: nowrap; 
  flex: 1;            /* 讓標題自動拉伸佔滿中間剩餘空間 */
  text-align: center; /* 文字維持正中央對齊 */
  padding-left: 24px;
  /* 【關鍵補償】因為左邊有漢堡按鈕(約32px)，右邊有日期，*/
  /* 稍微補一點左內縮，字體就能在視覺上維持在正中央 */
  overflow: hidden;
  text-overflow: ellipsis; /* 萬一真的塞不下，尾設會變...，絕對不撐壞畫面 */
}

.topbar-date {
  font-size: 12px; 
  color: #444;
  background: #f2f2f7;
  border: 1px solid #c8c8cc;
  padding: 5px 12px;
  border-radius: 20px;
  z-index: 5;
  flex-shrink: 0;
  /* 【關鍵設定】強制日期絕對不准被壓縮或變形 */
}
body {
    margin: 0;
    background:#e5e7eb;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto;
}

/* 手機外框 */

/* ── 1. 基礎外框與導航列 ── */
.phone {
    max-width: 440px;
    height: 100vh;
    margin: auto;
    background: #F4F6F8;
    display: flex;
    flex-direction: column;
}
/* 標題 */
.header {
    padding: 20px 20px 5px 20px;
}
.header h1 {
    font-size: 26px;
    font-weight: 900;
    margin: 0;
}
.header small {
    color: #9ca3af;
    font-size: 13px;
}

/* TAB 容器 */
.tabs {
    display: flex;
    overflow-x: auto;
    gap: 10px;
    padding: 10px 15px 0 15px;
    scrollbar-width: none;
}
.tabs::-webkit-scrollbar {
    display: none;
}

/* TAB 按鈕 */
.tabs button {
    border: none;
    padding:10px 18px;
    border-radius:12px;
    background:#ffffff;
    color:#6b7280;
    cursor:pointer;
    white-space: nowrap;
    font-size: 15px;
    font-weight: bold;
    box-shadow:0 2px 5px rgba(0,0,0,0.08);
}

.tabs button.active {
    background:#3b82f6;
    color:#fff;
}

/* 滑動指示條 */
.scrollbar-track {
    width: calc(100% - 30px);
    height: 4px;
    background:#e5e7eb;
    margin: 6px auto 0;
    border-radius: 10px;
    position: relative;
}

.scrollbar-thumb {
    height: 100%;
    background:#3b82f6;
    border-radius: 10px;
    position: absolute;
    left: 0;
    width: 30%;
    transition: all 0.2s;
}

.content {
    flex:1;
    position: relative;
    min-height: 400px;  /* 很重要 */
}

iframe {
    width:100%;
    height:100%;
    border:none;
    display:block;
}

/* 動畫 */
.fade {
    animation:fadeIn 0.3s;
}
@keyframes fadeIn {
    from {opacity:0;}
    to {opacity:1;}
}
</style>

<script>
let tabsEl, thumbEl;

function updateScrollBar(){
    const scrollWidth = tabsEl.scrollWidth;
    const visibleWidth = tabsEl.clientWidth;
    const scrollLeft = tabsEl.scrollLeft;

    if(scrollWidth <= visibleWidth){
        thumbEl.style.width = "100%";
        thumbEl.style.left = "0";
        return;
    }

    const widthPercent = (visibleWidth / scrollWidth) * 100;
    const maxScrollLeft = scrollWidth - visibleWidth;
    const leftPercent = (scrollLeft / maxScrollLeft) * (100 - widthPercent);

    thumbEl.style.width = widthPercent + "%";
    thumbEl.style.left = leftPercent + "%";
}

function switchTab(page, btn) {

    const frame = document.getElementById("frame");

    // 不用 setTimeout
    frame.style.visibility = "hidden";

    frame.src = page;

    frame.onload = function () {
        frame.style.visibility = "visible";
    };

    document.querySelectorAll(".tabs button")
        .forEach(b => b.classList.remove("active"));

    btn.classList.add("active");
}

/* 初始化 */
window.onload = function(){
    tabsEl = document.querySelector(".tabs");
    thumbEl = document.querySelector(".scrollbar-thumb");

    tabsEl.addEventListener("scroll", updateScrollBar);
    window.addEventListener("resize", updateScrollBar);

    updateScrollBar();
};
</script>

<body>
<div class="phone">
	<div class="topbar">
	    <div class="topbar-row">
	      <jsp:include page="bqjjHamBtn.jsp">
		      <jsp:param name="hambGroup" value="IY18" />
		  </jsp:include>
	      <span class="topbar-title">設備總覽</span>
	      <span class="topbar-date"><%= aaTool.getCrntDateWFmt2(updateDate) %> 更新</span>
	    </div>
	    <div class="tabs">
	        <button class="active" onclick="switchTab('bqjj052_tabOV.jsp', this)">總覽</button>
	        <button onclick="switchTab('bqjj052_tabXZ.jsp', this)">溪州廠</button>
	        <button onclick="switchTab('bqjj052_tabDL1.jsp', this)">斗一廠</button>
	        <button onclick="switchTab('bqjj052_tabDL2.jsp', this)">斗二廠</button>
	        <button onclick="switchTab('bqjj052_tabPX.jsp', this)">埔心廠</button>
	    </div>
	</div>
    <!-- 滑動條 -->
    <div class="scrollbar-track">
        <div class="scrollbar-thumb"></div>
    </div>
    <!-- 內容 -->
    <div class="content">
        <iframe id="frame" src="bqjj052_tabOV.jsp"></iframe>
    </div>

</div>
</body>
 
<script>
</script>
<de:footer/>
<%@ include file="../../jsp/dzjjMainFooter.jsp" %>