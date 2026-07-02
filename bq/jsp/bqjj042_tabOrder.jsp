<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.ds.dsjccom"%>
<%@ page import="com.icsc.dpms.ds.dsjcagc"%>
<%@ page import="java.util.*" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ042";
%>
<%
    // 2. 初始化 dsCom 連線
    dejc300 _de300 = new dejc300();
    dsjccom _dsCom = _de300.run(_AppId, this, request, response);
    if (_dsCom == null) { 
        return;
    }

    // 從主控檔傳下來的資料取出
    Map dashboardData = (Map) request.getAttribute("dashboardData");
    
    // 訂單區塊
    Map orderData = (Map) (dashboardData != null ? dashboardData.get("orderData") : new HashMap());
    if (orderData == null) orderData = new HashMap();
    
    // 庫存區塊
    Map invData = (Map) (dashboardData != null ? dashboardData.get("inventoryData") : new HashMap());
    if (invData == null) invData = new HashMap();
    
    aajcYCATool aaTool = new aajcYCATool();
    
    // ── 2. 後端動態解析四個接單達成率數值 (供前端顏色判定使用) ──
    double rateOrderAll = 0, rateDomOrd = 0, rateExpFlat = 0, rateExpLong = 0;
    try { 
        if (orderData.get("ORD_RATE") != null) rateOrderAll = Double.parseDouble(orderData.get("ORD_RATE").toString()); 
    } catch(Exception e) {}
    try { 
        if (orderData.get("DOM_RATE") != null) rateDomOrd = Double.parseDouble(orderData.get("DOM_RATE").toString());
    } catch(Exception e) {}
    try { 
        if (orderData.get("EXP_FLAT_RATE") != null) rateExpFlat = Double.parseDouble(orderData.get("EXP_FLAT_RATE").toString());
    } catch(Exception e) {}
    try { 
        if (orderData.get("EXP_LONG_RATE") != null) rateExpLong = Double.parseDouble(orderData.get("EXP_LONG_RATE").toString());
    } catch(Exception e) {}
    
    // 有IV1權限才可以看到金額
    boolean isIV1 = new dsjcagc().check(_dsCom, "AOJJ06", _dsCom.user.ID);
