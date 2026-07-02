<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool" %>
<%@ page import="java.util.*" %>
<%! public static final String _AppId = "BQJJ031"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>

<%

System.out.println("begDate_qry" + request.getParameter("begDate_qry"));


bqjc031 bq031 = new bqjc031(_dsCom);
 
Map[] rawDataMapArray = new Map[0];
try {
	if (_dsCom != null) {
		rawDataMapArray = bq031.getRawDataFromDB(_dsCom, request);
	}
} catch (Exception e) {
	e.printStackTrace();
}
Map dashboardData = bq031.processDashboardData(rawDataMapArray);
//展開資料供下方 HTML 使用
Map kpi = (Map) dashboardData.get("kpi");
List blackholeList = (List) dashboardData.get("blackholeList");

DecimalFormat numFmt = new DecimalFormat("#,###");

String trendMonthsJson = (String) dashboardData.get("trendMonthsJson");
String trendWeightsJson = (String) dashboardData.get("trendWeightsJson");
String trendLeadTimeJson = (String) dashboardData.get("trendLeadTimeJson");
String trendOntimeJson = (String) dashboardData.get("trendOntimeJson");

String prodLabelsJson = (String) dashboardData.get("prodLabelsJson");
String prodWeightsJson = (String) dashboardData.get("prodWeightsJson");
String prodOntimeJson = (String) dashboardData.get("prodOntimeJson");

String custLabelsJson = (String) dashboardData.get("custLabelsJson");
String custWeightsJson = (String) dashboardData.get("custWeightsJson");
String custRatesJson = (String) dashboardData.get("custRatesJson");
%>


