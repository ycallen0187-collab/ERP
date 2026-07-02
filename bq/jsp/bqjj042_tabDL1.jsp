<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.ds.dsjccom"%>
<%@ page import="com.icsc.bq.core.bqjc0422" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.math.BigDecimal"%>
<%!
public static final String _AppId = "BQJJ042"; %>

<% 
	aajcYCATool aaTool = new aajcYCATool();
	String updateDate = aaTool.getStr(request.getParameter("updateDate"));
	dejc300 _de300 = new dejc300();
	dsjccom _dsCom = _de300.run(_AppId, this, request, response);
	if(_dsCom==null){ return ;}

	// 抓取CIC斗一戰情室報表與ERP資料
 	bqjc0422 bq0422 = new bqjc0422(_dsCom);
 	Map dashboardData = bq0422.getDashboardData(_dsCom, request);
	
	// 接單與出貨區塊
    Map orderAndShipment = (Map) (dashboardData != null ? dashboardData.get("OrderAndShipment") : new HashMap());
    if (orderAndShipment == null) orderAndShipment = new HashMap();
    
 	// 本月生產量區塊
    Map monthProduction = (Map) (dashboardData != null ? dashboardData.get("MonthProduction") : new HashMap());
    if (monthProduction == null) monthProduction = new HashMap();
    
    // 品項產出參考區塊
    Map productItem = (Map) (dashboardData != null ? dashboardData.get("ProductItem") : new HashMap());
    if (productItem == null) productItem = new HashMap();
    
    // 總庫存區塊 總庫存品項I(大原料管料、小原料管料、大原料鋼捲、成品鋼板、成品鋼捲、次級)
    Map InventoryItemI = (Map) (dashboardData != null ? dashboardData.get("InventoryItemI") : new HashMap());
    if (InventoryItemI == null) InventoryItemI = new HashMap();
    // 總庫存區塊 總庫存品項II(角鐵、扁鐵)
	Map InventoryItemII = (Map) (dashboardData != null ? dashboardData.get("InventoryItemII") : new HashMap());
    if (InventoryItemII == null) InventoryItemII = new HashMap();
    
    // 欠量與未生產區塊 (切版、8K、研磨、停剪機、CR分條)
    Map EquipmentBacklogI = (Map) (dashboardData != null ? dashboardData.get("EquipmentBacklogI") : new HashMap());
    if (EquipmentBacklogI == null) EquipmentBacklogI = new HashMap();
    // 欠量與未生產區塊 (HR分條、角扁鐵)
    Map EquipmentBacklogII = (Map) (dashboardData != null ? dashboardData.get("EquipmentBacklogII") : new HashMap());
    if (EquipmentBacklogII == null) EquipmentBacklogII = new HashMap();
    
    //人力與追蹤項目
    Map staffData = (Map) (dashboardData != null ? dashboardData.get("StaffData") : new HashMap());
    if (staffData == null) staffData = new HashMap();
    
 	// ==========================================
 	// 接單與出貨計算
 	// ==========================================
 	BigDecimal targetQty = aaTool.getBigDecimal(orderAndShipment.get("本月出貨目標"));
 	BigDecimal salesQty  = aaTool.getBigDecimal(orderAndShipment.get("本月銷貨重量"));
 	BigDecimal currOrder = aaTool.getBigDecimal(orderAndShipment.get("本月接單"));
 	BigDecimal prevOrder = aaTool.getBigDecimal(orderAndShipment.get("上月接單"));

 	// 本月出貨目標達成率 = (本月銷貨重量 / 本月出貨目標) * 100
 	BigDecimal rate = targetQty.compareTo(BigDecimal.ZERO) > 0 ? salesQty.divide(targetQty, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;

 	// 本月與上月接單差額：本月接單 - 上月接單
 	BigDecimal orderDiff = currOrder.subtract(prevOrder);

 	// 本月出貨目標與本月銷貨重量差額：本月出貨目標 - 本月銷貨重量
 	BigDecimal qtyDiff = targetQty.subtract(salesQty);

 	// 接單月增率：(本月與上月接單差額 / 上月接單) * 100
 	BigDecimal orderMoM = prevOrder.compareTo(BigDecimal.ZERO) > 0 ? orderDiff.divide(prevOrder, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;

 	// 接單長條圖比例：(本月接單 / 上月接單) * 100
 	BigDecimal orderBar = prevOrder.compareTo(BigDecimal.ZERO) > 0 ? currOrder.divide(prevOrder, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;
	
	// ==========================================
	// 品項產出長條圖比例計算
	// 顯示方式：本月與上月哪個數值大，就當成 100%
	// ==========================================

	// 管料
	BigDecimal curPipe = aaTool.getBigDecimal(productItem.get("本月管料"));
	BigDecimal prvPipe = aaTool.getBigDecimal(productItem.get("上月管料"));
	BigDecimal maxPipe = curPipe.compareTo(prvPipe) > 0 ? curPipe : prvPipe;
	BigDecimal wCurPipe = maxPipe.compareTo(BigDecimal.ZERO) > 0 ? curPipe.divide(maxPipe, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;
	BigDecimal wPrvPipe = maxPipe.compareTo(BigDecimal.ZERO) > 0 ? prvPipe.divide(maxPipe, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;

	// CR鋼板卷
	BigDecimal curCR = aaTool.getBigDecimal(productItem.get("本月CR鋼板卷"));
	BigDecimal prvCR = aaTool.getBigDecimal(productItem.get("上月CR鋼板卷"));
	BigDecimal maxCR = curCR.compareTo(prvCR) > 0 ? curCR : prvCR;
	BigDecimal wCurCR = maxCR.compareTo(BigDecimal.ZERO) > 0 ? curCR.divide(maxCR, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;
	BigDecimal wPrvCR = maxCR.compareTo(BigDecimal.ZERO) > 0 ? prvCR.divide(maxCR, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;

	// HR鋼板卷
	BigDecimal curHR = aaTool.getBigDecimal(productItem.get("本月HR鋼板卷"));
	BigDecimal prvHR = aaTool.getBigDecimal(productItem.get("上月HR鋼板卷"));
	BigDecimal maxHR = curHR.compareTo(prvHR) > 0 ? curHR : prvHR;
	BigDecimal wCurHR = maxHR.compareTo(BigDecimal.ZERO) > 0 ? curHR.divide(maxHR, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;
	BigDecimal wPrvHR = maxHR.compareTo(BigDecimal.ZERO) > 0 ? prvHR.divide(maxHR, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;

	// 8K
	BigDecimal cur8K = aaTool.getBigDecimal(productItem.get("本月8K"));
	BigDecimal prv8K = aaTool.getBigDecimal(productItem.get("上月8K"));
	BigDecimal max8K = cur8K.compareTo(prv8K) > 0 ? cur8K : prv8K;
	BigDecimal wCur8K = max8K.compareTo(BigDecimal.ZERO) > 0 ? cur8K.divide(max8K, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;
	BigDecimal wPrv8K = max8K.compareTo(BigDecimal.ZERO) > 0 ? prv8K.divide(max8K, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;

	// 型鋼
	BigDecimal curType = aaTool.getBigDecimal(productItem.get("本月型鋼"));
	BigDecimal prvType = aaTool.getBigDecimal(productItem.get("上月型鋼"));
	BigDecimal maxType = curType.compareTo(prvType) > 0 ? curType : prvType;
	BigDecimal wCurType = maxType.compareTo(BigDecimal.ZERO) > 0 ? curType.divide(maxType, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;
	BigDecimal wPrvType = maxType.compareTo(BigDecimal.ZERO) > 0 ? prvType.divide(maxType, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100")) : BigDecimal.ZERO;
	
	// ==========================================
	// 總庫存與長條圖比例計算
	// ==========================================
	BigDecimal sRawPipe   = aaTool.getBigDecimal(InventoryItemI.get("斗一大原料管料"));
	BigDecimal sMinPipe   = aaTool.getBigDecimal(InventoryItemI.get("斗一小原料管料"));
	BigDecimal sRawCoil   = aaTool.getBigDecimal(InventoryItemI.get("斗一大原料鋼捲"));
	BigDecimal sProdPlate = aaTool.getBigDecimal(InventoryItemI.get("斗一成品鋼板"));
	BigDecimal sProdCoil  = aaTool.getBigDecimal(InventoryItemI.get("斗一成品鋼捲"));
	BigDecimal sAngle     = aaTool.getBigDecimal(InventoryItemII.get("斗一角鐵"));
	BigDecimal sFlat      = aaTool.getBigDecimal(InventoryItemII.get("斗一扁鐵"));
	BigDecimal sSub       = aaTool.getBigDecimal(InventoryItemI.get("斗一次級"));

	// 總庫存
	BigDecimal totalStock = sRawPipe.add(sMinPipe).add(sRawCoil).add(sProdPlate).add(sProdCoil)
									.add(sAngle).add(sFlat).add(sSub);

	// 長條圖百分比
	BigDecimal pRawPipe   = BigDecimal.ZERO;
	BigDecimal pMinPipe   = BigDecimal.ZERO;
	BigDecimal pRawCoil   = BigDecimal.ZERO;
	BigDecimal pProdPlate = BigDecimal.ZERO;
	BigDecimal pProdCoil  = BigDecimal.ZERO;
	BigDecimal pAngle     = BigDecimal.ZERO;
	BigDecimal pFlat      = BigDecimal.ZERO;
	BigDecimal pSub       = BigDecimal.ZERO;
	
	if (totalStock.compareTo(BigDecimal.ZERO) > 0) {
		pRawPipe   = sRawPipe.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
		pMinPipe   = sMinPipe.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
		pRawCoil   = sRawCoil.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
		pProdPlate = sProdPlate.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
		pProdCoil  = sProdCoil.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
		pAngle     = sAngle.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
		pFlat      = sFlat.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
		pSub       = sSub.divide(totalStock, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
	}
	// ==========================================
	// 設備欠量與未生產合計計算 
	// ==========================================
	
	// 欠量
	BigDecimal bLogO_cut   = aaTool.getBigDecimal(EquipmentBacklogI.get("欠量重_切板"));
	BigDecimal bLogO_8k    = aaTool.getBigDecimal(EquipmentBacklogI.get("欠量重_8K"));
	BigDecimal bLogO_grind = aaTool.getBigDecimal(EquipmentBacklogI.get("欠量重_研磨"));
	BigDecimal bLogO_stop  = aaTool.getBigDecimal(EquipmentBacklogI.get("欠量重_停剪"));
	BigDecimal bLogO_cr    = aaTool.getBigDecimal(EquipmentBacklogI.get("欠量重_CR分條"));
	BigDecimal bLogO_hr    = aaTool.getBigDecimal(EquipmentBacklogII.get("HR分條欠量重"));
	BigDecimal bLogO_iron  = aaTool.getBigDecimal(EquipmentBacklogII.get("角扁鐵欠量重"));

	// 合計欠量 只計算(切版、停剪機、CR分條、角扁鐵)
	BigDecimal totalBacklogOrder = bLogO_cut.add(bLogO_stop).add(bLogO_cr).add(bLogO_iron);

	// 未生產
	BigDecimal bLogP_cut   = aaTool.getBigDecimal(EquipmentBacklogI.get("未生產重_切板"));
	BigDecimal bLogP_8k    = aaTool.getBigDecimal(EquipmentBacklogI.get("未生產重_8K"));
	BigDecimal bLogP_grind = aaTool.getBigDecimal(EquipmentBacklogI.get("未生產重_研磨"));
	BigDecimal bLogP_stop  = aaTool.getBigDecimal(EquipmentBacklogI.get("未生產重_停剪"));
	BigDecimal bLogP_cr    = aaTool.getBigDecimal(EquipmentBacklogI.get("未生產重_CR分條"));
	BigDecimal bLogP_hr    = aaTool.getBigDecimal(EquipmentBacklogII.get("HR分條未生產重"));
	BigDecimal bLogP_iron  = aaTool.getBigDecimal(EquipmentBacklogII.get("角扁鐵未生產重"));

	// 合計未生產 只計算(切版、停剪機、CR分條、角扁鐵)
	BigDecimal totalBacklogProd = bLogP_cut.add(bLogP_stop).add(bLogP_cr).add(bLogP_iron);
	
	// ==========================================
	// 人力與追蹤項目計算 
	// ==========================================
    BigDecimal mTaiwan  = aaTool.getBigDecimal(staffData.get("製造台籍人數"));
    BigDecimal mForeign = aaTool.getBigDecimal(staffData.get("製造外籍人數"));
    BigDecimal pTaiwan  = aaTool.getBigDecimal(staffData.get("加工台籍人數"));
    BigDecimal pForeign = aaTool.getBigDecimal(staffData.get("加工外籍人數"));
    BigDecimal mbTaiwan  = aaTool.getBigDecimal(staffData.get("廠務台籍人數"));
    BigDecimal mbForeign = aaTool.getBigDecimal(staffData.get("廠務外籍人數"));
    BigDecimal eTaiwan  = aaTool.getBigDecimal(staffData.get("生管成品台籍人數"));
    BigDecimal eForeign = aaTool.getBigDecimal(staffData.get("生管成品外籍人數"));
    BigDecimal m41Taiwan  = aaTool.getBigDecimal(staffData.get("設備台籍人數"));
    BigDecimal m41Foreign = aaTool.getBigDecimal(staffData.get("設備外籍人數"));
    BigDecimal elseTaiwan  = aaTool.getBigDecimal(staffData.get("其他台籍人數"));
    BigDecimal elseForeign = aaTool.getBigDecimal(staffData.get("其他外籍人數"));
    
    BigDecimal mTotal   = mTaiwan.add(mForeign); //製造總人數
    BigDecimal pTotal   = pTaiwan.add(pForeign); //加工總人數
    BigDecimal mbTotal   = mbTaiwan.add(mbForeign); //廠務總人數
    BigDecimal eTotal   = eTaiwan.add(eForeign); //生管成品總人數
    BigDecimal m41Total   = m41Taiwan.add(m41Foreign); //設備總人數
    BigDecimal elseTotal   = elseTaiwan.add(elseForeign); //其他總人數
    BigDecimal factoryTotal   = mTotal.add(pTotal).add(mbTotal).add(eTotal).add(m41Total).add(elseTotal); //全廠總人數
    BigDecimal taiwanTotal   = mTaiwan.add(pTaiwan).add(mbTaiwan).add(eTaiwan).add(m41Taiwan).add(elseTaiwan); //台籍總人數
    BigDecimal foreignTotal   = mForeign.add(pForeign).add(mbForeign).add(eForeign).add(m41Foreign).add(elseForeign); //外籍總人數
    
    
%>


<div id="ajax-target-content">
  <style>
    /* 斗一廠專屬設計系統與色彩變數 (Scoped to DL1) */
    .dl1-wrap {
      --dl1-ink: #182235;
      --dl1-muted: #68758a;
      --dl1-line: #dbe2ea;
      --dl1-card: #ffffff;
      --dl1-green: #34a853;
      --dl1-green-soft: #e5f4e9;
      --dl1-amber: #e6ad00;
      --dl1-amber-soft: #fff2bd;
      --dl1-blue: #4f83ff;
      --dl1-blue-soft: #e5edff;
      --dl1-orange: #ff650a;
      --dl1-orange-soft: #ffe7d7;
      --dl1-red: #e52e4f;
      --dl1-red-soft: #ffe2e7;
      --dl1-purple: #8a63d2;
      --dl1-purple-soft: #eee8fb;
      --dl1-track: #edf1f5;
      --dl1-teal: #18a999;
      --dl1-purple-dl2: #a65bd4;
      
      font-family: "Segoe UI", "Noto Sans TC", "Microsoft JhengHei", Arial, sans-serif;
      color: var(--dl1-ink);
      padding: 4px 0 24px 0;
    }

    .dl1-wrap * { box-sizing: border-box; }
    
    /* 基礎橫列佈局 */
    .dl1-meta-row, .dl1-section-title, .dl1-kpi-topline, .dl1-bar-head, .dl1-pair-row, .dl1-inventory-row, .dl1-focus-row, .dl1-equipment-head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }

    .dl1-hero { padding: 8px 2px 10px; }
    .dl1-eyebrow { margin: 0; color: var(--dl1-muted); font-size: 12px; font-weight: 750; }
    
    /* 狀態標籤 */
    .dl1-live-pill, .dl1-risk-pill, .dl1-delta, .dl1-type-badge {
      display: inline-flex;
      align-items: center;
      min-height: 24px;
      padding: 0 8px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 800;
      white-space: nowrap;
    }
    .dl1-live-pill { color: #176a38; background: var(--dl1-green-soft); }
    .dl1-live-pill::before { content: ""; width: 7px; height: 7px; margin-right: 5px; border-radius: 50%; background: var(--dl1-green); }

    .dl1-lead { margin: 6px 0 0 0; color: var(--dl1-muted); font-size: 13px; line-height: 1.55; font-weight: 650; }
    .dl1-summary-strip { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin: 12px 0; }

    /* 卡片設計 */
    .dl1-hero-card, .dl1-insight, .dl1-kpi-card, .dl1-chart-card, .dl1-inventory-card, .dl1-total-tile, .dl1-equipment-card {
      border: 1px solid var(--dl1-line);
      border-radius: 12px;
      background: var(--dl1-card);
      box-shadow: 0 4px 12px rgba(35, 48, 70, 0.05);
      padding: 12px;
    }

    .dl1-hero-card.wide {
      grid-column: 1 / -1;
      color: #fff;
      border-color: #283a56;
      background: #22314a;
    }
    .dl1-label { margin: 0; color: var(--dl1-muted); font-size: 12px; font-weight: 750; }
    .dl1-hero-card.wide .dl1-label, .dl1-hero-card.wide .dl1-sub { color: rgba(255, 255, 255, 0.76); }
    
    .dl1-value { margin-top: 7px; color: var(--dl1-ink); font-size: 26px; line-height: 1; font-weight: 850; }
    .dl1-hero-card.wide .dl1-value { color: #fff; font-size: 30px; }
    .dl1-sub { margin: 8px 0 0; color: var(--dl1-muted); font-size: 12px; line-height: 1.35; font-weight: 700; }

    /* 風險色彩標籤 */
    .dl1-risk-pill { color: #a52d00; background: var(--dl1-orange-soft); }
    .dl1-risk-pill.red { color: #a90f2c; background: var(--dl1-red-soft); }
    .dl1-risk-pill.blue { color: #2450b8; background: var(--dl1-blue-soft); }

    /* 錨點導航列 */
    .dl1-local-nav {
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
    .dl1-local-nav a {
      display: grid;
      place-items: center;
      height: 32px;
      border: 1px solid var(--dl1-line);
      border-radius: 8px;
      color: #334155;
      background: #fff;
      text-decoration: none;
      font-size: 11px;
      font-weight: 850;
    }

    /* 區塊標題 */
    .dl1-section { margin-top: 16px; scroll-margin-top: 48px; }
    .dl1-section-title { margin-bottom: 8px; }
    .dl1-section-title h2 { margin: 0; font-size: 17px; line-height: 1.2; font-weight: 850; }
    .dl1-section-title small { color: var(--dl1-muted); font-size: 12px; font-weight: 750; }

    /* 重點洞察 */
    .dl1-insights, .dl1-kpi-grid, .dl1-bar-list, .dl1-paired, .dl1-inventory-list, .dl1-equipment-list { display: grid; gap: 8px; }
    .dl1-insight { display: grid; grid-template-columns: 5px 1fr; gap: 10px; padding: 11px 12px 11px 0; overflow: hidden; }
    .dl1-insight::before { content: ""; width: 5px; height: 100%; border-radius: 0 3px 3px 0; background: var(--dl1-orange); }
    .dl1-insight.red::before { background: var(--dl1-red); }
    .dl1-insight.blue::before { background: var(--dl1-blue); }
    .dl1-insight.green::before { background: var(--dl1-green); }
    .dl1-insight b { display: block; margin-bottom: 3px; font-size: 14px; line-height: 1.25; }
    .dl1-insight span { display: block; color: var(--dl1-muted); font-size: 12px; line-height: 1.45; font-weight: 650; }

    /* 進度條與 KPI */
    .dl1-kpi-title { font-size: 14px; font-weight: 850; }
    .dl1-kpi-value { color: var(--dl1-ink); font-size: 22px; font-weight: 850; }
    .dl1-track { position: relative; height: 10px; overflow: hidden; border-radius: 999px; background: var(--dl1-track); margin: 6px 0; }
    .dl1-fill { height: 100%; width: var(--w); min-width: 3px; border-radius: inherit; background: var(--c); }
    .dl1-kpi-meta { display: flex; justify-content: space-between; gap: 8px; color: var(--dl1-muted); font-size: 11px; font-weight: 700; }
    
    .dl1-delta { color: #a90f2c; background: var(--dl1-red-soft); }
    .dl1-delta.neutral { color: #52606f; background: #edf1f5; }

    /* 產出參考長條圖對比 */
    .dl1-bar-list { gap: 14px; }
    .dl1-bar-value { color: var(--c); font-size: 14px; font-weight: 850; }
    .dl1-pair-row { min-height: 28px; }
    .dl1-pair-label { width: 42px; color: var(--dl1-muted); font-size: 12px; font-weight: 800; }
    .dl1-pair-bar { flex: 1; height: 8px; border-radius: 999px; background: var(--dl1-track); overflow: hidden; }
    .dl1-month-fill { height: 100%; width: var(--w); min-width: 3px; border-radius: inherit; background: var(--c); }
    .dl1-pair-value { width: 56px; text-align: right; color: var(--c); font-size: 12px; font-weight: 850; }

    /* 庫存多段堆疊條 */
    .dl1-stacked { display: flex; width: 100%; height: 14px; overflow: hidden; border-radius: 999px; background: var(--dl1-track); margin: 4px 0 10px 0; }
    .dl1-stacked span { width: var(--w); background: var(--c); }
    .dl1-name-dot { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 800; }
    .dl1-name-dot i { flex: 0 0 auto; width: 8px; height: 8px; border-radius: 3px; background: var(--c); }
    
    .dl1-inventory-row { padding-bottom: 8px; border-bottom: 1px solid #edf1f5; }
    .dl1-inventory-row:last-child { border-bottom: 0; padding-bottom: 0; }
    .dl1-inventory-num { text-align: right; font-size: 14px; font-weight: 850; }
    .dl1-inventory-num small { display: block; color: var(--dl1-muted); font-size: 11px; font-weight: 750; }

    /* 欠量與未生產區塊 */
    .dl1-backlog-total { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 8px; }
    .dl1-total-tile span { display: block; color: var(--dl1-muted); font-size: 12px; font-weight: 800; }
    .dl1-total-tile strong { display: block; margin-top: 6px; color: var(--dl1-ink); font-size: 24px; font-weight: 850; }

    /* 設備別卡片明細 */
    .dl1-equipment-name { font-size: 15px; font-weight: 850; }
    .dl1-type-badge { color: #2450b8; background: var(--dl1-blue-soft); font-size: 11px; font-weight: 850; }
    .dl1-type-badge.indirect { color: #7a4b00; background: var(--dl1-amber-soft); }
    .dl1-type-badge.pipe { color: #596274; background: #edf1f5; }
    
    .dl1-equipment-metrics { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-top: 4px; }
    .dl1-metric-box { min-height: 58px; padding: 8px 10px; border-radius: 8px; background: #f7f9fc; }
    .dl1-metric-label { display: block; margin-bottom: 4px; color: var(--dl1-muted); font-size: 12px; font-weight: 800; }
    .dl1-metric-value { display: flex; align-items: center; gap: 6px; color: var(--dl1-ink); font-size: 15px; font-weight: 850; }
    
    .dl1-trend { display: inline-grid; place-items: center; width: 20px; height: 20px; border-radius: 6px; color: #fff; font-size: 14px; font-style: normal; font-weight: 900; background: var(--dl1-red); }
    .dl1-trend.down { background: #198fd7; }
    
    .dl1-data-note { margin: -2px 0 8px 2px; color: var(--dl1-muted); font-size: 12px; font-weight: 700; }
    
    /* 人力資源區塊樣式（已完美同步 dl2 視覺與自適應網格）*/
    .dl1-people-grid { 
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 8px;
        margin-top: 10px;
    }
    
    .dl1-people-card {
        border: 1px solid var(--dl1-line);
        border-radius: 12px;
        background: var(--dl1-card);
        box-shadow: 0 4px 12px rgba(35, 48, 70, 0.05);
        padding: 12px;
    }
    
    .dl1-people-card strong { 
        display: block; 
        margin-top: 4px; 
        color: var(--dl1-purple-dl2); 
        font-size: 30px; 
        font-weight: 850; 
    }
    
    .dl1-people-row { 
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        padding: 10px 0; 
        border-top: 1px solid #edf1f5; 
        color: var(--dl1-muted); 
        font-size: 12px; 
        font-weight: 750; 
    }
    
    .dl1-people-row b { 
        color: var(--dl1-ink); 
        font-size: 15px; 
        font-weight: 850;
    }
  </style>

  <div class="dl1-wrap">
    <header class="dl1-hero">
      <div class="dl1-meta-row">
        <p class="dl1-eyebrow">斗一廠｜本月 vs 上月</p>
        <span class="dl1-live-pill">即時摘要</span>
      </div>
      <p class="dl1-lead">接單、出貨、生產、庫存與欠量集中檢視。</p>
    </header>

    <nav class="dl1-local-nav">
      <a href="javascript:document.getElementById('dl1-summary').scrollIntoView({behavior:'smooth'});">重點</a>
      <a href="javascript:document.getElementById('dl1-sales').scrollIntoView({behavior:'smooth'});">接出貨</a>
      <a href="javascript:document.getElementById('dl1-production').scrollIntoView({behavior:'smooth'});">生產</a>
      <a href="javascript:document.getElementById('dl1-stock').scrollIntoView({behavior:'smooth'});">庫存</a>
      <a href="javascript:document.getElementById('dl1-backlog').scrollIntoView({behavior:'smooth'});">欠量</a>
    </nav>

    <div class="dl1-summary-strip" id="dl1-summary">
      <article class="dl1-hero-card wide">
        <p class="dl1-label">本月出貨目標達成</p>
        <div class="dl1-kpi-topline">
          <div class="dl1-value"><%= aaTool.format(rate, "#,##0.0") %>%</div>
          <span class="dl1-risk-pill red">
            <%= qtyDiff.compareTo(BigDecimal.ZERO) > 0 ? "差 " : "達標 " %>
            <%= aaTool.format(qtyDiff.abs(), "#,##0") %>
          </span>
        </div>
        <p class="dl1-sub">銷售重量 <%= aaTool.format(salesQty, "#,##0") %> / 目標 <%= aaTool.format(targetQty, "#,##0") %>，需優先追出貨節奏。</p>
      </article>

      <article class="dl1-hero-card">
        <p class="dl1-label">外銷本月接單量</p>
        <div class="dl1-value"><%=aaTool.format(currOrder, "#,##0")%></div>
        <p class="dl1-sub">
          較上月<%= orderDiff.compareTo(BigDecimal.ZERO) >= 0 ? "多 " : "少 " %><%= aaTool.format(orderDiff.abs(), "#,##0") %><br>
          月<%= orderMoM.compareTo(BigDecimal.ZERO) >= 0 ? "增 " : "減 " %><%= aaTool.format(orderMoM.abs(), "#,##0.0") %>%
        </p>
      </article>

      <article class="dl1-hero-card">
        <p class="dl1-label">本月生產量</p>
        <div class="dl1-value"><%=aaTool.format(monthProduction.get("本月生產量"), "#,##0")%></div>
        <p class="dl1-sub">Ton｜飛剪、停剪、CR分條</p>
      </article>
    </div>
	<!-- 
    <section class="dl1-section">
      <div class="dl1-section-title">
        <h2>老闆先看</h2>
        <small>3 個重點</small>
      </div>
      <div class="dl1-insights">
        <div class="dl1-insight red">
          <div>
            <b>出貨達成率偏低</b>
            <span>目前銷售重量 670，僅達本月目標 26.8%，剩餘 1,830 需追蹤。</span>
          </div>
        </div>
        <div class="dl1-insight">
          <div>
            <b>接單動能較上月弱</b>
            <span>本月接單 2,091，低於上月 3,481，差距 1,390。</span>
          </div>
        </div>
        <div class="dl1-insight green">
          <div>
            <b>生產量改採直接產出口徑</b>
            <span>本月生產量 1870 Ton，僅包含飛剪、停剪、CR分條。</span>
          </div>
        </div>
      </div>
    </section>
     -->

    <section class="dl1-section" id="dl1-sales">
      <div class="dl1-section-title">
        <h2>接單與出貨</h2>
        <small>板捲</small>
      </div>
      <div class="dl1-kpi-grid">
        <article class="dl1-kpi-card">
          <div class="dl1-kpi-topline"><span class="dl1-kpi-title">外銷本月接單量</span><span class="dl1-kpi-value"><%=aaTool.format(currOrder, "#,##0")%></span></div>
          <div class="dl1-track"><div class="dl1-fill" style="--w:<%= orderBar %>%;--c:var(--dl1-amber)"></div></div>
          <div class="dl1-kpi-meta">
            <span>上月 <%=aaTool.format(prevOrder, "#,##0")%></span>
            <span class="dl1-delta"><%= orderMoM.compareTo(BigDecimal.ZERO) >= 0 ? "+" : "-" %><%= aaTool.format(orderMoM.abs(), "#,##0.0") %>%</span>
          </div>
        </article>

        <article class="dl1-kpi-card">
          <div class="dl1-kpi-topline"><span class="dl1-kpi-title">本月出貨目標</span><span class="dl1-kpi-value"><%= aaTool.format(targetQty, "#,##0") %></span></div>
          <div class="dl1-track"><div class="dl1-fill" style="--w:100%;--c:var(--dl1-orange)"></div></div>
          <div class="dl1-kpi-meta"><span>目標基準</span><span class="dl1-delta neutral">100%</span></div>
        </article>

        <article class="dl1-kpi-card">
          <div class="dl1-kpi-topline"><span class="dl1-kpi-title">本月出貨重量</span><span class="dl1-kpi-value"><%= aaTool.format(salesQty, "#,##0") %></span></div>
          <div class="dl1-track"><div class="dl1-fill" style="--w:<%= aaTool.format(rate, "#,##0.0") %>%;--c:var(--dl1-red)"></div></div>
          <div class="dl1-kpi-meta">
            <span>達成率 <%= aaTool.format(rate, "#,##0.0") %>%</span>
            <span class="dl1-delta"><%= qtyDiff.compareTo(BigDecimal.ZERO) > 0 ? "缺 " : "" %><%= aaTool.format(qtyDiff.abs(), "#,##0") %></span>
          </div>
        </article>
      </div>
    </section>

    <section class="dl1-section" id="dl1-production">
      <div class="dl1-section-title">
        <h2>品項產出參考</h2>
        <small>原圖月比</small>
      </div>
      <p class="dl1-data-note">摘要 KPI 僅採飛剪、停剪、CR分條；下方保留原圖品項月比。</p>
      <div class="dl1-chart-card">
        <div class="dl1-bar-list">
          
          <div>
            <div class="dl1-bar-head">
              <span style="font-weight: bold;">管料</span>
            </div>
            <div class="dl1-paired">
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">本月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wCurPipe%>%;--c:var(--dl1-green)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-green)"><%=aaTool.format(productItem.get("本月管料"), "#,##0.0")%></span>
              </div>
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">上月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wPrvPipe%>%;--c:var(--dl1-amber)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-amber)"><%=aaTool.format(productItem.get("上月管料"), "#,##0.0")%></span>
              </div>
            </div>
          </div>

          <div>
            <div class="dl1-bar-head">
              <span style="font-weight: bold;">CR鋼板卷</span>
            </div>
            <div class="dl1-paired">
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">本月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wCurCR%>%;--c:var(--dl1-blue)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-blue)"><%=aaTool.format(productItem.get("本月CR鋼板卷"), "#,##0.0")%></span>
              </div>
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">上月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wPrvCR%>%;--c:var(--dl1-orange)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-orange)"><%=aaTool.format(productItem.get("上月CR鋼板卷"), "#,##0.0")%></span>
              </div>
            </div>
          </div>

          <div>
            <div class="dl1-bar-head">
              <span style="font-weight: bold;">HR鋼板卷</span>
            </div>
            <div class="dl1-paired">
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">本月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wCurHR%>%;--c:var(--dl1-red)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-red)"><%=aaTool.format(productItem.get("本月HR鋼板卷"), "#,##0.0")%></span>
              </div>
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">上月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wPrvHR%>%;--c:var(--dl1-blue)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-blue)"><%=aaTool.format(productItem.get("上月HR鋼板卷"), "#,##0.0")%></span>
              </div>
            </div>
          </div>

          <div>
            <div class="dl1-bar-head">
              <span style="font-weight: bold;">8K</span>
            </div>
            <div class="dl1-paired">
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">本月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wCur8K%>%;--c:var(--dl1-purple)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-purple)"><%=aaTool.format(productItem.get("本月8K"), "#,##0.0")%></span>
              </div>
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">上月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wPrv8K%>%;--c:#5e35b1"></div></div>
                <span class="dl1-pair-value" style="color:#5e35b1"><%=aaTool.format(productItem.get("上月8K"), "#,##0.0")%></span>
              </div>
            </div>
          </div>

          <div>
            <div class="dl1-bar-head">
              <span style="font-weight: bold;">型鋼</span>
            </div>
            <div class="dl1-paired">
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">本月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wCurType%>%;--c:var(--dl1-green)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-green)"><%=aaTool.format(productItem.get("本月型鋼"), "#,##0.0")%></span>
              </div>
              <div class="dl1-pair-row">
                <span class="dl1-pair-label">上月</span>
                <div class="dl1-pair-bar"><div class="dl1-month-fill" style="--w:<%=wPrvType%>%;--c:var(--dl1-amber)"></div></div>
                <span class="dl1-pair-value" style="color:var(--dl1-amber)"><%=aaTool.format(productItem.get("上月型鋼"), "#,##0.0")%></span>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>

    <section class="dl1-section" id="dl1-stock">
      <div class="dl1-section-title">
        <h2>總庫存</h2>
        <small><%=aaTool.format(totalStock, "#,##0")%></small>
      </div>
      <article class="dl1-inventory-card">
        <div class="dl1-stacked" aria-label="庫存結構">
          <span style="--w:<%=aaTool.format(pRawPipe, "0.0")%>%;--c:var(--dl1-red)"></span>
          <span style="--w:<%=aaTool.format(pMinPipe, "0.0")%>%;--c:#d00000"></span>
          <span style="--w:<%=aaTool.format(pRawCoil, "0.0")%>%;--c:var(--dl1-blue)"></span>
          <span style="--w:<%=aaTool.format(pProdPlate, "0.0")%>%;--c:var(--dl1-orange)"></span>
          <span style="--w:<%=aaTool.format(pProdCoil, "0.0")%>%;--c:#ce6d1b"></span>
          <span style="--w:<%=aaTool.format(pAngle, "0.0")%>%;--c:var(--dl1-green)"></span>
          <span style="--w:<%=aaTool.format(pFlat, "0.0")%>%;--c:#1b5e20"></span>
          <span style="--w:<%=aaTool.format(pSub, "0.0")%>%;--c:var(--dl1-purple)"></span>
        </div>

        <div class="dl1-inventory-list">
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:var(--dl1-red)"><i></i><span>大原料(管料):鋼捲未生產的庫存量</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sRawPipe, "#,##0")%><small><%=aaTool.format(pRawPipe, "0.0")%>%</small></div>
          </div>
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:#d00000"><i></i><span>小原料(管料):已生產完成的庫存量</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sMinPipe, "#,##0")%><small><%=aaTool.format(pMinPipe, "0.0")%>%</small></div>
          </div>
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:var(--dl1-blue)"><i></i><span>大原料鋼捲</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sRawCoil, "#,##0")%><small><%=aaTool.format(pRawCoil, "0.0")%>%</small></div>
          </div>
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:var(--dl1-orange)"><i></i><span>成品鋼板</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sProdPlate, "#,##0")%><small><%=aaTool.format(pProdPlate, "0.0")%>%</small></div>
          </div>
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:#ce6d1b"><i></i><span>成品鋼捲</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sProdCoil, "#,##0")%><small><%=aaTool.format(pProdCoil, "0.0")%>%</small></div>
          </div>
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:var(--dl1-green)"><i></i><span>角鐵</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sAngle, "#,##0")%><small><%=aaTool.format(pAngle, "0.0")%>%</small></div>
          </div>
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:#1b5e20"><i></i><span>扁鐵</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sFlat, "#,##0")%><small><%=aaTool.format(pFlat, "0.0")%>%</small></div>
          </div>
          <div class="dl1-inventory-row">
            <div class="dl1-name-dot" style="--c:var(--dl1-purple)"><i></i><span>次級</span></div>
            <div class="dl1-inventory-num"><%=aaTool.format(sSub, "#,##0")%><small><%=aaTool.format(pSub, "0.0")%>%</small></div>
          </div>
        </div>
      </article>
    </section>

    <section class="dl1-section" id="dl1-backlog">
      <div class="dl1-section-title">
        <h2>欠量與未生產</h2>
        <small>設備別</small>
      </div>
      
      <div class="dl1-backlog-total">
        <div class="dl1-total-tile"><span>合計欠量</span><strong><%=aaTool.format(totalBacklogOrder, "#,##0")%></strong></div>
        <div class="dl1-total-tile"><span>合計未生產</span><strong><%=aaTool.format(totalBacklogProd, "#,##0")%></strong></div>
      </div>

      <div class="dl1-equipment-list">
        <article class="dl1-equipment-card">
          <div class="dl1-equipment-head"><span class="dl1-equipment-name">切板</span><span class="dl1-type-badge">直接產出</span></div>
          <div class="dl1-equipment-metrics">
            <div class="dl1-metric-box"><span class="dl1-metric-label">欠量</span><span class="dl1-metric-value"><%=aaTool.format(bLogO_cut, "#,##0")%></span></div>
            <div class="dl1-metric-box"><span class="dl1-metric-label">未生產</span><span class="dl1-metric-value"><%=aaTool.format(bLogP_cut, "#,##0")%></span></div>
          </div>
        </article>

        <article class="dl1-equipment-card">
          <div class="dl1-equipment-head"><span class="dl1-equipment-name">8K</span><span class="dl1-type-badge indirect">間接產出</span></div>
          <div class="dl1-equipment-metrics">
            <div class="dl1-metric-box"><span class="dl1-metric-label">欠量</span><span class="dl1-metric-value"><%=aaTool.format(bLogO_8k, "#,##0")%></span></div>
            <div class="dl1-metric-box"><span class="dl1-metric-label">未生產</span><span class="dl1-metric-value"><%=aaTool.format(bLogP_8k, "#,##0")%></span></div>
          </div>
        </article>

        <article class="dl1-equipment-card">
          <div class="dl1-equipment-head"><span class="dl1-equipment-name">研磨</span><span class="dl1-type-badge indirect">間接產出</span></div>
          <div class="dl1-equipment-metrics">
            <div class="dl1-metric-box"><span class="dl1-metric-label">欠量</span><span class="dl1-metric-value"><%=aaTool.format(bLogO_grind, "#,##0")%></span></div>
            <div class="dl1-metric-box"><span class="dl1-metric-label">未生產</span><span class="dl1-metric-value"><%=aaTool.format(bLogP_grind, "#,##0")%></span></div>
          </div>
        </article>

        <article class="dl1-equipment-card">
          <div class="dl1-equipment-head"><span class="dl1-equipment-name">停剪機</span><span class="dl1-type-badge">直接產出</span></div>
          <div class="dl1-equipment-metrics">
            <div class="dl1-metric-box"><span class="dl1-metric-label">欠量</span><span class="dl1-metric-value"><%=aaTool.format(bLogO_stop, "#,##0")%></span></div>
            <div class="dl1-metric-box"><span class="dl1-metric-label">未生產</span><span class="dl1-metric-value"><%=aaTool.format(bLogP_stop, "#,##0")%></span></div>
          </div>
        </article>

        <article class="dl1-equipment-card">
          <div class="dl1-equipment-head"><span class="dl1-equipment-name">CR 分條</span><span class="dl1-type-badge">直接產出</span></div>
          <div class="dl1-equipment-metrics">
            <div class="dl1-metric-box"><span class="dl1-metric-label">欠量</span><span class="dl1-metric-value"><%=aaTool.format(bLogO_cr, "#,##0")%></span></div>
            <div class="dl1-metric-box"><span class="dl1-metric-label">未生產</span><span class="dl1-metric-value"><%=aaTool.format(bLogP_cr, "#,##0")%></span></div>
          </div>
        </article>

        <article class="dl1-equipment-card">
          <div class="dl1-equipment-head"><span class="dl1-equipment-name">HR 分條</span><span class="dl1-type-badge pipe">配管</span></div>
          <div class="dl1-equipment-metrics">
            <div class="dl1-metric-box"><span class="dl1-metric-label">欠量</span><span class="dl1-metric-value"><%=aaTool.format(bLogO_hr, "#,##0")%></span></div>
            <div class="dl1-metric-box"><span class="dl1-metric-label">未生產</span><span class="dl1-metric-value"><%=aaTool.format(bLogP_hr, "#,##0")%></span></div>
          </div>
        </article>

        <article class="dl1-equipment-card">
          <div class="dl1-equipment-head"><span class="dl1-equipment-name">角扁鐵</span><span class="dl1-type-badge">直接產出</span></div>
          <div class="dl1-equipment-metrics">
            <div class="dl1-metric-box"><span class="dl1-metric-label">欠量</span><span class="dl1-metric-value"><%=aaTool.format(bLogO_iron, "#,##0")%></span></div>
            <div class="dl1-metric-box"><span class="dl1-metric-label">未生產</span><span class="dl1-metric-value"><%=aaTool.format(bLogP_iron, "#,##0")%></span></div>
          </div>
        </article>
      </div>
    </section>
    
    <section class="dl1-section" id="dl1-people">
      <div class="dl1-section-title">
        <h2>人力與追蹤項目</h2>
        <small>現況管理</small>
      </div>
      
      <article class="dl1-people-card" style="margin-top:8px">
        <div class="dl1-people-row" style="border-top:none;">
          <span>全廠合計人力</span>
          <b><%= aaTool.format(factoryTotal, "#,##0") %> 人</b>
        </div>
        <div class="dl1-people-row">
          <span>台籍 / 外籍總計</span>
          <b><%= aaTool.format(taiwanTotal, "#,##0") %> / <%= aaTool.format(foreignTotal, "#,##0") %></b>
        </div>
      </article>

      <div class="dl1-people-grid">
        <article class="dl1-people-card">
          <p class="dl1-label">廠務人力</p>
          <strong><%= aaTool.format(mbTotal, "#,##0") %>人</strong>
          <p class="dl1-sub">台籍 <%= aaTool.format(mbTaiwan, "#,##0") %> / 外籍 <%= aaTool.format(mbForeign, "#,##0") %></p>
        </article>
        <article class="dl1-people-card">
          <p class="dl1-label">生管成品人力</p>
          <strong style="color:var(--dl1-teal)"><%= aaTool.format(eTotal, "#,##0") %> 人</strong>
          <p class="dl1-sub">台籍 <%= aaTool.format(eTaiwan, "#,##0") %> / 外籍 <%= aaTool.format(eForeign, "#,##0") %></p>
        </article>
      </div>

      <div class="dl1-people-grid">
        <article class="dl1-people-card">
          <p class="dl1-label">製造課人力</p>
          <strong><%= aaTool.format(mTotal, "#,##0") %>人</strong>
          <p class="dl1-sub">台籍 <%= aaTool.format(mTaiwan, "#,##0") %> / 外籍 <%= aaTool.format(mForeign, "#,##0") %></p>
        </article>
        <article class="dl1-people-card">
          <p class="dl1-label">加工課人力</p>
          <strong style="color:var(--dl1-teal)"><%= aaTool.format(pTotal, "#,##0") %> 人</strong>
          <p class="dl1-sub">台籍 <%= aaTool.format(pTaiwan, "#,##0") %> / 外籍 <%= aaTool.format(pForeign, "#,##0") %></p>
        </article>
      </div>

      <div class="dl1-people-grid">
        <article class="dl1-people-card">
          <p class="dl1-label">設備人力</p>
          <strong><%= aaTool.format(m41Total, "#,##0") %>人</strong>
          <p class="dl1-sub">台籍 <%= aaTool.format(m41Taiwan, "#,##0") %> / 外籍 <%= aaTool.format(m41Foreign, "#,##0") %></p>
        </article>
        <article class="dl1-people-card">
          <p class="dl1-label">其他人力</p>
          <strong style="color:var(--dl1-teal)"><%= aaTool.format(elseTotal, "#,##0") %> 人</strong>
          <p class="dl1-sub">台籍 <%= aaTool.format(elseTaiwan, "#,##0") %> / 外籍 <%= aaTool.format(elseForeign, "#,##0") %></p>
        </article>
      </div>
    </section>
    
  </div>
</div>