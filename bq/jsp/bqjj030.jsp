<%@ page contentType = "text/html;charset=cp950"%> 
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>
<%@ page import="java.math.BigDecimal"%>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool"%>
<%! public static final String _AppId = "BQJJ029"; %>
<%@ include file="../../jsp/dzjjMenuHeader.jsp" %>

<%! 
public List getDatas(dsjccom dsCom)throws Exception {
	aajcYCATool aaTool = new aajcYCATool();
	
	String sql =
		" SELECT *, CASE WHEN a.MANUDIAI=a.PIPEDIAMETER AND a.MANUDIAII=a.PIPEDIAMETER2 THEN 'Y' ELSE 'N' END AS RUNNING FROM (" +
		" 	SELECT " +
		" 		a.MACHINE, a.PIPEDIAMETER, a.PIPEDIAMETER2," +
		" 		a.MANUDIAI, a.MANUDIAII," +
		" 		SUM(a.總待排數量) AS TOTAL," +
		" 		SUM(a.THISMONTH) AS THISMONTH," +
		" 		SUM(a.NEXT1MONTH) AS NEXT1MONTH," +
		" 		SUM(a.NEXT2MONTH) AS NEXT2MONTH," +
		"       SUM(a.THISMONTH+a.NEXT1MONTH+a.NEXT2MONTH) AS TOTALHR " +
		" 	FROM DB.TBWYPORDERLACK_SPEC a " +
		" 	WHERE a.FACTORY='B' AND a.MACHINE='BF32' " +
		" 	GROUP BY a.MACHINE, a.PIPEDIAMETER, a.PIPEDIAMETER2, a.MANUDIAI, a.MANUDIAII" +
		" ) a" +
		" ORDER BY a.MACHINE," +
		" CASE WHEN a.MANUDIAI=a.PIPEDIAMETER AND a.MANUDIAII=a.PIPEDIAMETER2 THEN 999" +
		" ELSE a.THISMONTH END DESC, a.NEXT1MONTH DESC, a.NEXT2MONTH DESC" +
		" WITH UR ";
	Map[] jobs = new dejcQueryDAO(dsCom).getDatas(sql.toString());
	
	//組成畫面需要的資料
	Map totLoading = new HashMap();
	List<Map<String, Object>> bars = new ArrayList();
	for(int i = 0; i < jobs.length; i++){
		Map job = jobs[i];
		String machine = aaTool.getStr(job.get("MACHINE"));
		String size = aaTool.format(job.get("PIPEDIAMETER"), "###.#") + "x" + aaTool.format(job.get("PIPEDIAMETER2"), "###.#");
		double loading = aaTool.getBigDecimal((job.get("TOTALHR"))).doubleValue();
		
		//累計時間
	    double totTime = aaTool.getBigDecimal((totLoading.get(machine))).doubleValue();
	    if(!totLoading.containsKey(machine))
	    	totTime = 0;
		
	    Map bar = new HashMap();
		//非執行中的，要增加一個換模具時間
		if("N".equals(aaTool.getStr(job.get("RUNNING")))){
		    bar.put("label", "換模"); 						// 標籤（可顯示在圖例中）
		    bar.put("y", machine + " - " + size); 			// Y 軸標籤：機台名稱 + 尺寸
		    bar.put("x_start", totTime); 					// 換模開始時間（小時）
		    bar.put("x_end", totTime + 24); 					// 換模結束時間（小時）
		    bar.put("color", "rgba(239, 68, 68, 0.8)"); 	// 換模顏色（紅色半透明）
		    bar.put("text", ""); 							// 顯示在 bar 上的文字
		    bars.add(bar);			
		    totTime += 24;
		}

	    bar = new HashMap(); 			// 下一個產品工單
	    bar.put("label", size); 						// 標籤（可顯示在圖例中）
	    bar.put("y", machine + " - " + size); 			// Y 軸標籤：機台名稱 + 尺寸
	    bar.put("x_start", 0); 							// 生產開始時間（接續換模）
	    bar.put("x_end", loading); 						// 生產結束時間（假設工時為 10 小時）
	    bar.put("color", "rgba(59, 130, 246, 0.8)"); 	// 工單顏色（藍色）
	    bar.put("text", size); 							// 顯示在 bar 上的文字
	    bars.add(bar);				
	    totTime += loading;		
	    
	    totLoading.put(machine, totTime);
	}
	return bars;
}
%>