<!DOCTYPE html>
<%@page import="com.icsc.bq.core.bqjc031"%>
<%@page import="java.text.DecimalFormat"%>
<html lang="zh-TW">
<head>
    <meta charset="cp950">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>高階主管 - 產銷與出貨績效全景戰情室</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        darkbg: '#0f172a',
                        primary: '#2563eb', 
                        success: '#10b981', 
                        warning: '#f59e0b', 
                        danger: '#ef4444'
                    }
                }
            }
        }
    </script>
    <style>
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: #f8fafc; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="bg-slate-50 font-sans text-slate-800 antialiased tracking-wide">

    <div class="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-slate-200 shadow-sm px-6 py-3 transition-all duration-300">
        <div class="w-full mx-auto flex flex-col md:flex-row justify-between items-center">
            <div>
                <h1 class="text-3xl font-bold text-slate-900 tracking-tight">
                    報表說明
                </h1>
                <p class="text-xl text-slate-500 mt-1">
                    即時資料庫抓取 | 分析基數：
                    <span class="font-bold text-slate-700"><%= kpi != null && kpi.get("totalWeight") != null ? numFmt.format(kpi.get("totalWeight")) : "0" %></span> 噸有效出貨
                    
                </p>
            </div>
            <div class="mt-3 md:mt-0 flex space-x-2">
                <button onclick="window.scrollTo({top: document.getElementById('section-trend').offsetTop - 80, behavior: 'smooth'})" class="text-xl bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 px-4 py-2 rounded-md font-semibold transition-colors shadow-sm">趨勢分析</button>
                <button onclick="window.scrollTo({top: document.getElementById('section-customer').offsetTop - 80, behavior: 'smooth'})" class="text-xl bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 px-4 py-2 rounded-md font-semibold transition-colors shadow-sm">客戶風險</button>
                <button onclick="window.scrollTo({top: document.getElementById('section-blackhole').offsetTop - 80, behavior: 'smooth'})" class="text-xl bg-red-50 border border-red-200 hover:bg-red-100 text-red-700 px-4 py-2 rounded-md font-semibold transition-colors shadow-sm">異常黑洞</button>
            </div>
        </div>
    </div>

    <div class="p-6 space-y-8 w-full mx-auto">

        <div id="section-kpi">
            <div class="flex items-center mb-4">
                <div class="w-1 h-6 bg-primary rounded-full mr-3"></div>
                <h2 class="text-2xl font-bold text-slate-800">第一層：全廠營運體檢</h2>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="bg-white rounded-xl p-5 border-t-4 border-primary shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300">
                    <p class="text-xl font-semibold text-slate-400 uppercase tracking-wider mb-2">有效出貨總重</p>
                    <div class="flex items-end space-x-1">
                        <p class="text-4xl font-black text-slate-800"><%= kpi != null ? numFmt.format(kpi.get("totalWeight")) : "0" %></p>
                        <span class="text-xl text-slate-500 font-bold mb-1">噸</span>
                    </div>
                </div>

                <div class="bg-white rounded-xl p-5 border-t-4 border-warning shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300 relative overflow-hidden">
                    <p class="text-xl font-semibold text-slate-400 uppercase tracking-wider mb-2">平均加權出貨天數</p>
                    <div class="flex items-end space-x-1">
                        <p class="text-4xl font-black text-amber-600"><%= kpi != null ? kpi.get("weightedLeadTime") : "0" %></p>
                        <span class="text-xl text-amber-500 font-bold mb-1">天</span>
                    </div>
                </div>

                <div class="bg-red-50 rounded-xl p-5 border-t-4 border-danger shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300 border border-red-100">
                    <p class="text-xl font-semibold text-red-500 uppercase tracking-wider mb-2">積壓延遲出貨金額</p>
                    <div class="flex items-end space-x-1">
                        <p class="text-4xl font-black text-red-700"><%= kpi != null ? kpi.get("delayedAmt") : "0" %></p>
                        <span class="text-xl text-red-600 font-bold mb-1">億元</span>
                    </div>
                </div>

                <div class="bg-white rounded-xl p-5 border-t-4 border-success shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300">
                    <p class="text-xl font-semibold text-slate-400 uppercase tracking-wider mb-2">整體生產達交率</p>
                    <div class="flex items-end space-x-1">
                        <p class="text-4xl font-black text-emerald-600"><%= kpi != null ? kpi.get("ontimeRate") : "0" %></p>
                        <span class="text-xl text-emerald-500 font-bold mb-1">%</span>
                    </div>
                    <p class="text-xl text-slate-500 mt-2 font-medium">遠低於製造業 95% 標準</p>
                </div>

                <div class="bg-white rounded-xl p-5 border-t-4 border-success shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300">
                    <p class="text-xl font-semibold text-slate-400 uppercase tracking-wider mb-2">內銷訂單達交率</p>
                    <div class="flex items-end space-x-1">
                        <p class="text-4xl font-black text-emerald-600"><%= kpi != null ? kpi.get("domesticOntime") : "0" %></p>
                        <span class="text-xl text-emerald-500 font-bold mb-1">%</span>
                    </div>
                    <p class="text-xl text-slate-500 mt-2 font-medium">顯示產能偏向滿足國內需求</p>
                </div>

                <div class="bg-white rounded-xl p-5 border-t-4 border-danger shadow-sm hover:shadow-md hover:-translate-y-1 transition-all duration-300">
                    <p class="text-xl font-semibold text-slate-400 uppercase tracking-wider mb-2">外銷訂單達交率</p>
                    <div class="flex items-end space-x-1">
                        <p class="text-4xl font-black text-red-600"><%= kpi != null ? kpi.get("exportOntime") : "0" %></p>
                        <span class="text-xl text-red-500 font-bold mb-1">%</span>
                    </div>
                    <p class="text-xl text-slate-500 mt-2 font-medium">顯示主要外銷訂單被嚴重延遲</p>
                </div>
            </div>
        </div>

        <div id="section-trend">
            <div class="flex items-center mb-4">
                <div class="w-1 h-6 bg-primary rounded-full mr-3"></div>
                <h2 class="text-2xl font-bold text-slate-800">第二層：產能與出貨天數推移</h2>
            </div>
            
            <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                <div class="relative h-[320px] w-full">
                    <canvas id="trendChart"></canvas>
                </div>
                <div class="bg-slate-50 border border-slate-100 p-4 mt-6 text-xl text-slate-600 rounded-lg">
                    趨勢解讀：產能維持高峰時，出貨天數相對平穩。當出貨量暴跌時，出貨天數卻飆升，代表當月出貨的大量訂單都是極度陳舊的積壓單（清庫存效應）。
                </div>
            </div>
        </div>

        <div id="section-customer" class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            
            <div class="bg-white rounded-xl shadow-sm border border-slate-200 flex flex-col overflow-hidden">
                <div class="px-6 py-4 border-b border-slate-100 bg-slate-50/50">
                    <h3 class="text-2xl font-bold text-slate-800">產品線出貨量與達交率矩陣</h3>
                </div>
                <div class="p-6 relative h-[300px] w-full">
                    <canvas id="productChart"></canvas>
                </div>
                <div class="px-6 py-4 bg-slate-50 border-t border-slate-100 text-xl text-slate-600">
                    管理說明：部分產品處於全面違約狀態，需查核後加工瓶頸站點。
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border border-slate-200 flex flex-col overflow-hidden">
                <div class="px-6 py-4 border-b border-red-100 bg-red-50/30">
                    <h3 class="text-2xl font-bold text-red-800">巨頭客戶延遲風險 (前五大延遲噸數)</h3>
                </div>
                <div class="p-6 relative h-[300px] w-full">
                    <canvas id="customerChart"></canvas>
                </div>
                <div class="px-6 py-4 bg-red-50/50 border-t border-red-100 text-xl text-red-800">
                    管理說明：部分巨頭客戶的延遲噸數與違約率過高，若容忍度耗盡將引發抽單危機。
                </div>
            </div>

        </div>

        <div id="section-blackhole">
            <div class="flex items-center mb-4">
                <div class="w-1 h-6 bg-danger rounded-full mr-3"></div>
                <h2 class="text-2xl font-bold text-slate-800">第三層：管理盲區 - 極端異常黑洞訂單追蹤</h2>
            </div>
            
            <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="px-6 py-4 border-b border-slate-200 bg-slate-800 flex justify-between items-center">
                    <h3 class="text-xl font-bold text-white tracking-wide">系統未結案或髒資料清單</h3>
                    <span class="text-xl text-slate-400">延遲大於 300 天</span>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xl whitespace-nowrap">
                        <thead class="bg-slate-50 text-slate-600 border-b border-slate-200">
                            <tr>
                                <th class="px-6 py-4 font-semibold">訂單號碼</th>
                                <th class="px-6 py-4 font-semibold">客戶簡稱</th>
                                <th class="px-6 py-4 font-semibold">銷別 / 產品</th>
                                <th class="px-6 py-4 font-semibold text-right">出貨金額</th>
                                <th class="px-6 py-4 font-semibold text-center text-red-600">延遲天數</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 bg-white">
                            <% 
                                if(blackholeList != null && blackholeList.size() > 0) {
                                    for(int i = 0; i < blackholeList.size(); i++) { 
                                        Map row = (Map) blackholeList.get(i);
                            %>
                                <tr class="hover:bg-slate-50 transition-colors duration-150">
                                    <td class="px-6 py-4 font-mono font-medium text-slate-800"><%= row.get("訂單號碼") %></td>
                                    <td class="px-6 py-4 text-slate-700 font-medium"><%= row.get("客戶簡稱") %></td>
                                    <td class="px-6 py-4 text-slate-600"><%= row.get("銷別") %> / <%= row.get("產品大類") %></td>
                                    <td class="px-6 py-4 text-right text-slate-600 font-mono">NT$ <%= numFmt.format(row.get("出貨金額")) %></td>
                                    <td class="px-6 py-4 text-center">
                                        <span class="inline-block bg-red-100 text-red-700 font-bold px-3 py-1 rounded-full text-xl">
                                            <%= row.get("延遲天數") %> 天
                                        </span>
                                    </td>
                                </tr>
                            <% 
                                    } 
                                } else { 
                            %>
                                <tr><td colspan="5" class="text-center py-8 text-slate-400">目前無嚴重延遲訂單</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <div class="h-12"></div>
    </div>

    <script>
        Chart.defaults.font.family = "'Segoe UI', 'Microsoft JhengHei', sans-serif";
        Chart.defaults.color = '#64748b';

        const trendLabels = <%= trendMonthsJson != null ? trendMonthsJson : "[]" %>;
        const trendLeadTime = <%= trendLeadTimeJson != null ? trendLeadTimeJson : "[]" %>;
        const trendOntime = <%= trendOntimeJson != null ? trendOntimeJson : "[]" %>;
        const trendWeight = <%= trendWeightsJson != null ? trendWeightsJson : "[]" %>;

        const prodLabels = <%= prodLabelsJson != null ? prodLabelsJson : "[]" %>;
        const prodWeights = <%= prodWeightsJson != null ? prodWeightsJson : "[]" %>;
        const prodOntime = <%= prodOntimeJson != null ? prodOntimeJson : "[]" %>;

        const custLabels = <%= custLabelsJson != null ? custLabelsJson : "[]" %>;
        const custWeights = <%= custWeightsJson != null ? custWeightsJson : "[]" %>;
        const custRates = <%= custRatesJson != null ? custRatesJson : "[]" %>;

        window.onload = function() {
            
            if(trendLabels.length > 0) {
                const ctxTrend = document.getElementById('trendChart').getContext('2d');
                new Chart(ctxTrend, {
                    type: 'bar',
                    data: {
                        labels: trendLabels,
                        datasets: [
                            {
                                type: 'line', label: '加權出貨天數', data: trendLeadTime,
                                borderColor: '#f59e0b', backgroundColor: '#f59e0b',
                                borderWidth: 3, yAxisID: 'y1', tension: 0.3, pointRadius: 4
                            },
                            {
                                type: 'line', label: '生產達交率 (%)', data: trendOntime,
                                borderColor: '#ef4444', backgroundColor: '#ef4444', borderDash: [5, 5],
                                borderWidth: 3, yAxisID: 'y2', tension: 0.3, pointRadius: 4
                            },
                            {
                                type: 'bar', label: '當月出貨量 (噸)', data: trendWeight,
                                backgroundColor: '#cbd5e1', hoverBackgroundColor: '#94a3b8',
                                borderRadius: 4, barPercentage: 0.6, yAxisID: 'y'
                            }
                        ]
                    },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        interaction: { mode: 'index', intersect: false },
                        plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 20 } } },
                        scales: {
                            x: { grid: { display: false } },
                            y: { display: true, position: 'left', title: { display: true, text: '出貨量 (噸)' }, border: { dash: [4, 4] } },
                            y1: { display: true, position: 'right', title: { display: true, text: '天數' }, min: 60, grid: { drawOnChartArea: false } },
                            y2: { display: false, position: 'right', min: 50, max: 100 }
                        }
                    }
                });
            }

            if(prodLabels.length > 0) {
                const ctxProduct = document.getElementById('productChart').getContext('2d');
                new Chart(ctxProduct, {
                    type: 'bar',
                    data: {
                        labels: prodLabels,
                        datasets: [
                            {
                                type: 'line', label: '該產品達交率 (%)', data: prodOntime,
                                borderColor: '#8b5cf6', backgroundColor: '#8b5cf6',
                                borderWidth: 3, yAxisID: 'y1', pointRadius: 4
                            },
                            {
                                type: 'bar', label: '總出貨重量 (噸)', data: prodWeights,
                                backgroundColor: '#e2e8f0', hoverBackgroundColor: '#cbd5e1',
                                borderRadius: 4, barPercentage: 0.5, yAxisID: 'y'
                            }
                        ]
                    },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 20 } } },
                        scales: {
                            x: { grid: { display: false } },
                            y: { display: true, position: 'left', title: { display: true, text: '總出貨重量 (噸)' }, border: { dash: [4, 4] } },
                            y1: { display: true, position: 'right', title: { display: true, text: '達交率 (%)' }, min: 0, max: 105, grid: { drawOnChartArea: false } }
                        }
                    }
                });
            }

            if(custLabels.length > 0) {
                const ctxCustomer = document.getElementById('customerChart').getContext('2d');
                new Chart(ctxCustomer, {
                    type: 'bar',
                    data: {
                        labels: custLabels,
                        datasets: [
                            {
                                type: 'line', label: '客戶遭違約率 (%)', data: custRates,
                                borderColor: '#ef4444', backgroundColor: '#ef4444',
                                borderWidth: 3, yAxisID: 'y1', borderDash: [5, 5], pointRadius: 4
                            },
                            {
                                type: 'bar', label: '遭延遲總重量 (噸)', data: custWeights,
                                backgroundColor: '#bfdbfe', hoverBackgroundColor: '#93c5fd',
                                borderRadius: 4, barPercentage: 0.5, yAxisID: 'y'
                            }
                        ]
                    },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 20 } } },
                        scales: {
                            x: { grid: { display: false }, ticks: { font: { size: 10 } } },
                            y: { display: true, position: 'left', title: { display: true, text: '延遲噸數 (Ton)' }, border: { dash: [4, 4] } },
                            y1: { display: true, position: 'right', title: { display: true, text: '違約率 (%)' }, min: 0, max: 105, grid: { drawOnChartArea: false } }
                        }
                    }
                });
            }

        };
    </script>
</body>
</html>
 