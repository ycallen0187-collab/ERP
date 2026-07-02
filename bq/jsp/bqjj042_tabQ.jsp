<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.ds.dsjccom"%>
<%@ page import="com.icsc.bq.core.bqjc042" %>
<%@ page import="java.util.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%!
public static final String _AppId = "BQJJ042"; %>

<%
    aajcYCATool aaTool = new aajcYCATool();
    String updateDate = aaTool.getStr(request.getParameter("updateDate"));
    
    dejc300 _de300 = new dejc300();
    dsjccom _dsCom = _de300.run(_AppId, this, request, response);
    if(_dsCom==null){ return ; }
%>

<div id="ajax-target-content">

    <div class="section-label">今日品質快照 <span class="idx">指標66·67·68·69·77</span></div>
    <div class="card">
      <div class="card-row-2">
        <div>
          <div class="metric-label">品保端良率</div>
          <div class="big-num"><span class="metric-val red">93.0</span><span class="metric-unit">%</span></div>
          <div style="margin-top:5px;"><span class="pill pill-red"><i class="dot-icon dot-red"></i> 低於 95% 警戒</span></div>
        </div>
        <div>
          <div class="metric-label">品檢通過率</div>
          <div class="big-num"><span class="metric-val amber">95.4</span><span class="metric-unit">%</span></div>
          <div style="margin-top:5px;"><span class="pill pill-amber"><i class="dot-icon dot-amber"></i> 邊際</span></div>
        </div>
      </div>
      <div class="card-div-bg card-row-4">
        <div class="stat-cell">
          <div class="stat-label">不良批數</div>
          <div class="stat-val red">12批</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">不良數量</div>
          <div class="stat-val red">87支</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">檢驗總批</div>
          <div class="stat-val blue">156批</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">生產-品保落差</div>
          <div class="stat-val red">2.4%</div>
        </div>
      </div>
    </div>

    <div class="section-label">生產端 vs 品保端良率落差 <span class="idx">指標70</span></div>
    <div class="card">
      <div class="card-row-2">
        <div>
          <div class="metric-label">生產端良率</div>
          <div class="big-num"><span class="metric-val md amber">95.4</span><span class="metric-unit">%</span></div>
        </div>
        <div>
          <div class="metric-label">品保端良率</div>
          <div class="big-num"><span class="metric-val md red">93.0</span><span class="metric-unit">%</span></div>
        </div>
      </div>
      <div class="card-div-bg card-body" style="padding-top:8px;padding-bottom:8px;">
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <span style="font-size:12px;color:#3a3a3c;">落差 <span class="red" style="font-weight:700;">2.4%</span>（超過 2% 需確認資料一致性）</span>
          <span class="badge badge-red">需追查</span>
        </div>
      </div>
    </div>

    <div class="section-label">站別不良率即時排行 <span class="idx">指標78</span></div>
    <div class="card" style="padding:10px 0 6px;">
      <div class="bar-row">
        <span class="bar-name">加工站</span>
        <div class="bar-track"><div class="bar-fill" style="width:70%;background:#ff3b30;"></div></div>
        <span class="bar-val red">7.0% <i class="dot-icon dot-red"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name">彎管站</span>
        <div class="bar-track"><div class="bar-fill" style="width:39%;background:#ff9500;"></div></div>
        <span class="bar-val amber">3.9%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">裁剪站</span>
        <div class="bar-track"><div class="bar-fill" style="width:25%;background:#ff9500;"></div></div>
        <span class="bar-val amber">2.5%</span>
      </div>
      <div class="bar-row">
        <span class="bar-name">製管站</span>
        <div class="bar-track"><div class="bar-fill" style="width:18%;background:#34c759;"></div></div>
        <span class="bar-val green">1.8% <i class="dot-icon dot-green"></i></span>
      </div>
    </div>

    <div class="section-label">不良代碼 Top 5 <span class="idx">指標15·71·72</span></div>
    <div class="card" style="padding:10px 0 6px;">
      <div class="bar-row">
        <span class="bar-name w72">C-1-11 砂孔</span>
        <div class="bar-track"><div class="bar-fill" style="width:100%;background:#ff3b30;"></div></div>
        <span class="bar-val red">7次 <i class="dot-icon dot-red"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name w72">C-2-03 縮孔</span>
        <div class="bar-track"><div class="bar-fill" style="width:71%;background:#ff3b30;"></div></div>
        <span class="bar-val red">5次 <i class="dot-icon dot-red"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name w72">B-1-07 裂縫</span>
        <div class="bar-track"><div class="bar-fill" style="width:57%;background:#ff9500;"></div></div>
        <span class="bar-val amber">4次 <i class="dot-icon dot-amber"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name w72">A-3-02 毛邊</span>
        <div class="bar-track"><div class="bar-fill" style="width:43%;background:#ff9500;"></div></div>
        <span class="bar-val amber">3次 <i class="dot-icon dot-amber"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name w72">D-1-05 氣孔</span>
        <div class="bar-track"><div class="bar-fill" style="width:29%;background:#34c759;"></div></div>
        <span class="bar-val green">2次 <i class="dot-icon dot-green"></i></span>
      </div>
    </div>

    <div class="section-label">各廠品質狀態 <span class="idx">指標68·79·80</span></div>
    <div class="card">
      <div class="list-row">
        <div>
          <div class="list-main">溪州廠</div>
          <div class="list-sub">不良批次 3批 ／ 主因：砂孔（C-1-11）</div>
        </div>
        <span class="badge badge-green">98.1%</span>
      </div>
      <div class="list-row">
        <div>
          <div class="list-main">斗一廠</div>
          <div class="list-sub">不良批次 4批 ／ 主因：縮孔（C-2-03）</div>
        </div>
        <span class="badge badge-amber">96.4%</span>
      </div>
      <div class="list-row">
        <div>
          <div class="list-main">斗二廠</div>
          <div class="list-sub">不良批次 5批 ／ 主因：裂縫（B-1-07）</div>
        </div>
        <span class="badge badge-red">93.0%</span>
      </div>
    </div>

    <div class="section-label">品檢效率 <span class="idx">指標73·74·新增</span></div>
    <div class="card">
      <div class="card-row-3">
        <div class="stat-cell">
          <div class="stat-label">品保等待天數</div>
          <div class="stat-val amber">1.8天</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">RUNCARD完整率</div>
          <div class="stat-val green">97.2%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">今日檢驗批數</div>
          <div class="stat-val blue">156批</div>
        </div>
      </div>
      <div class="card-div-bg card-row-2">
        <div>
          <div class="metric-label">今日檢驗總數量</div>
          <div class="big-num"><span class="metric-val md">1,240</span><span class="metric-unit">支</span></div>
        </div>
        <div>
          <div class="metric-label">今日檢驗總重量</div>
          <div class="big-num"><span class="metric-val md">82.4</span><span class="metric-unit">噸</span></div>
        </div>
      </div>
    </div>

    <div class="section-label">本月品質績效 <span class="idx">指標79·85·139·140</span></div>
    <div class="card">
      <div class="card-row-4">
        <div class="stat-cell">
          <div class="stat-label">期間不良率</div>
          <div class="stat-val amber">3.8%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">一次良率</div>
          <div class="stat-val amber">94.2%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">不良成本</div>
          <div class="stat-val red">142萬</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">關鍵客戶異常</div>
          <div class="stat-val red">3件</div>
        </div>
      </div>
    </div>

    <div class="section-label">不良成本損失 Top 3 站別 <span class="idx">指標85·88</span></div>
    <div class="card">
      <div class="list-row">
        <div>
          <div class="list-main">加工站 · SUS304 6×200</div>
          <div class="list-sub">不良重量 3.2噸 · 動態成本 28元/kg</div>
        </div>
        <div class="list-right">
          <div style="font-size:14px;font-weight:700;" class="red">89.6萬</div>
        </div>
      </div>
      <div class="list-row">
        <div>
          <div class="list-main">彎管站 · SPHC 4×150</div>
          <div class="list-sub">不良重量 2.1噸 · 動態成本 22元/kg</div>
        </div>
        <div class="list-right">
          <div style="font-size:14px;font-weight:700;" class="amber">46.2萬</div>
        </div>
      </div>
      <div class="list-row">
        <div>
          <div class="list-main">裁剪站 · SUS430 3×120</div>
          <div class="list-sub">不良重量 0.8噸 · 動態成本 24元/kg</div>
        </div>
        <div class="list-right">
          <div style="font-size:14px;font-weight:700;" class="amber">19.2萬</div>
        </div>
      </div>
    </div>

</div>