%>
<div class="tab-order-wrap">

  <div class="section-label">銷貨與出貨</div>
  <div class="grid-card">
    <div class="toggle-header" onclick="toggleOrderDetails('sales-details', 'sales-icon')" style="padding: 16px; background: #fafafa;">
      <div class="dual-header-container">
        <div class="dual-header-main">
          <div style="font-size: 16px; font-weight: 900; color: #333; display: flex; align-items: center;">
            <svg id="sales-icon" class="toggle-icon" style="color: #666;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            銷貨與出貨總覽
          </div>
        </div>
        <div class="dual-header-vals">
          <div class="dual-val-box">
            <div class="item-label" style="color: #333;">本月銷貨</div>
            <div>
              <span class="item-val" style="color: #000;"><%= aaTool.format(orderData.get("SALESQTY"),"#,##0", RoundingMode.HALF_UP) %></span>
              <span class="item-unit">噸</span>
            </div>
          </div>
          <div class="dual-val-box">
            <div class="item-label" style="color: #333;">本月出貨</div>
            <div>
              <span class="item-val" style="color: #000;"><%= aaTool.format(orderData.get("SHIPQTY"),"#,##0", RoundingMode.HALF_UP) %></span>
              <span class="item-unit">噸</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div id="sales-details" class="details-content">
      <div style="display: flex; justify-content: space-between; padding: 12px 16px 0; gap: 8px;">
        <div class="col-left"></div>
        <div class="col-right" style="background: #fff0ef; color: #d32f2f; padding: 4px 0; border-radius: 6px; font-size: 13px; font-weight: 900; text-align: center;">銷貨</div>
        <div class="col-right" style="background: #e6f0fa; color: #0056b3; padding: 4px 0; border-radius: 6px; font-size: 13px; font-weight: 900; text-align: center;">出貨</div>
      </div>

      <div class="detail-group" style="border-top: none;">
        <div class="detail-group-header">
          <div class="detail-title col-left" style="color: #333;">內銷管</div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #333; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
            <%= aaTool.format(orderData.get("內銷管_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #333; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
            <%= aaTool.format(orderData.get("內銷管_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
        </div>
        <div class="detail-grid">
          <div class="detail-row">
            <span class="col-left">P：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("內銷配管_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("內銷配管_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span class="col-left">T：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("內銷構造管_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("內銷構造管_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span class="col-left">F/L：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("內銷角扁鐵_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("內銷角扁鐵_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
        </div>
      </div>

      <div class="detail-group">
        <div class="detail-group-header">
          <div class="detail-title col-left" style="color: #333;">外銷管</div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #333; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
            <%= aaTool.format(orderData.get("外銷管_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #333; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
            <%= aaTool.format(orderData.get("外銷管_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
        </div>
        <div class="detail-grid">
          <div class="detail-row">
            <span class="col-left">P：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("外銷配管_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("外銷配管_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span class="col-left">T：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("外銷構造管_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("外銷構造管_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span class="col-left">F/L：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("外銷角扁鐵_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("外銷角扁鐵_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
        </div>
      </div>

      <div class="detail-group">
        <div class="detail-group-header">
          <div class="detail-title col-left" style="color: #333;">板捲</div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #333; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
            <%= aaTool.format(orderData.get("C/S_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #333; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
            <%= aaTool.format(orderData.get("C/S_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
        </div>
        <div class="detail-grid">
          <div class="detail-row">
            <span class="col-left">CR_C/S：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("CR_C/S_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("CR_C/S_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span class="col-left">HR_C/S：</span>
            <span class="detail-row-val col-right" style="color: #222; background: #fffaf9; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("HR_C/S_銷貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
            <span class="detail-row-val col-right" style="color: #222; background: #f5f9ff; border-radius: 4px; padding: 2px 8px;">
              <%= aaTool.format(orderData.get("HR_C/S_出貨量"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 11px; font-weight: 700; color: #666;">噸</span>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="section-label">達成率</div>
  <div class="grid-card" style="border-color: #34c759;">
    <div class="toggle-header" onclick="toggleOrderDetails('target-details', 'target-icon')" style="padding: 18px 16px;">
      <div class="dual-header-container">
        <div class="dual-header-main">
          <div style="font-size: 16px; font-weight: 900; color: #333; display: flex; align-items: center; margin-bottom: 4px;">
            <svg id="target-icon" class="toggle-icon" style="color: #333; transition: transform 0.3s ease; margin-right: 8px; vertical-align: middle;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            總出貨目標 / 總達成率
          </div>
        </div>
        <div style="display: flex; align-items: baseline;">
          <span class="item-val" style="color: #000;"><%= aaTool.format(orderData.get("本月_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></span>
          <span class="item-unit" style="margin-left: 4px;">噸</span>
          <span class="text-green" style="font-size: 32px; font-weight: 900; margin-left: auto;"><%= aaTool.format(orderData.get("本月_出貨達標率"),"#,##0.0") %>%</span>
        </div>
      </div>
    </div>
    
    <div id="target-details" class="details-content" style="background: #f9f9fb;">
      <div class="target-table" style="border-top: 1px solid #d1d1d6;">
        <div class="target-row th">
          <div style="text-align: left;">產品別</div>
          <div>出貨(噸)</div>
          <div>目標(噸)</div>
          <div style="text-align: right;">達成率</div>
        </div>

        <div class="target-row" onclick="toggleSubDetails('sub-dom-details', 'sub-dom-icon', event)" style="cursor: pointer; background: #ffffff;">
          <div class="target-cell-name">
            <svg id="sub-dom-icon" class="toggle-icon" style="color: #666; transition: transform 0.2s; margin-right: 4px; display: inline-block; vertical-align: middle;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
            內銷管
          </div>
          <div class="target-cell-val"><%= aaTool.format(orderData.get("內銷管_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
          <div class="target-cell-target"><%= aaTool.format(orderData.get("內銷管_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
          <div class="target-cell-rate text-green"><%= aaTool.format(orderData.get("內銷管_出貨達標率"),"#,##0.0") %>%</div>
        </div>
        <div id="sub-dom-details" class="details-content" style="background: #f4f5f7;">
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">P</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("內銷配管_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("內銷配管_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-green" style="font-size: 14px;"><%= aaTool.format(orderData.get("內銷配管_出貨達標率"),"#,##0.0") %>%</div>
          </div>
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">T</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("內銷構造管_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("內銷構造管_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-green" style="font-size: 14px;"><%= aaTool.format(orderData.get("內銷構造管_出貨達標率"),"#,##0.0") %>%</div>
          </div>
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">F/L</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("內銷角扁鐵_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("內銷角扁鐵_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-green" style="font-size: 14px;"><%= aaTool.format(orderData.get("內銷角扁鐵_出貨達標率"),"#,##0.0") %>%</div>
          </div>
        </div>

        <div class="target-row" onclick="toggleSubDetails('sub-exp-details', 'sub-exp-icon', event)" style="cursor: pointer; background: #ffffff;">
          <div class="target-cell-name">
            <svg id="sub-exp-icon" class="toggle-icon" style="color: #666; transition: transform 0.2s; margin-right: 4px; display: inline-block; vertical-align: middle;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
            外銷管
          </div>
          <div class="target-cell-val"><%= aaTool.format(orderData.get("外銷管_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
          <div class="target-cell-target"><%= aaTool.format(orderData.get("外銷管_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
          <div class="target-cell-rate text-amber"><%= aaTool.format(orderData.get("外銷管_出貨達標率"),"#,##0.0") %>%</div>
        </div>
        <div id="sub-exp-details" class="details-content" style="background: #f4f5f7;">
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">P</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("外銷配管_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("外銷配管_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-amber" style="font-size: 14px;"><%= aaTool.format(orderData.get("外銷配管_出貨達標率"),"#,##0.0") %>%</div>
          </div>
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">T</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("外銷構造管_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("外銷構造管_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-amber" style="font-size: 14px;"><%= aaTool.format(orderData.get("外銷構造管_出貨達標率"),"#,##0.0") %>%</div>
          </div>
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">F/L</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("外銷角扁鐵_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("外銷角扁鐵_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-amber" style="font-size: 14px;"><%= aaTool.format(orderData.get("外銷角扁鐵_出貨達標率"),"#,##0.0") %>%</div>
          </div>
        </div>

        <div class="target-row" onclick="toggleSubDetails('sub-flat-details', 'sub-flat-icon', event)" style="cursor: pointer; background: #ffffff;">
          <div class="target-cell-name">
            <svg id="sub-flat-icon" class="toggle-icon" style="color: #666; transition: transform 0.2s; margin-right: 4px; display: inline-block; vertical-align: middle;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
            板捲
          </div>
          <div class="target-cell-val"><%= aaTool.format(orderData.get("C/S_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
          <div class="target-cell-target"><%= aaTool.format(orderData.get("板捲_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
          <div class="target-cell-rate text-blue"><%= aaTool.format(orderData.get("板捲_出貨達標率"),"#,##0.0") %>%</div>
        </div>
        <div id="sub-flat-details" class="details-content" style="background: #f4f5f7;">
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">CR</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("CR_C/S_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("CR板捲_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-blue" style="font-size: 14px;"><%= aaTool.format(orderData.get("CR板捲_出貨達標率"),"#,##0.0") %>%</div>
          </div>
          <div class="target-row" style="border-top: 1px solid #e5e5ea; padding: 8px 14px; font-size: 14px;">
            <div class="target-cell-name" style="padding-left: 20px; font-weight: normal; color: #555;">HR</div>
            <div class="target-cell-val" style="font-size: 14px; color: #555;"><%= aaTool.format(orderData.get("HR_C/S_出貨量"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-target" style="font-size: 14px; background: none; color: #0056b3;"><%= aaTool.format(orderData.get("HR板捲_出貨目標"),"#,##0", RoundingMode.HALF_UP) %></div>
            <div class="target-cell-rate text-blue" style="font-size: 14px;"><%= aaTool.format(orderData.get("HR板捲_出貨達標率"),"#,##0.0") %>%</div>
          </div>
        </div>
      </div>
    </div>
  </div>

<% if (isIV1) { %>
  <div class="section-label">營收與單價</div>
  <div class="grid-card" style="border-color: #b3d4ff;">
    <div class="toggle-header toggle-header-blue" onclick="toggleOrderDetails('revenue-details', 'revenue-icon')" style="padding: 16px; background: #e6f0fa;">
      <div class="dual-header-container">
        <div class="dual-header-main">
          <div style="font-size: 16px; font-weight: 900; color: #0056b3; display: flex; align-items: center;">
            <svg id="revenue-icon" class="toggle-icon" style="color: #0056b3;" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            營收與單價總覽
          </div>
        </div>
        <div class="dual-header-vals" style="border-top-color: rgba(0,86,179,0.1);">
          <div class="dual-val-box" style="border-right-color: rgba(0,86,179,0.1);">
            <div class="item-label" style="font-size: 13px; font-weight: 700; margin-bottom: 4px; color: #0056b3;">營業額</div>
            <div>
              <span class="item-val" style="font-size: 26px; color: #004085;"><%= aaTool.format(orderData.get("銷貨金額"),"#,##0.0") %></span>
              <span class="item-unit" style="color: #0056b3;">億</span>
            </div>
          </div>
          <div class="dual-val-box">
            <div class="item-label" style="font-size: 13px; font-weight: 700; margin-bottom: 4px; color: #0056b3;">單價</div>
            <div>
              <span class="item-val" style="font-size: 26px; color: #004085;"><%= aaTool.format(orderData.get("銷貨單價"),"#,##0.0") %></span>
              <span class="item-unit" style="color: #0056b3;">NT/KG</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div id="revenue-details" class="details-content">
      <div style="padding: 18px 16px; background: #ebf5ff; border-top: 1px solid #b3d4ff;">
        <div style="font-size: 14px; font-weight: 900; color: #0056b3; margin-bottom: 12px; border-bottom: 1px solid #b3d4ff; padding-bottom: 8px;">
          產品別明細
        </div>
        <div class="detail-grid">
          <div class="detail-row">
            <span class="col-left">P：</span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3;"><%= aaTool.format(orderData.get("配管_銷貨金額"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">億</span></span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3; flex: 1.5; white-space: nowrap;"><%= aaTool.format(orderData.get("配管_銷貨單價"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">NT/KG</span></span>
          </div>
          <div class="detail-row">
            <span class="col-left">T：</span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3;"><%= aaTool.format(orderData.get("構造管_銷貨金額"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">億</span></span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3; flex: 1.5; white-space: nowrap;"><%= aaTool.format(orderData.get("構造管_銷貨單價"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">NT/KG</span></span>
          </div>
          <div class="detail-row">
            <span class="col-left">F/L：</span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3;"><%= aaTool.format(orderData.get("角扁鐵_銷貨金額"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">億</span></span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3; flex: 1.5; white-space: nowrap;"><%= aaTool.format(orderData.get("角扁鐵_銷貨單價"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">NT/KG</span></span>
          </div>
          <div class="detail-row">
            <span class="col-left">CR_C/S：</span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3;"><%= aaTool.format(orderData.get("CR_C/S_銷貨金額"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">億</span></span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3; flex: 1.5; white-space: nowrap;"><%= aaTool.format(orderData.get("CR_C/S_銷貨單價"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">NT/KG</span></span>
          </div>
          <div class="detail-row">
            <span class="col-left">HR_C/S：</span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3;"><%= aaTool.format(orderData.get("HR_C/S_銷貨金額"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">億</span></span>
            <span class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3; flex: 1.5; white-space: nowrap;"><%= aaTool.format(orderData.get("HR_C/S_銷貨單價"),"#,##0.0") %> <span style="font-size: 11px; font-weight: 700; color: #666;">NT/KG</span></span>
          </div>
        </div>
      </div>
    </div>
  </div>
<% } %>

  <div class="section-label">本月接單</div>
  <div class="grid-card" style="border-radius: 16px;">
    <div style="padding: 18px 16px;">
      <div style="font-size: 16px; font-weight: 900; color: #333; margin-bottom: 8px;">本月接單總計 / 達成率</div>
      <div style="display: flex; align-items: baseline;">
        <span class="item-val" style="font-size: 38px; color: #000;"><%= aaTool.format(orderData.get("ORDERQTY"),"#,##0", RoundingMode.HALF_UP) %></span>
        <span class="item-unit" style="font-size: 16px; margin-left: 4px;">噸</span>
        <span class="<%= rateOrderAll >= 100.0 ? "text-red" : "text-green" %>" style="font-size: 16px; font-weight: 900; margin-left: 12px;">
          <%= aaTool.format(orderData.get("ORD_RATE"),"#,##0", RoundingMode.HALF_UP) %>%
        </span>
        <span class="text-red" style="font-size: 14px; font-weight: 900; margin-left: auto;">
           <%= orderData.get("ORD_TODAYQTY") != null ? "↑ " + orderData.get("ORD_TODAYQTY") : "--" %>
        </span>
      </div>
    </div>
    <div style="background: #f9f9fb; border-top: 1px solid #d1d1d6; border-bottom: 1px solid #d1d1d6; display: grid; grid-template-columns: 1fr 1fr 1fr;">
      <div style="padding: 14px 4px; text-align: center; border-right: 1px solid #d1d1d6;">
        <div style="font-size: 14px; font-weight: 700; color: #333; margin-bottom: 4px;">
          內銷 <span class="<%= rateDomOrd >= 100.0 ? "text-red" : "text-green" %>"><%= aaTool.format(orderData.get("DOM_RATE"),"#,###") %>%</span>
        </div>
        <div style="font-size: 22px; font-weight: 900; color: #000;"><%= aaTool.format(orderData.get("ORDQTY_DOM"),"#,##0", RoundingMode.HALF_UP) %><span style="font-size:12px; font-weight:700; color:#666;">噸</span></div>
      </div>
      <div style="padding: 14px 4px; text-align: center; border-right: 1px solid #d1d1d6;">
        <div style="font-size: 14px; font-weight: 700; color: #333; margin-bottom: 4px;">
          外板 <span class="<%= rateExpFlat >= 100.0 ? "text-red" : "text-green" %>"><%= aaTool.format(orderData.get("EXP_FLAT_RATE"),"#,###") %>%</span>
        </div>
        <div style="font-size: 22px; font-weight: 900; color: #000;"><%= aaTool.format(orderData.get("ORDQTY_EXP_FLAT"),"#,##0", RoundingMode.HALF_UP) %><span style="font-size:12px; font-weight:700; color:#666;">噸</span></div>
      </div>
      <div style="padding: 14px 4px; text-align: center;">
        <div style="font-size: 14px; font-weight: 700; color: #333; margin-bottom: 4px;">
          外管 <span class="<%= rateExpLong >= 100.0 ? "text-red" : "text-green" %>"><%= aaTool.format(orderData.get("EXP_LONG_RATE"),"#,###") %>%</span>
        </div>
        <div style="font-size: 22px; font-weight: 900; color: #000;"><%= aaTool.format(orderData.get("ORDQTY_EXP_LONG"),"#,##0", RoundingMode.HALF_UP) %><span style="font-size:12px; font-weight:700; color:#666;">噸</span></div>
      </div>
    </div>
    <div class="toggle-header" onclick="toggleOrderDetails('tr-received-details', 'tr-received-icon')" style="padding: 20px 16px; display: flex; justify-content: space-between; align-items: center; background: #eef2ff;">
      <div style="font-size: 18px; font-weight: 900; color: #0056b3; display: flex; align-items: center;">
        <svg id="tr-received-icon" class="toggle-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="6 9 12 15 18 9"></polyline>
        </svg>
        接單總計
      </div>
    </div>
    <div id="tr-received-details" class="details-content">
      <div class="detail-group">
        <div class="detail-group-header" style="justify-content: flex-start; gap: 16px;">
          <div class="detail-title col-left" style="color: #333;">內銷管</div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3; flex: none; white-space: nowrap; margin-left: auto;">
            <%= aaTool.format(orderData.get("內銷管_接單量"),"#,##0", RoundingMode.HALF_UP) %> 
            <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span></div>
        </div>
        <div class="detail-grid" style="grid-template-columns: 1fr;">
          <div class="detail-row"><span>P：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_P_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_O：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_T_O_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_口：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_T_口_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>F/L：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_FL_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
        </div>
      </div>
  
      <div class="detail-group">
        <div class="detail-group-header" style="justify-content: flex-start; gap: 16px;">
          <div class="detail-title col-left" style="color: #333;">外銷管</div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3;">
            <%= aaTool.format(orderData.get("ORDQTY_EXP_LONG"),"#,##0", RoundingMode.HALF_UP) %>  <%--從既有的欄位取得 --%> 
            <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span></div>
        </div>
        <div class="detail-grid" style="grid-template-columns: 1fr;">
          <div class="detail-row"><span>P：</span><span class="detail-row-val" style="color: #222;white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_P_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_O：</span><span class="detail-row-val" style="color: #222;white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_T_O_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_口：</span><span class="detail-row-val" style="color: #222;white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_T_口_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>F/L：</span><span class="detail-row-val" style="color: #222;white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_FL_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
        </div>
      </div>
  
      <div class="detail-group">
        <div class="detail-group-header" style="justify-content: flex-start; gap: 16px;">
          <div class="detail-title col-left" style="color: #333;">板捲</div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #0056b3;">
            <%= aaTool.format(aaTool.getBigDecimal(orderData.get("CR_板捲_接單量")).add(aaTool.getBigDecimal(orderData.get("HR_板捲_接單量"))),"#,##0", RoundingMode.HALF_UP) %> 
            <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span></div>
        </div>
        <div class="detail-grid" style="grid-template-columns: 1fr;">
          <div class="detail-row"><span>CR_C/S：</span><span class="detail-row-val" style="color: #222;white-space: nowrap;"><%= aaTool.format(orderData.get("CR_板捲_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>HR_C/S：</span><span class="detail-row-val" style="color: #222;white-space: nowrap;"><%= aaTool.format(orderData.get("HR_板捲_接單量"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
        </div>
      </div>
  
      <div class="detail-group" style="background: #ffffff;">
        <div class="detail-group-header" onclick="toggleSubDetails('tr-sub-pipe-top10', 'tr-sub-pipe-top10-icon', event)" style="cursor: pointer; margin-bottom: 0;">
          <div class="detail-title col-left" style="color: #1c1c1e; display: flex; align-items: center;">
            <svg id="tr-sub-pipe-top10-icon" class="toggle-icon" style="color: #0056b3; transition: transform 0.2s; margin-right: 6px; vertical-align: middle;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
            鋼管接單TOP10排名
          </div>
          <div class="col-right" style="font-size: 13px; font-weight: 900; color: #0056b3;">點擊展開</div>
        </div>
        <div id="tr-sub-pipe-top10" class="details-content" style="background: #fdfdfe;">
          <div style="padding: 8px 0 4px 20px;">
            <% 
              Map[] pipeTop10MapArr = (Map[]) orderData.get("PIPE_TOP10");
              if (pipeTop10MapArr == null) pipeTop10MapArr = new Map[0];
              
              for (int i = 0; i < pipeTop10MapArr.length; i++) {
                Map row = (Map) pipeTop10MapArr[i];
                String borderStyle = (i < pipeTop10MapArr.length - 1) ? "border-bottom: 1px dashed #e5e5ea;" : "";
            %>
              <div class="detail-row" style="padding: 6px 0; <%= borderStyle %>">
                <span style="color:#555;"><%= (i + 1) %>. <%= aaTool.getStr(row.get("客戶名")) %></span>
                <span class="detail-row-val" style="color:#0056b3;"><%= aaTool.format(row.get("接單量"), "#,##0") %> 噸</span>
              </div>
            <% 
              } 
            %>
          </div>
        </div>
      </div>
  
      <div class="detail-group" style="background: #ffffff; border-top: none;">
        <div class="detail-group-header" onclick="toggleSubDetails('tr-sub-flat-top10', 'tr-sub-flat-top10-icon', event)" style="cursor: pointer; margin-bottom: 0;">
          <div class="detail-title col-left" style="color: #1c1c1e; display: flex; align-items: center;">
            <svg id="tr-sub-flat-top10-icon" class="toggle-icon" style="color: #0056b3; transition: transform 0.2s; margin-right: 6px; vertical-align: middle;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
            板捲接單TOP10排名
          </div>
          <div class="col-right" style="font-size: 13px; font-weight: 900; color: #0056b3;">點擊展開</div>
        </div>
        <div id="tr-sub-flat-top10" class="details-content" style="background: #fdfdfe;">
          <div style="padding: 8px 0 4px 20px;">
            <%  
              Map[] flatTop10MapArr = (Map[]) orderData.get("FLAT_TOP10");
              if (flatTop10MapArr == null) flatTop10MapArr = new Map[0];
         
              for (int i = 0; i < flatTop10MapArr.length; i++) {
                  Map row = (Map) flatTop10MapArr[i];
                  String borderStyle = (i < flatTop10MapArr.length - 1) ? "border-bottom: 1px dashed #e5e5ea;" : "";
            %>
              <div class="detail-row" style="padding: 6px 0; <%= borderStyle %>">
                <span style="color:#555;"><%= (i + 1) %>. <%= aaTool.getStr(row.get("客戶名")) %></span>
                <span class="detail-row-val" style="color:#0056b3;"><%= aaTool.format(row.get("接單量"), "#,##0") %> 噸</span>
              </div>
            <% 
              } 
            %>
          </div>
        </div>
      </div>
  
      <div class="detail-group" style="padding: 18px 16px; background: #ebf5ff; border-top: 1px solid #d1d1d6; margin-bottom: 0;">
        <div class="detail-group-header" style="margin-bottom: 14px; border-bottom: 1px solid #b3d4ff; padding-bottom: 8px; justify-content: flex-start;">
          <div class="detail-title col-left" style="font-size: 14px; font-weight: 900; color: #0056b3;">產品別小計</div>
        </div>
        <div class="detail-grid" style="color: #444; grid-template-columns: 1fr;">
          <div class="detail-row"><span>P：</span><span style="font-size: 15px; font-weight: 900; color: #0056b3;white-space: nowrap;">
            <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_P_接單量")).add(aaTool.getBigDecimal(orderData.get("外銷_P_接單量"))),"#,##0", RoundingMode.HALF_UP) %>
            <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span></span></div>
          <div class="detail-row"><span>T_O：</span><span style="font-size: 15px; font-weight: 900; color: #0056b3;white-space: nowrap;">
            <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_T_O_接單量")).add(aaTool.getBigDecimal(orderData.get("外銷_T_O_接單量"))),"#,##0", RoundingMode.HALF_UP) %>
            <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span></span></div>
          <div class="detail-row"><span>T_口：</span><span style="font-size: 15px; font-weight: 900; color: #0056b3;white-space: nowrap;">
            <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_T_口_接單量")).add(aaTool.getBigDecimal(orderData.get("外銷_T_口_接單量"))),"#,##0", RoundingMode.HALF_UP) %>
            <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span></span></div>
          <div class="detail-row"><span>F/L：</span><span style="font-size: 15px; font-weight: 900; color: #0056b3;white-space: nowrap;">
            <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_FL_接單量")).add(aaTool.getBigDecimal(orderData.get("外銷_FL_接單量"))),"#,##0", RoundingMode.HALF_UP) %>
            <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span></span></div>
          <div class="detail-row"><span>CR_C/S：</span><span style="font-size: 15px; font-weight: 900; color: #0056b3;white-space: nowrap;">
            <%= aaTool.format(orderData.get("CR_板捲_接單量"),"#,##0", RoundingMode.HALF_UP) %>
            <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span></span></div>
          <div class="detail-row"><span>HR_C/S：</span><span style="font-size: 15px; font-weight: 900; color: #0056b3;white-space: nowrap;">
            <%= aaTool.format(orderData.get("HR_板捲_接單量"),"#,##0", RoundingMode.HALF_UP) %>
            <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span></span></div>
        </div>
      </div>
    </div>
  </div>
  <div class="section-label">訂單未交總計</div>
  <div class="grid-card">
    <div class="toggle-header" onclick="toggleOrderDetails('pending-details', 'pending-icon')" style="padding: 20px 16px; display: flex; justify-content: space-between; align-items: center; background: #fff0ef;">
      <div style="font-size: 18px; font-weight: 900; color: #d32f2f; display: flex; align-items: center;">
        <svg id="pending-icon" class="toggle-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="6 9 12 15 18 9"></polyline>
        </svg>
        訂單未交總計
      </div>
      <div><span class="item-val" style="color: #d32f2f;"><%= aaTool.format(orderData.get("UNDERWET"),"#,##0", RoundingMode.HALF_UP) %></span><span class="item-unit" style="color: #d32f2f;">噸</span></div>
    </div>

    <div id="pending-details" class="details-content">
      <div class="detail-group">
        <div class="detail-row-header" style="justify-content: flex-start; gap: 16px; display: flex; align-items: baseline; margin-bottom: 10px;">
          <div class="detail-title col-left" style="color: #333;">內銷管</div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #d32f2f; flex: none; white-space: nowrap; margin-left: auto;">
            <%= aaTool.format(orderData.get("內銷管_未交重"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
        </div>
        <div class="detail-grid" style="grid-template-columns: 1fr;">
          <div class="detail-row"><span>P：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_P_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_O：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_T_O_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_口：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_T_口_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>F/L：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("內銷_FL_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
        </div>
      </div>

      <div class="detail-group">
        <div class="detail-row-header" style="justify-content: flex-start; gap: 16px; display: flex; align-items: baseline; margin-bottom: 10px;">
          <div class="detail-title col-left" style="color: #333;">外銷管 </div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #d32f2f; flex: none; white-space: nowrap; margin-left: auto;">
            <%= aaTool.format(orderData.get("外銷管_未交重"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
        </div>
        <div class="detail-grid" style="grid-template-columns: 1fr;">
          <div class="detail-row"><span>P：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_P_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_O：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_T_O_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>T_口：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_T_口_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>F/L：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("外銷_FL_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
        </div>
      </div>

      <div class="detail-group">
        <div class="detail-row-header" style="justify-content: flex-start; gap: 16px; display: flex; align-items: baseline; margin-bottom: 10px;">
          <div class="detail-title col-left" style="color: #333;">板捲 </div>
          <div class="col-right" style="font-size: 15px; font-weight: 900; color: #d32f2f; flex: none; white-space: nowrap; margin-left: auto;">
            <%= aaTool.format(orderData.get("板捲_未交重"),"#,##0", RoundingMode.HALF_UP) %> <span style="font-size: 12px; font-weight: 700; color: #666;">噸</span>
          </div>
        </div>
        <div class="detail-grid" style="grid-template-columns: 1fr;">
          <div class="detail-row"><span>CR_C/S：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("CR_板捲_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
          <div class="detail-row"><span>HR_C/S：</span><span class="detail-row-val" style="color: #222; white-space: nowrap;"><%= aaTool.format(orderData.get("HR_板捲_未交重"),"#,##0", RoundingMode.HALF_UP) %> 噸</span></div>
        </div>
      </div>

      <div class="detail-group" style="background: #ffffff;">
        <div class="detail-group-header" onclick="toggleSubDetails('sub-dom-top5', 'sub-dom-top5-icon', event)" style="cursor: pointer; margin-bottom: 0;">
          <div class="detail-title col-left" style="color: #1c1c1e; display: flex; align-items: center;">
            <svg id="sub-dom-top5-icon" class="toggle-icon" style="color: #d32f2f; transition: transform 0.2s; margin-right: 6px; vertical-align: middle;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
            內銷未交 TOP 5 排行
          </div>
          <div class="col-right text-red" style="font-size: 13px; font-weight: 900;">點擊展開</div>
        </div>
        <div id="sub-dom-top5" class="details-content" style="background: #fdfdfe;">
          <div style="padding: 8px 0 4px 20px;">
            <% 
                Map[] domTop5List = (Map[]) orderData.get("內銷訂未交 TOP 5");
                if (domTop5List == null) domTop5List = new Map[0];
                
                for (int i = 0; i < domTop5List.length; i++) {
                    Map row = (Map) domTop5List[i];
                    String borderStyle = (i < domTop5List.length - 1) ? "border-bottom: 1px dashed #e5e5ea;" : "";
            %>
            <div class="detail-row" style="padding: 6px 0; <%= borderStyle %>">
              <span style="color:#555; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;"><%= (i + 1) %>. <%= aaTool.getStr(row.get("客戶名")) %></span>
              <span class="detail-row-val" style="color:#d32f2f; white-space: nowrap; flex-shrink: 0; margin-left: 8px;"><%= aaTool.format(row.get("訂未交"), "#,##0") %> 噸</span>
            </div>
            <% 
                } 
            %>
          </div>
        </div>
      </div>

      <div class="detail-group" style="background: #ffffff; border-top: none;">
        <div class="detail-group-header" onclick="toggleSubDetails('sub-exp-top5', 'sub-exp-top5-icon', event)" style="cursor: pointer; margin-bottom: 0;">
          <div class="detail-title col-left" style="color: #1c1c1e; display: flex; align-items: center;">
            <svg id="sub-exp-top5-icon" class="toggle-icon" style="color: #d32f2f; transition: transform 0.2s; margin-right: 6px; vertical-align: middle;" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
            外銷未交 TOP 5 排行
          </div>
          <div class="col-right text-red" style="font-size: 13px; font-weight: 900;">點擊展開</div>
        </div>
        <div id="sub-exp-top5" class="details-content" style="background: #fdfdfe;">
          <div style="padding: 8px 0 4px 20px;">
            <%  
                Map[] expTop5List = (Map[]) orderData.get("外銷訂未交 TOP 5");
                if (expTop5List == null) expTop5List = new Map[0];
                
                for (int i = 0; i < expTop5List.length; i++) {
                    Map row = (Map) expTop5List[i];
                    String borderStyle = (i < expTop5List.length - 1) ? "border-bottom: 1px dashed #e5e5ea;" : "";
            %>
            <div class="detail-row" style="padding: 6px 0; <%= borderStyle %>; display: flex; justify-content: space-between; align-items: flex-start; gap: 8px;">
              <span style="color:#555; white-space: normal; word-break: break-all; flex: 1;"><%= (i + 1) %>. <%= aaTool.getStr(row.get("客戶名")) %></span>
              <span class="detail-row-val" style="color:#d32f2f; white-space: nowrap; flex-shrink: 0; margin-left: auto; padding-top: 1px;"><%= aaTool.format(row.get("訂未交"), "#,##0") %> 噸</span>
            </div>

            <% 
                } 
            %>
          </div>
        </div>
      </div>

      <div style="padding: 18px 16px; background: #ebf5ff; border-top: 1px solid #d1d1d6;">
        <div style="font-size: 14px; font-weight: 900; color: #0056b3; margin-bottom: 14px; border-bottom: 1px solid #b3d4ff; padding-bottom: 8px;">
          產品別小計 
        </div>
        <div class="detail-grid" style="color: #444; grid-template-columns: 1fr;">
          <div class="detail-row">
            <span>P：</span>
            <span style="font-size: 15px; font-weight: 900; color: #0056b3; white-space: nowrap;">
              <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_P_未交重")).add(aaTool.getBigDecimal(orderData.get("外銷_P_未交重"))),"#,##0", RoundingMode.HALF_UP) %>
              <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span>T_O：</span>
            <span style="font-size: 15px; font-weight: 900; color: #0056b3; white-space: nowrap;">
              <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_T_O_未交重")).add(aaTool.getBigDecimal(orderData.get("外銷_T_O_未交重"))),"#,##0", RoundingMode.HALF_UP) %>
              <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span>T_口：</span>
            <span style="font-size: 15px; font-weight: 900; color: #0056b3; white-space: nowrap;">
              <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_T_口_未交重")).add(aaTool.getBigDecimal(orderData.get("外銷_T_口_未交重"))),"#,##0", RoundingMode.HALF_UP) %>
              <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span>F/L：</span>
            <span style="font-size: 15px; font-weight: 900; color: #0056b3; white-space: nowrap;">
              <%= aaTool.format(aaTool.getBigDecimal(orderData.get("內銷_FL_未交重")).add(aaTool.getBigDecimal(orderData.get("外銷_FL_未交重"))),"#,##0", RoundingMode.HALF_UP) %>
              <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span>CR_C/S：</span>
            <span style="font-size: 15px; font-weight: 900; color: #0056b3; white-space: nowrap;">
              <%= aaTool.format(orderData.get("CR_板捲_未交重"),"#,##0", RoundingMode.HALF_UP) %>
              <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span>
            </span>
          </div>
          <div class="detail-row">
            <span>HR_C/S：</span>
            <span style="font-size: 15px; font-weight: 900; color: #0056b3; white-space: nowrap;">
              <%= aaTool.format(orderData.get("HR_板捲_未交重"),"#,##0", RoundingMode.HALF_UP) %>
              <span style="font-size: 12px; font-weight: 700; color: #444;">噸</span>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="section-label">庫存結構</div>
  <div class="grid-card">
    <div class="grid-row">
      <div class="grid-item grid-item-border-right grid-item-border-bottom">
        <div class="item-label">原料/板成品庫存</div>
        <div><span class="item-val" style="color: #000;"><%= aaTool.format(invData.get("原料庫存"),"#,##0", RoundingMode.HALF_UP)%></span><span class="item-unit">噸</span></div>
      </div>
      <div class="grid-item grid-item-border-bottom">
        <div class="item-label">管/型鋼成品庫存</div>
        <div><span class="item-val" style="color: #000;"><%= aaTool.format(invData.get("成品庫存"),"#,##0", RoundingMode.HALF_UP)%></span><span class="item-unit">噸</span></div>
      </div>
    </div>
    <div class="grid-row">
      <div class="grid-item grid-item-border-right">
        <div class="item-label">鋼廠未交</div>
        <div><span class="item-val" style="color: #000;"><%= aaTool.format(invData.get("鋼廠未交"),"#,##0", RoundingMode.HALF_UP)%></span><span class="item-unit">噸</span></div>
      </div>
      <div class="grid-item">
        <div class="item-label">結存</div>
        <div><span class="item-val text-blue" style="color: #0056b3;"><%= aaTool.format(invData.get("結存"),"#,##0", RoundingMode.HALF_UP)%></span><span class="item-unit">噸</span></div>
      </div>
    </div>
  </div>

  <script>
    // 專屬這個分頁的展開收合特效
    function toggleOrderDetails(contentId, iconId) {
      const content = document.getElementById(contentId);
      const icon = document.getElementById(iconId);
      if (content && icon) {
        if (content.classList.contains('expanded')) {
          content.classList.remove('expanded');
          icon.style.transform = 'rotate(0deg)';
        } else {
          content.classList.add('expanded');
          icon.style.transform = 'rotate(180deg)';
        }
      }
    }

    // 處理達成率與 TOP 5 表格內細項項目的展開收合
    function toggleSubDetails(contentId, iconId, event) {
      if (event) event.stopPropagation(); // 阻止點擊事件向上傳遞，防範外層區塊混亂
      const content = document.getElementById(contentId);
      const icon = document.getElementById(iconId);
      if (content && icon) {
        if (content.classList.contains('expanded')) {
          content.classList.remove('expanded');
          icon.style.transform = 'rotate(0deg)';
        } else {
          content.classList.add('expanded');
          icon.style.transform = 'rotate(90deg)'; // 轉為指向下方的箭頭
        }
      }
    }
  </script>
</div>