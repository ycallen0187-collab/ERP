<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.bq.core.bqjc052" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ052"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<%
    // 取得資料
    bqjc052 bq052 = new bqjc052(_dsCom);
    Map dataOV= bq052.getDashboardDataOV(_dsCom);
    
    Map craData = (Map) (dataOV != null ? dataOV.get("craOV") : new HashMap());
    for(Object key:craData.keySet()){
    	System.out.println(key.toString()+":"+craData.get(key));
    }
    Map machineData = (Map) (dataOV != null ? dataOV.get("machineOV") : new HashMap());
    for(Object key:machineData.keySet()){
    	System.out.println(key.toString()+":"+machineData.get(key));
    }
    Map fklData = (Map) (dataOV != null ? dataOV.get("fklOV") : new HashMap());
    for(Object key:fklData.keySet()){
    	System.out.println(key.toString()+":"+fklData.get(key));
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="cp950">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">

<style>
body {
    margin:0;
    background:#F4F6F8;
    font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto;
}

/* 卡片 */
.card {
    background:#ffffff;
    border-radius:2rem;
    padding:22px;
    margin:15px;
    border:1px solid #e5e7eb;
    box-shadow:0 4px 12px rgba(0,0,0,0.05);
}

/* 主標題 */
.card h3 {
    margin:0 0 16px 0;
    font-size:16px;
    font-weight:bold;
    color:#374151;
}

/* 標題內 數字（橘色） */
.highlight {
    color:#f97316;
    font-weight:bold;
}

/* Grid */
.grid {
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:12px;
}

/* 小卡 */
.stat {
    text-align:center;
    background:#ffffff;
    padding:14px 10px;
    border-radius:14px;
    border:1px solid #e5e7eb;
}

/* 工廠名稱 */
.stat .name {
    font-size:12px;
    color:#9ca3af;
    margin-bottom:4px;
}

/* 數字 */
.stat .num {
    font-size:20px;
    font-weight:900;
    color:#111827;
}

/* 第二區塊（灰底框） */
.sub-box {
    background:#f1f5f9;
    border-radius:1.5rem;
    padding:16px;
}

/* 設備數量列表 */
.sub-box p {
    margin:6px 0;
    font-size:14px;
    font-weight:bold;
    color:#374151;
}
</style>

<body>
<!-- 天車總覽 -->
<div class="card">
    <h3>
        固定式起重機 (天車) 數量 
        <span class="highlight"><%= craData.get("合計_天車") %> 台</span>
    </h3>

    <div class="grid">
        <div class="stat">
            <div class="name">溪州廠</div>
            <div class="num"><%= craData.get("溪州_天車") %> 台</div>
        </div>

        <div class="stat">
            <div class="name">斗一廠</div>
            <div class="num"><%= craData.get("斗一_天車") %> 台</div>
        </div>

        <div class="stat">
            <div class="name">斗二廠</div>
            <div class="num"><%= craData.get("斗二_天車") %> 台</div>
        </div>

        <div class="stat">
            <div class="name">埔心廠</div>
            <div class="num"><%= craData.get("埔心_天車") %> 台</div>
        </div>
    </div>
</div>

<!-- 設備數量 -->
<div class="card">
    <h3>製管機 & 生產設備數量</h3>

    <div class="sub-box">
        <p>溪州廠：<%= machineData.get("溪州_機台") %> 台</p>
        <p>斗一廠：<%= machineData.get("斗一_機台") %> 台</p>
        <p>斗二廠：<%= machineData.get("斗二_機台") %> 台</p>
        <!-- <p>埔心廠：<%= machineData.get("埔心_機台") %> 台</p>  -->
    </div>
</div>

<!-- 堆高機 -->
<div class="card">
    <h3>
        堆高機
        <span class="highlight"><%= fklData.get("合計_堆高") %> 台</span>
    </h3>
</div>

</body>
</html>