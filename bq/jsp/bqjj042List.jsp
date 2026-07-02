<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.bq.core.bqjc042" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ042"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>

<%
    // 取得資料
    bqjc042 bq042 = new bqjc042(_dsCom);
    Map dashboardData = bq042.getDashboardData(_dsCom, request);
    aajcYCATool aaTool = new aajcYCATool();
    String updateDate = (String) dashboardData.get("updateDate");
    if (updateDate == null) updateDate = "2026/04/08";

    // 將資料放入 request attribute，讓被 include 的子網頁可以讀取
    request.setAttribute("dashboardData", dashboardData);
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="cp950">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>營運總覽</title>
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
    /* 電腦版最底層背景色 */
  }
  
  body {
    font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
    background: #e8e8ed;
    display: flex;
    justify-content: center;
    padding: 16px 0;
    min-height: 100dvh;
    overflow-y: auto;
    /* ── 【關鍵修改】強行鎖定字體，禁止手機系統放大 ── */
    -webkit-text-size-adjust: 100% !important;
    /* 鎖定 iOS Safari / WebView 字體率 */
    -moz-text-size-adjust: 100% !important;
    /* 鎖定 Firefox */
    -ms-text-size-adjust: 100% !important;     /* 鎖定 IE/Edge */
    text-size-adjust: 100% !important;         /* 標準屬性 */
  }

  /* ── 1. 基礎外框與導航列 ── */
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
    font-size: 16px;
    padding: 12px 14px;
    color: #555;
    border-bottom: 4px solid transparent; 
    cursor: pointer;
    background: none; 
    border-top: none; 
    border-left: none; 
    border-right: none;
    font-family: inherit; 
    white-space: nowrap; 
    flex-shrink: 0;
    font-weight: normal;
  }
  
  .tab.active { 
    color: #007aff; 
    border-bottom-color: #007aff; 
    font-weight: 800; 
  }
  
  .tab-content { 
    display: none; 
    padding: 16px;
    animation: fadeIn 0.25s ease-out; 
  }
  
  .tab-content.active { 
    display: block; 
  }
  
  .section-label { 
    font-size: 15px; 
    font-weight: 800; 
    color: #333;
    letter-spacing: 0.06em; 
    margin: 20px 0 12px; 
  }
  
  .section-label:first-child { 
    margin-top: 4px;
  }

  /* ── 2. 接單庫存分頁專用 CSS (包含展開收合) ── */
  .grid-card { 
    background: #fff; 
    border-radius: 24px;
    border: 1px solid #d1d1d6; 
    overflow: hidden; 
    margin-bottom: 16px; 
  }
  
  .grid-row { 
    display: grid; 
    grid-template-columns: 1fr 1fr;
  }
  
  .grid-item { 
    padding: 20px 10px; 
    text-align: center; 
  }
  
  .grid-item-border-right { 
    border-right: 1px solid #d1d1d6;
  }
  
  .grid-item-border-bottom { 
    border-bottom: 1px solid #d1d1d6; 
  }
  
  .item-label { 
    font-size: 16px; 
    color: #666; 
    margin-bottom: 8px;
    font-weight: 400; 
  }
  
  .item-val { 
    font-size: 30px; 
    font-weight: 900; 
    color: #000; 
    line-height: 1.2; 
  }
  
  .item-unit { 
    font-size: 14px;
    color: #666; 
    margin-left: 2px; 
    font-weight: 500; 
  }

  .detail-group { 
    padding: 16px; 
    border-top: 1px solid #d1d1d6;
  }
  
  .detail-group-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: baseline; 
    margin-bottom: 10px; 
    gap: 8px; 
  }
  
  .detail-title { 
    font-size: 15px;
    font-weight: 800; 
    color: #333; 
  }
  
  .detail-title span { 
    font-size: 12px; 
    font-weight: 500; 
    color: #888; 
    margin-left: 4px;
  }
  
  .detail-total { 
    font-size: 18px; 
    font-weight: 900; 
    color: #d32f2f; 
  }
  
  .detail-total span { 
    font-size: 13px; 
    font-weight: 500;
    color: #666; 
    margin-left: 2px; 
  }
  
  .col-left { 
    flex: 1; 
    text-align: left; 
  }
  
  .col-right { 
    flex: 1;
    text-align: right; 
  }
  
  .detail-grid { 
    display: grid; 
    grid-template-columns: 1fr; 
    gap: 6px; 
    font-size: 13px; 
    color: #555;
  }
  
  .detail-row { 
    display: flex; 
    justify-content: space-between; 
    align-items: baseline; 
    gap: 8px; 
  }
  
  .detail-row-val { 
    font-weight: 800; 
    color: #222;
  }

  .toggle-header { 
    cursor: pointer; 
    user-select: none; 
    transition: background-color 0.2s; 
  }
  
  .toggle-header:active { 
    background-color: #ffeaea !important;
  }
  
  .toggle-header-blue:active { 
    background-color: #e6f0fa !important; 
  }
  
  .toggle-header-gray:active { 
    background-color: #f2f2f2 !important;
  }
  
  .toggle-icon { 
    transition: transform 0.3s ease; 
    margin-right: 8px; 
    vertical-align: middle; 
  }
  
  .details-content { 
    max-height: 0; 
    opacity: 0;
    overflow: hidden; 
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); 
  }
  
  .details-content.expanded { 
    max-height: 1200px; 
    opacity: 1;
  }
  
  .dual-header-container { 
    display: flex; 
    flex-direction: column; 
    width: 100%; 
  }
  
  .dual-header-main { 
    display: flex; 
    justify-content: space-between; 
    align-items: center;
    margin-bottom: 8px; 
  }
  
  .dual-header-vals { 
    display: flex; 
    justify-content: space-around; 
    width: 100%; 
    border-top: 1px solid rgba(0,0,0,0.05); 
    padding-top: 12px;
  }
  
  .dual-val-box { 
    text-align: center; 
    flex: 1; 
  }
  
  .dual-val-box:first-child { 
    border-right: 1px solid rgba(0,0,0,0.1);
  }

  /* ── 3. 其他分頁 (生產、各廠、品保、生管) 共用樣式 ── */
  .card { 
    background: #fff; 
    border-radius: 24px;
    border: 1px solid #d1d1d6; 
    overflow: hidden; 
    margin-bottom: 16px; 
  }
  
  .card-body { 
    padding: 16px; 
  }
  
  .card-row-2 { 
    display: grid;
    grid-template-columns: 1fr 1fr; 
    gap: 12px; 
    padding: 16px; 
  }
  
  .card-row-3 { 
    display: grid; 
    grid-template-columns: repeat(3, 1fr); 
    gap: 8px; 
    padding: 16px;
  }
  
  .card-row-4 { 
    display: grid; 
    grid-template-columns: repeat(4, 1fr); 
    gap: 6px; 
    padding: 16px; 
  }
  
  .card-row-split { 
    display: grid;
    grid-template-columns: 1fr 1fr; 
    gap: 12px; 
    padding: 16px; 
  }
  
  .metric-label { 
    font-size: 14px; 
    font-weight: 700; 
    color: #666;
    margin-bottom: 4px; 
  }
  
  .big-num { 
    display: flex; 
    align-items: baseline; 
  }
  
  .metric-val { 
    font-size: 28px; 
    font-weight: 900; 
    color: #111;
    line-height: 1; 
  }
  
  .metric-val.md { 
    font-size: 24px; 
  }
  
  .metric-val.lg { 
    font-size: 32px;
  }
  
  .pill { 
    display: inline-flex; 
    align-items: center; 
    padding: 3px 8px; 
    border-radius: 12px; 
    font-size: 12px; 
    font-weight: 700;
  }
  
  .pill-amber { 
    background: #fff8ec; 
    color: #ff9500; 
  }
  
  .pill-green { 
    background: #e8f9ee; 
    color: #34c759;
  }
  
  .pill-red { 
    background: #ffeaea; 
    color: #ff3b30; 
  }
  
  .dot-icon { 
    display: inline-block; 
    width: 6px; 
    height: 6px;
    border-radius: 50%; 
    margin-right: 4px; 
  }
  
  .dot-amber { 
    background: #ff9500; 
  }
  
  .dot-green { 
    background: #34c759;
  }
  
  .dot-red { 
    background: #ff3b30; 
  }
  
  .card-div-bg { 
    background: #f9f9fb; 
    border-top: 1px solid #d1d1d6;
  }
  
  .card-div { 
    border-top: 1px solid #d1d1d6; 
  }
  
  .stat-cell { 
    text-align: center;
  }
  
  .stat-label { 
    font-size: 13px; 
    font-weight: 700; 
    color: #666; 
    margin-bottom: 4px; 
  }
  
  .stat-val { 
    font-size: 20px; 
    font-weight: 900;
  }
  
  .bar-row { 
    display: flex; 
    align-items: center; 
    padding: 8px 16px; 
    border-top: 1px solid #f2f2f7;
  }
  
  .bar-row:first-child { 
    border-top: none; 
  }
  
  .bar-name { 
    font-size: 14px; 
    font-weight: 700; 
    color: #333; 
    width: 55px; 
    flex-shrink: 0;
  }
  
  .bar-name.w48 { 
    width: 48px; 
  }
  
  .bar-name.w72 { 
    width: 85px; 
  }
  
  .bar-track { 
    flex: 1; 
    height: 8px;
    background: #e5e5ea; 
    border-radius: 4px; 
    margin: 0 12px; 
    overflow: hidden; 
  }
  
  .bar-fill { 
    height: 100%; 
    border-radius: 4px;
  }
  
  .bar-val { 
    font-size: 14px; 
    font-weight: 900; 
    width: 60px; 
    text-align: right; 
  }
  
  .list-row { 
    display: flex;
    justify-content: space-between; 
    align-items: center; 
    padding: 14px 16px; 
    border-bottom: 1px solid #d1d1d6; 
  }
  
  .list-row:last-child { 
    border-bottom: none;
  }
  
  .list-main { 
    font-size: 16px; 
    font-weight: 900; 
    color: #333; 
    margin-bottom: 4px; 
  }
  
  .list-sub { 
    font-size: 13px; 
    color: #666;
    font-weight: 700; 
  }
  
  .badge { 
    padding: 4px 8px; 
    border-radius: 6px; 
    font-size: 13px; 
    font-weight: 900; 
    display: inline-block;
  }
  
  .badge-red { 
    background: #ffeaea; 
    color: #ff3b30; 
  }
  
  .badge-amber { 
    background: #fff8ec; 
    color: #ff9500;
  }
  
  .badge-green { 
    background: #e8f9ee; 
    color: #34c759; 
  }
  
  .badge-gray { 
    background: #f2f2f7; 
    color: #666;
  }
  
  .prog-section { 
    padding: 16px; 
  }
  
  .prog-header { 
    display: flex; 
    justify-content: space-between; 
    font-size: 13px; 
    font-weight: 700;
    color: #333; 
    margin-bottom: 6px; 
  }
  
  .prog-track { 
    height: 8px; 
    background: #e5e5ea; 
    border-radius: 4px; 
    overflow: hidden;
  }
  
  .prog-fill { 
    height: 100%; 
    border-radius: 4px; 
  }
  
  .idx { 
    font-size: 11px; 
    color: #8e8e93; 
    font-weight: 700;
    margin-left: 6px; 
  }
  
  .red { color: #d32f2f; }
  .amber { color: #ff9500; }
  .green { color: #248a3d; }
  .blue { color: #0056b3; }
  .gray { color: #8e8e93; }

  /* ── 【接單庫存子頁 (.tab-order-wrap) 全域統一樣式集】 ── */
  .text-amber { 
    color: #ff9500;
  }
  
  .tab-order-wrap * { 
    box-sizing: border-box; 
  }
  
  .tab-order-wrap .section-label { 
    font-size: 15px; 
    font-weight: 900; 
    color: #333; 
    letter-spacing: 0.05em;
    margin: 20px 0 12px; 
    font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif; 
  }
  
  .tab-order-wrap .grid-card { 
    background: #fff; 
    border-radius: 20px;
    border: 1px solid #d1d1d6; 
    overflow: hidden; 
    margin-bottom: 16px; 
    font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
  }
  
  .tab-order-wrap .grid-row { 
    display: grid; 
    grid-template-columns: 1fr 1fr; 
  }
  
  .tab-order-wrap .grid-item { 
    padding: 20px 10px; 
    text-align: center;
  }
  
  .tab-order-wrap .grid-item-border-right { 
    border-right: 1px solid #d1d1d6; 
  }
  
  .tab-order-wrap .grid-item-border-bottom { 
    border-bottom: 1px solid #d1d1d6;
  }
  
  .tab-order-wrap .item-label { 
    font-size: 14px; 
    font-weight: 700; 
    color: #666; 
    margin-bottom: 4px;
  }
  
  .tab-order-wrap .item-val { 
    font-size: 26px; 
    font-weight: 900; 
    line-height: 1.2; 
  }
  
  .tab-order-wrap .item-unit { 
    font-size: 14px; 
    margin-left: 2px;
    font-weight: 700; 
  }
  
  .tab-order-wrap .detail-group { 
    padding: 16px; 
    border-top: 1px solid #d1d1d6;
  }
  
  .tab-order-wrap .detail-group-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: baseline; 
    margin-bottom: 10px; 
    gap: 8px;
  }
  
  .tab-order-wrap .detail-title { 
    font-size: 15px; 
    font-weight: 900; 
  }
  
  .tab-order-wrap .detail-title span { 
    font-size: 12px; 
    font-weight: 700;
    margin-left: 4px; 
  }
  
  .tab-order-wrap .col-left { 
    flex: 1; 
    text-align: left; 
  }
  
  .tab-order-wrap .col-right { 
    flex: 1;
    text-align: right; 
  }
  
  .tab-order-wrap .detail-grid { 
    display: grid; 
    grid-template-columns: 1fr; 
    gap: 6px; 
    font-size: 14px; 
    color: #555;
  }
  
  .tab-order-wrap .detail-row { 
    display: flex; 
    justify-content: space-between; 
    align-items: baseline; 
    gap: 8px; 
  }
  
  .tab-order-wrap .detail-row-val { 
    font-weight: 900;
  }
  
  .tab-order-wrap .toggle-header { 
    cursor: pointer; 
    user-select: none; 
    transition: background-color 0.2s;
  }
  
  .tab-order-wrap .toggle-header:active { 
    background-color: #f2f2f2 !important; 
  }
  
  .tab-order-wrap .toggle-header-blue:active { 
    background-color: #e6f0fa !important;
  }
  
  .tab-order-wrap .toggle-icon { 
    transition: transform 0.3s ease; 
    margin-right: 8px; 
    vertical-align: middle;
  }
  
  .tab-order-wrap .details-content { 
    max-height: 0; 
    opacity: 0; 
    overflow: hidden; 
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .tab-order-wrap .details-content.expanded { 
    max-height: 1500px; 
    opacity: 1; 
  }
  
  .tab-order-wrap .dual-header-container { 
    display: flex; 
    flex-direction: column;
    width: 100%; 
  }
  
  .tab-order-wrap .dual-header-main { 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    margin-bottom: 8px;
  }
  
  .tab-order-wrap .dual-header-vals { 
    display: flex; 
    justify-content: space-around; 
    width: 100%; 
    border-top: 1px solid rgba(0,0,0,0.05); 
    padding-top: 12px;
  }
  
  .tab-order-wrap .dual-val-box { 
    text-align: center; 
    flex: 1; 
  }
  
  .tab-order-wrap .dual-val-box:first-child { 
    border-right: 1px solid rgba(0,0,0,0.1);
  }
  
  .tab-order-wrap .text-red { color: #d32f2f; }
  .tab-order-wrap .text-green { color: #248a3d; }
  .tab-order-wrap .text-blue { color: #0056b3; }

  /* 老花眼專用高對比四格 Grid 數據表樣式 */
  .tab-order-wrap .target-table { 
    display: flex;
    flex-direction: column; 
    padding: 6px 0; 
  }
  
  .tab-order-wrap .target-row { 
    display: grid; 
    grid-template-columns: 1.1fr 1fr 1fr 1.1fr; 
    align-items: center;
    padding: 12px 14px; 
    border-top: 1px solid #e5e5ea; 
    text-align: center; 
  }
  
  .tab-order-wrap .target-row.th { 
    border-top: none; 
    background: #e5e5ea; 
    font-weight: 900;
    color: #1c1c1e; 
    padding: 8px 14px; 
    font-size: 14px; 
  }
  
  .tab-order-wrap .target-cell-name { 
    font-size: 15px; 
    font-weight: 900; 
    color: #1c1c1e; 
    text-align: left;
  }
  
  .tab-order-wrap .target-cell-val { 
    font-size: 16px; 
    font-weight: 900; 
    color: #000; 
  }
  
  .tab-order-wrap .target-cell-target { 
    font-size: 15px; 
    font-weight: 900;
    color: #0056b3; 
    background: #eef7ff; 
    padding: 4px 0; 
    border-radius: 6px; 
  }
  
  .tab-order-wrap .target-cell-rate { 
    font-size: 16px; 
    font-weight: 900; 
    text-align: right;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateX(10px); }
    to { opacity: 1; transform: translateX(0); }
  }

  /* ── 【各廠狀況分頁專用樣式修正：覆蓋全域排版，精準呈現實心框線與外觀】 ── */
  .card[class*="theme-"] { 
    border-radius: 12px !important;
  }
  
  .card[class*="theme-"] .factory-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    padding: 11px 14px; 
    border-bottom: 1px solid #d1d1d6;
  }
  
  .card[class*="theme-"] .factory-name { 
    font-size: 14px; 
    font-weight: 600; 
    color: #1c1c1e;
  }
  
  /* 移除全域 card-row 的 gap 與內縮，改為實心線分欄排版 */
  .card[class*="theme-"] .card-row-3 { 
    display: grid;
    grid-template-columns: 1fr 1fr 1fr; 
    gap: 0; 
    padding: 0; 
  }
  
  .card[class*="theme-"] .card-row-3 > * { 
    padding: 10px 8px; 
    text-align: center;
    border-right: 1px solid #d1d1d6; 
  }
  
  .card[class*="theme-"] .card-row-3 > *:last-child { 
    border-right: none;
  }
  
  .card[class*="theme-"] .card-row-split { 
    display: grid; 
    grid-template-columns: 1fr 1fr; 
    gap: 0; 
    padding: 0;
  }
  
  .card[class*="theme-"] .card-row-split > * { 
    padding: 12px 14px; 
    text-align: center; 
    border-right: 1px solid #d1d1d6;
  }
  
  .card[class*="theme-"] .card-row-split > *:last-child { 
    border-right: none; 
  }
  
  /* 底色區塊修正 */
  .card[class*="theme-"] .card-divider-bg { 
    border-top: 1px solid #d1d1d6;
    background: #f9f9fb; 
  }
  
  /* 狀態徽章美化修正 */
  .card[class*="theme-"] .badge { 
    font-size: 11px; 
    padding: 2px 9px; 
    border-radius: 20px;
    font-weight: 500; 
    display: inline-block; 
  }
  
  .card[class*="theme-"] .badge-green { 
    background: #e8f9ee; 
    color: #1a7a38; 
    border: 1px solid #a3d9b1;
  }
  
  .card[class*="theme-"] .badge-red { 
    background: #fff0ef; 
    color: #c0392b; 
    border: 1px solid #f5b7b1;
  }
  
  .card[class*="theme-"] .badge-amber { 
    background: #fff8ec; 
    color: #a0600a; 
    border: 1px solid #f5d28a;
  }
  
  /* 數據文字微調 */
  .card[class*="theme-"] .stat-label { 
    font-size: 11px; 
    color: #555555; 
    margin-bottom: 3px; 
    font-weight: 500;
  }
  
  .card[class*="theme-"] .stat-val { 
    font-size: 14px; 
    font-weight: 600; 
    color: #1c1c1e;
  }
  
  /* 補足並修正進度條樣式 */
  .card[class*="theme-"] .progress-section { 
    padding: 10px 14px;
  }
  
  .card[class*="theme-"] .progress-header { 
    display: flex; 
    justify-content: space-between; 
    font-size: 11px; 
    color: #8e8e93; 
    margin-bottom: 6px;
  }
  
  .card[class*="theme-"] .progress-track { 
    height: 6px; 
    background: #e5e5ea; 
    border-radius: 3px; 
    overflow: hidden; 
  }
  
  .card[class*="theme-"] .progress-fill { 
    height: 100%;
    border-radius: 3px; 
    transition: width 0.3s ease; 
  }

  /* ── 【終極修正：手機版全螢幕滿版 & 拔除底部白色區塊】 ── */
  @media (max-width: 450px) {
    html {
      background: #f2f2f7 !important;
      /* 強制網頁最底層與手機框背景一致，消除白色底框 */
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
    .tab-content {
      padding-bottom: calc(env(safe-area-inset-bottom) + 20px) !important;
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
      <span class="topbar-title">營運總覽</span>
      <span class="topbar-date"><%= aaTool.getCrntDateWFmt2(updateDate) %> 更新</span>
    </div>
    <div class="tabs">
      <button class="tab active" onclick="switchTab('order')">接單/庫存</button>
	  <button class="tab" onclick="switchTab('DL2')">斗二</button>
      <button class="tab" onclick="switchTab('XZ')">溪州</button>
      <button class="tab" onclick="switchTab('DL1')">斗一</button>
      <button class="tab" onclick="switchTab('factory')">各廠狀況</button>
    </div>
  </div>

  <div id="tab-order" class="tab-content active">
    <jsp:include page="bqjj042_tabOrder.jsp" />
  </div>
  <div id="tab-DL2" class="tab-content"></div>
  <div id="tab-XZ" class="tab-content"></div>
  <div id="tab-DL1" class="tab-content"></div>
  <div id="tab-factory" class="tab-content"></div>
  <div id="tab-manufacture" class="tab-content"></div>
  <div id="tab-pp" class="tab-content"></div>
  <div id="tab-qa" class="tab-content"></div>
</div>

<script>
/* 【修正 2】將 tabsList 陣列順序調整與 HTML 上的 Button 標籤完全一致 */
const tabsList = ['order','DL2', 'XZ', 'DL1', 'factory'];
let currentTabIndex = 0;

async function switchTab(name) {
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.tab').forEach(btn => btn.classList.remove('active'));
  const targetTabContent = document.getElementById('tab-' + name);
  
  if (targetTabContent.innerHTML.trim() === '') {
    try {
      let targetUrl = '';
      if (name === 'factory') targetUrl = '/erp/bq/jsp/bqjj042_tabFactory.jsp?updateDate=<%= updateDate %>';
      else if (name === 'manufacture') targetUrl = '/erp/bq/jsp/bqjj042_tabManufacture.jsp?updateDate=<%= updateDate %>';
      else if (name === 'pp') targetUrl = '/erp/bq/jsp/bqjj042_tabPP.jsp?updateDate=<%= updateDate %>';
      else if (name === 'qa') targetUrl = '/erp/bq/jsp/bqjj042_tabQ.jsp?updateDate=<%= updateDate %>';
      else if (name === 'XZ') targetUrl = '/erp/bq/jsp/bqjj042_tabXZ.jsp?updateDate=<%= updateDate %>';
      else if (name === 'DL1') targetUrl = '/erp/bq/jsp/bqjj042_tabDL1.jsp?updateDate=<%= updateDate %>';
	  else if (name === 'DL2') targetUrl = '/erp/bq/jsp/bqjj042_tabDL2.jsp?updateDate=<%= updateDate %>';
	  else if (name === 'DL2') targetUrl = '/erp/bq/jsp/bqjj042_tabDL2.jsp?updateDate=<%= updateDate %>';
      else if (name === 'orderTR') targetUrl = '/erp/bq/jsp/bqjj042_tabOrderTR.jsp?updateDate=<%= updateDate %>';
      
      if (targetUrl !== '') {
        const response = await fetch(targetUrl);
        if (!response.ok) throw new Error('Network response was not ok');
        
        const buffer = await response.arrayBuffer();
        const decoder = new TextDecoder('big5');
        const htmlText = decoder.decode(buffer);
        
        const parser = new DOMParser();
        const doc = parser.parseFromString(htmlText, 'text/html');
        const extractedContent = doc.querySelector('#ajax-target-content');
        if (extractedContent) {
          targetTabContent.innerHTML = extractedContent.innerHTML;
        } else {
          targetTabContent.innerHTML = '<div style="text-align:center; padding: 30px; color:#ff3b30;">載入異常</div>';
        }
      }
    } catch (error) {
      console.error('Fetch error:', error);
      targetTabContent.innerHTML = '<div style="text-align:center; padding: 30px; color:#ff3b30;">載入失敗</div>';
    }
  }

  targetTabContent.classList.add('active');
  const targetBtn = document.querySelector(`.tab[onclick="switchTab('${name}')"]`);
  if (targetBtn) {
    targetBtn.classList.add('active');
    targetBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
  }
  currentTabIndex = tabsList.indexOf(name);
}

function toggleDetails(contentId, iconId) {
  const content = document.getElementById(contentId);
  const icon = document.getElementById(iconId);
  if (content.classList.contains('expanded')) {
    content.classList.remove('expanded');
    icon.style.transform = 'rotate(0deg)';
  } else {
    content.classList.add('expanded');
    icon.style.transform = 'rotate(180deg)';
  }
}
/* 左右滑動切換頁面 ,先停用 因新版UI 從左往右滑會觸發返回上一頁功能
let touchstartX = 0;
let touchendX = 0;
const swipeZone = document.querySelector('.phone');
swipeZone.addEventListener('touchstart', function(e) { touchstartX = e.changedTouches[0].screenX; }, { passive: true });
swipeZone.addEventListener('touchend', function(e) { touchendX = e.changedTouches[0].screenX; handleSwipe(); }, { passive: true });

function handleSwipe() {
  const swipeThreshold = 50;
  if (touchendX < touchstartX - swipeThreshold) {
    if (currentTabIndex < tabsList.length - 1) switchTab(tabsList[currentTabIndex + 1]);
  }
  if (touchendX > touchstartX + swipeThreshold) {
    if (currentTabIndex > 0) switchTab(tabsList[currentTabIndex - 1]);
  }
}
*/

function showHumanData(element) {
    var panel = document.getElementById('shared-human-panel');
    var titleEl = document.getElementById('human-panel-title');

    // 收合
    if (panel.classList.contains('panel-open') && titleEl.innerText === element.getAttribute('data-name') + " 人力結構現況") {
        panel.classList.remove('panel-open');
        element.classList.remove('active-human-click');
        return;
    }

    // 清除其他高亮
    var allHeaders = element.parentNode.querySelectorAll('.factory-header');
    for (var i = 0; i < allHeaders.length; i++) {
        allHeaders[i].classList.remove('active-human-click');
    }

    titleEl.innerText = element.getAttribute('data-name') ;
    document.getElementById('txt-total').innerText = Number(element.getAttribute('data-total')).toLocaleString();

    // 分類中文對照表
   // 定義順序 + 中文對照
		var factoryName = element.getAttribute('data-name');

	// 各廠指定顯示的分類
	var labelOrder;
	
	if (factoryName === '總公司') {
	    // 總公司：不顯示其他
	    labelOrder = [
	        { key: 'mb',    label: '廠務'    },
	        { key: 'e',     label: '生管成品' },
	        { key: 'm',     label: '製造'    },
	        { key: 'p',     label: '加工'    },
	        { key: 'prod',  label: '生產'    },
	        { key: 'm41',   label: '設備'    },
	        { key: 'ee',    label: '生管'    },
	        { key: 'sa',    label: '安衛'    },
	        { key: 'of',    label: '行政'    },
	        { key: 'wa',    label: '保修'    },
	        { key: 'q',     label: '品保'    },
	        { key: 'rd',    label: '研開'    },
	        { key: 'c',     label: '裁剪'    }
	        // ← 沒有 else
	    ];
	} else {
	    // 溪州廠、斗二廠、斗一廠：只顯示前6個
	    labelOrder = [
	        { key: 'mb',    label: '廠務'    },
	        { key: 'e',     label: '生管成品' },
	        { key: 'm',     label: '製造'    },
	        { key: 'p',     label: '加工'    },
	        { key: 'm41',   label: '設備'    },
	        { key: 'else',  label: '其他'    }
	    ];
	}
	
	var tbody = document.querySelector('#shared-human-panel tbody');
	tbody.innerHTML = '';
	var dataset = element.dataset;
	
	for (var j = 0; j < labelOrder.length; j++) {
	    var prefix = labelOrder[j].key;
	    var label  = labelOrder[j].label;
	    var twVal  = Number(dataset[prefix + 'taiwan'])  || 0;
	    var foVal  = Number(dataset[prefix + 'foreign']) || 0;

	    var tr = document.createElement('tr');
	    tr.className = 'hunman-tr';
	    tr.innerHTML =
	        '<td class="labels">'     + label                   + '</td>' +
	        '<td class="num-taiwan">' + twVal.toLocaleString()  + '</td>' +
	        '<td class="num-foreign">' + foVal.toLocaleString() + '</td>';
	    tbody.appendChild(tr);
	}  
	
	panel.classList.add('panel-open');
	element.classList.add('active-human-click');
}
</script>
</body>
</html>