<%
	//從 Controller 傳入的是 List<Map<String, Object>>
	//List<Map<String, Object>> bars = 測試資料();
	List<Map<String, Object>> bars = getDatas(_dsCom);
	    
    JSONArray jsonBars = new JSONArray(); 		// 用來存放前端 Chart.js 要用的 bar JSON 資料
    Set<String> labelSet = new LinkedHashSet(); // 收集 Y 軸上所有出現過的「機台 + 尺寸」標籤（順序不重複）

    for (Map<String, Object> bar : bars) {
        JSONObject obj = new JSONObject(bar); 	// 將每筆 bar 資料轉為 JSON 格式
        jsonBars.put(obj); 						// 加入 JSON 陣列中
        labelSet.add((String) bar.get("y")); 	// 收集 Y 軸標籤（例如 BF37 - 12.0x0）
    }

    JSONArray labelArray = new JSONArray(labelSet); // 將 Set 轉為 JSON 陣列，供 Chart.js 使用
%>

<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <title>工單排產甘特圖</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-6">
    <div class="max-w-6xl mx-auto bg-white p-6 rounded-xl shadow-xl">
        <h1 class="text-2xl font-bold text-center mb-6 text-gray-800">工單排產甘特圖</h1>
        <div class="overflow-y-auto" style="max-height: 600px;">
            <canvas id="ganttChart"></canvas>
        </div>
    </div>

    <script>
        const labels = <%= labelArray.toString() %>;
        const bars = <%= jsonBars.toString() %>;

        const datasets = bars.map(bar => ({
            label: bar.label,
            data: [{ x: [bar.x_start, bar.x_end], y: bar.y }],
            backgroundColor: bar.color,
            datalabels: {
                display: !!bar.text,
                anchor: 'center',
                align: 'center',
                formatter: () => bar.text,
                color: 'white',
                font: { weight: 'bold' }
            }
        }));

        new Chart(document.getElementById('ganttChart').getContext('2d'), {
            type: 'bar',
            data: { labels, datasets },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    datalabels: { display: true }
                },
                scales: {
                    x: {
                        stacked: true,
                        title: { display: true, text: '時間（小時）' }
                    },
                    y: {
                        stacked: true,
                        title: { display: true, text: '機台 + 尺寸' }
                    }
                }
            },
            plugins: [ChartDataLabels]
        });
    </script>
</body>
</html>

<%! 
public List 測試資料() {
    // 宣告 Map 陣列
    List bars = new ArrayList();

    Map bar = new HashMap(); 		// 第 1 筆：換模資料
    bar.put("label", "換模"); 		// 標籤（可顯示在圖例中）
    bar.put("y", "BF37 - 12.0x0"); 	// Y 軸標籤：機台名稱 + 尺寸
    bar.put("x_start", 0); 			// 換模開始時間（小時）
    bar.put("x_end", 2); 			// 換模結束時間（小時）
    bar.put("color", "rgba(239, 68, 68, 0.8)"); // 換模顏色（紅色半透明）
    bar.put("text", "換模"); 		// 顯示在 bar 上的文字
    bars.add(bar);

    bar = new HashMap(); 			// 第 2 筆：產品工單
    bar.put("label", "12.0x0"); 	// 標籤（尺寸）
    bar.put("y", "BF37 - 12.0x0"); 	// 同樣是 BF37 機台，尺寸為 12.0x0
    bar.put("x_start", 0); 			// 生產開始時間（接在前一筆換模後）
    bar.put("x_end", 14.7); 		// 生產結束時間（共 14.7 小時）
    bar.put("color", "rgba(59, 130, 246, 0.8)"); // 工單顏色（藍色）
    bar.put("text", "12.0x0"); 		// 顯示在 bar 上的文字
    bars.add(bar);
    
    //
    bar = new HashMap(); 			// 第 3 筆：再次換模
    bar.put("label", "換模"); 		// 標籤為換模
    bar.put("y", "BF37 - 10.0x0"); 	// 機台尺寸相同（實際應該改為不同尺寸）
    bar.put("x_start", 16.7); 		// 換模開始時間（接續上個工單後）
    bar.put("x_end", 18.7);			// 換模結束時間（2 小時）
    bar.put("color", "rgba(239, 68, 68, 0.8)"); // 換模顏色
    bar.put("text", "換模"); 		// 顯示換模文字
    bars.add(bar);

    bar = new HashMap(); 			// 第 4 筆：下一個產品工單
    bar.put("label", "10.0x0"); 	// 標籤（產品尺寸）
    bar.put("y", "BF37 - 10.0x0"); 	// 機台與尺寸標示
    bar.put("x_start", 0); 		// 生產開始時間（接續換模）
    bar.put("x_end", 10); 		// 生產結束時間（假設工時為 10 小時）
    bar.put("color", "rgba(59, 130, 246, 0.8)"); // 工單顏色（藍色）
    bar.put("text", "10.0x0"); 		// 顯示在 bar 上的文字
    bars.add(bar);

    return bars;
}
%>
