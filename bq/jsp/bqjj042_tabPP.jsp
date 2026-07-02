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

    <div class="section-label">應開工未開工 <span class="idx">指標9·10·38·新增</span></div>
    <div class="card">
      <div class="card-row-4">
        <div class="stat-cell">
          <div class="stat-label">未開工單</div>
          <div class="stat-val red">4張</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">未開重量</div>
          <div class="stat-val red">65噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">未開數量</div>
          <div class="stat-val red">350支</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">占計畫%</div>
          <div class="stat-val red">20.3%</div>
        </div>
      </div>
      <div class="card-div-bg prog-section">
        <div class="prog-header">
          <span>未開工重量占今日計畫</span>
          <span class="val" style="color:#ff3b30;">20.3% <i class="dot-icon dot-red"></i> ／ 警戒 >=10%</span>
        </div>
        <div class="prog-track" style="margin-bottom:0;">
          <div class="prog-fill" style="width:20.3%;background:#ff3b30;"></div>
        </div>
      </div>
    </div>

    <div class="section-label">預計完工未完工 <span class="idx">指標11·12·新增</span></div>
    <div class="card">
      <div class="card-row-4">
        <div class="stat-cell">
          <div class="stat-label">未完工單</div>
          <div class="stat-val red">4張</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">未完重量</div>
          <div class="stat-val amber">95噸</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">未完數量</div>
          <div class="stat-val amber">400支</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">占計畫%</div>
          <div class="stat-val red">40%</div>
        </div>
      </div>
      <div class="card-div-bg prog-section">
        <div class="prog-header">
          <span>未完工工單占今日計畫</span>
          <span class="val" style="color:#ff3b30;">40% <i class="dot-icon dot-red"></i> ／ 警戒 >=15%</span>
        </div>
        <div class="prog-track" style="margin-bottom:0;">
          <div class="prog-fill" style="width:40%;background:#ff3b30;"></div>
        </div>
      </div>
    </div>

    <div class="section-label">逾期工單老化分析 <span class="idx">指標49·50·58</span></div>
    <div class="card">
      <div class="card-row-2">
        <div>
          <div class="metric-label">逾期開工平均天數</div>
          <div class="big-num"><span class="metric-val md red">4.2</span><span class="metric-unit">天</span></div>
          <div style="font-size:10px;color:#ff3b30;margin-top:3px;">最長 8天 <i class="dot-icon dot-red"></i></div>
        </div>
        <div>
          <div class="metric-label">逾期完工平均天數</div>
          <div class="big-num"><span class="metric-val md red">5.8</span><span class="metric-unit">天</span></div>
          <div style="font-size:10px;color:#ff3b30;margin-top:3px;">最長 12天 <i class="dot-icon dot-red"></i></div>
        </div>
      </div>
      <div class="card-div card-body">
        <div class="metric-label" style="margin-bottom:6px;">應開未開老化分布 <span class="idx">指標58</span></div>
        <div class="bar-row" style="padding:0 0 4px 0;border-top:none;">
          <span class="bar-name">1-3天</span>
          <div class="bar-track"><div class="bar-fill" style="width:50%;background:#ff9500;"></div></div>
          <span class="bar-val amber">2張</span>
        </div>
        <div class="bar-row" style="padding:4px 0 4px 0;">
          <span class="bar-name">4-7天</span>
          <div class="bar-track"><div class="bar-fill" style="width:25%;background:#ff3b30;"></div></div>
          <span class="bar-val red">1張</span>
        </div>
        <div class="bar-row" style="padding:4px 0 0 0;">
          <span class="bar-name">&gt;7天</span>
          <div class="bar-track"><div class="bar-fill" style="width:25%;background:#8e0000;"></div></div>
          <span class="bar-val red">1張 <i class="dot-icon dot-red"></i></span>
        </div>
      </div>
    </div>

    <div class="section-label">在製 WIP 水位 <span class="idx">指標13·14</span></div>
    <div class="card" style="padding:10px 0 6px;">
      <div class="bar-row">
        <span class="bar-name">製管站</span>
        <div class="bar-track"><div class="bar-fill" style="width:95%;background:#ff9500;"></div></div>
        <span class="bar-val amber">190% <i class="dot-icon dot-amber"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name">加工站</span>
        <div class="bar-track"><div class="bar-fill" style="width:93%;background:#ff9500;"></div></div>
        <span class="bar-val amber">187% <i class="dot-icon dot-amber"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name">彎管站</span>
        <div class="bar-track"><div class="bar-fill" style="width:55%;background:#34c759;"></div></div>
        <span class="bar-val green">110% <i class="dot-icon dot-green"></i></span>
      </div>
      <div class="bar-row">
        <span class="bar-name">裁剪站</span>
        <div class="bar-track"><div class="bar-fill" style="width:45%;background:#34c759;"></div></div>
        <span class="bar-val green">90% <i class="dot-icon dot-green"></i></span>
      </div>
      <div style="padding:6px 14px 0;font-size:10px;color:#8e8e93;">*WIP% = 當前在製 / 站別日均值，>200% 觸發紅燈</div>
    </div>
    <div class="card">
      <div class="card-row-3">
        <div class="stat-cell">
          <div class="stat-label">加工站在製</div>
          <div class="stat-val amber">28張</div>
          <div style="font-size:10px;color:#ff9500;">187%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">製管站在製</div>
          <div class="stat-val green">22張</div>
          <div style="font-size:10px;color:#34c759;">88%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">裁剪站在製</div>
          <div class="stat-val green">14張</div>
          <div style="font-size:10px;color:#34c759;">70%</div>
        </div>
      </div>
    </div>

    <div class="section-label">短期產能負荷預警 <span class="idx">指標48·136</span></div>
    <div class="card">
      <div class="card-body">
        <div class="metric-label">當月負荷率</div>
        <div class="big-num"><span class="metric-val md amber">88</span><span class="metric-unit">%</span></div>
      </div>
      <div class="card-div-bg prog-section">
        <div class="prog-header">
          <span>5月已排工時 ／ 可用產能</span>
          <span class="val amber">88%</span>
        </div>
        <div class="prog-track" style="margin-bottom:10px;">
          <div class="prog-fill" style="width:88%;background:#ff9500;"></div>
        </div>
        <div class="prog-header">
          <span>6月已排工時 ／ 可用產能</span>
          <span class="val green">62%</span>
        </div>
        <div class="prog-track" style="margin-bottom:0;">
          <div class="prog-fill" style="width:62%;background:#34c759;"></div>
        </div>
      </div>
    </div>

    <div class="section-label">排程準確率 <span class="idx">指標53·63·125·126</span></div>
    <div class="card">
      <div class="card-row-2">
        <div>
          <div class="metric-label">期間開工達成率</div>
          <div class="big-num"><span class="metric-val md amber">76</span><span class="metric-unit">%</span></div>
        </div>
        <div>
          <div class="metric-label">期間完工達成率</div>
          <div class="big-num"><span class="metric-val md red">61</span><span class="metric-unit">%</span></div>
        </div>
      </div>
      <div class="card-div-bg card-row-2">
        <div>
          <div class="metric-label">排程準確率（完工日）</div>
          <div class="big-num"><span class="metric-val md amber">78</span><span class="metric-unit">%</span></div>
        </div>
        <div>
          <div class="metric-label">逾期工單占比</div>
          <div class="big-num"><span class="metric-val md red">38</span><span class="metric-unit">%</span></div>
        </div>
      </div>
    </div>

    <div class="section-label">工單週轉天數 <span class="idx">指標56·57·62</span></div>
    <div class="card">
      <div class="card-row-3">
        <div class="stat-cell">
          <div class="stat-label">平均週轉天數</div>
          <div class="stat-val amber">6.8天</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">最長週轉</div>
          <div class="stat-val red">14天</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">目標天數</div>
          <div class="stat-val gray">5天</div>
        </div>
      </div>
      <div class="card-div card-body" style="padding-top:8px;padding-bottom:8px;">
        <div class="metric-label" style="margin-bottom:4px;">最長週轉料種</div>
        <div style="font-size:12px;color:#3a3a3c;">SUS304 厚6mm 寬200mm → 平均 <span class="red">9.2天</span></div>
      </div>
    </div>

    <div class="section-label">機台產出效率 <span class="idx">指標7·61</span></div>
    <div class="card" style="padding:10px 0 6px;">
      <div class="bar-row">
        <span class="bar-name w48">MF01</span>
        <div class="bar-track"><div class="bar-fill" style="width:100%;background:#34c759;"></div></div>
        <span class="bar-val green">2.6T/h</span>
      </div>
      <div class="bar-row">
        <span class="bar-name w48">DF01</span>
        <div class="bar-track"><div class="bar-fill" style="width:88%;background:#34c759;"></div></div>
        <span class="bar-val green">2.3T/h</span>
      </div>
      <div class="bar-row">
        <span class="bar-name w48">BS02</span>
        <div class="bar-track"><div class="bar-fill" style="width:58%;background:#ff9500;"></div></div>
        <span class="bar-val amber">1.5T/h</span>
      </div>
      <div class="bar-row">
        <span class="bar-name w48">BM01</span>
        <div class="bar-track"><div class="bar-fill" style="width:46%;background:#ff3b30;"></div></div>
        <span class="bar-val red">1.2T/h</span>
      </div>
      <div class="bar-row">
        <span class="bar-name w48">BF01</span>
        <div class="bar-track"><div class="bar-fill" style="width:31%;background:#ff3b30;"></div></div>
        <span class="bar-val red">0.8T/h</span>
      </div>
    </div>

    <div class="section-label">本月生管績效指標 <span class="idx">指標125·126·132·133</span></div>
    <div class="card">
      <div class="card-row-4">
        <div class="stat-cell">
          <div class="stat-label">產出達成率</div>
          <div class="stat-val amber">85%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">稼動績效</div>
          <div class="stat-val amber">72%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">逾期工單%</div>
          <div class="stat-val red">38%</div>
        </div>
        <div class="stat-cell">
          <div class="stat-label">閒置機台</div>
          <div class="stat-val amber">2台</div>
        </div>
      </div>
    </div>

</div>