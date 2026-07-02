<%@ page contentType = "text/html;charset=cp950"%>
<%@ page import="com.icsc.dpms.de.*" %>
<%@ page import="com.icsc.dpms.de.web.*" %>
<%@ page import="com.icsc.dpms.de.structs.web.*" %>
<%@ page import="com.icsc.dpms.de.dejcQueryDAO"%>
<%@ page import="java.util.*" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.icsc.aa.yc.util.aajcYCATool"%>
<%! public static final String _AppId = "BQJJ026"; %>
<%@ include file="../../jsp/dzjjMainHeader.jsp" %>
<%

	aajcYCATool aaTool = new aajcYCATool();

	//判斷是否已有資料，若沒有就塞測試資料
	if (request.getAttribute("Blocks") == null) {
		injectTestData(request);							//直接塞測試資料就可以模擬了
	}

	//組合大MAP，以便顯示--給script用	
	Map[] Blocks = (Map[]) request.getAttribute("Blocks");
	Map locXSize = (Map) request.getAttribute("locXSize");
	Map locYSize = (Map) request.getAttribute("locYSize");
	Map ihx = (Map) request.getAttribute("ihx");
	Map stockNum = (Map) request.getAttribute("stockNum");
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
	<title>倉庫管理 Dashboard + 2D 倉儲</title>
  	<script type="text/javascript" src="/erp/html/bq/chart.js"></script>
	<script src="https://cdn.tailwindcss.com"></script>
	<style>
		body {
			margin: 0;
			background: #f9fafb;
		}
		.cell {
		  	position: relative;
			width: 32px;
			height: 32px;
			margin: 2px;
			display: inline-flex;
			align-items: center;
			justify-content: center;
			border-radius: 4px;
			font-size: 12px;
			color: white;
			cursor: pointer;
		}
	</style>
</head>
<body class="p-4 font-sans">
	<h1 class="text-3xl font-bold mb-4">倉庫管理 Dashboard-------</h1>

	<!-- 倉儲區域切換 -->
	<div class="bg-white p-4 rounded-xl shadow-md mb-6">
		<h2 class="text-xl font-semibold mb-4">倉儲分區（點擊顯示 2D）</h2>
		<div class="grid grid-cols-5 gap-4 text-center">
		<%
			String style="";
			for (int i = 0; i < Blocks.length; i++) {
				String block = aaTool.getStr(Blocks[i].get("BLOCK"));
				switch (i % 5) {
				    case 1: style = "bg-green"; 	break;
				    case 2: style = "bg-yellow"; 	break;
				    case 3: style = "bg-blue"; 		break;
				    case 4: style = "bg-red"; 		break;
				    default: style = "bg-orange"; 	break;
				}
		%>
			<div onclick="render2D('<%=block%>')" class="<%=style%>-300 p-4 rounded-lg cursor-pointer hover:<%=style%>-400"> <%=block%> 棟</div>
		<%} %>			
			
		</div>
	</div>
	
	<!-- 2D 倉儲圖區塊 -->
	<div class="bg-white p-4 rounded-xl shadow-md">
		<h2 class="text-xl font-semibold mb-4">倉儲平面圖</h2>
		<div class="relative flex">
			<!-- 左側 70% 倉儲圖（主導高度） -->
			<div id="warehouse2D" class="w-[70%] flex flex-col items-center">
				<!-- 模擬內容高度 -->
				<div class="w-full h-[600px] bg-gray-100">這是倉儲圖內容</div>
			</div>
	
			<!-- 右側 30% 包裝容器，position 相對於左側高度 -->
			<div class="w-[30%] relative">
				<!-- 固定高度、右側 scroll -->
				<div id="infoBox" class="absolute top-0 left-0 right-0 bottom-0 overflow-auto p-4 bg-gray-50 border-l border-gray-300 text-sm font-mono whitespace-pre-line text-gray-900">
				庫存明細
				</div>
			</div>
		</div>
	</div>
	
	
	<!-- Dashboard Cards -->
	<div class="grid grid-cols-3 gap-4 mb-6">
		<div class="bg-white p-4 rounded-xl shadow-md">
			<h2 class="text-xl font-semibold mb-2">庫存總覽</h2>
			<canvas id="inventoryGauge"></canvas>
		</div>
		<div class="bg-white p-4 rounded-xl shadow-md col-span-2">
			<h2 class="text-xl font-semibold mb-2">異常警示</h2>
			<ul class="list-disc ml-5 text-red-600">
				<li>原料 A 剩餘量低於警戒值（目前：120kg）</li>
				<li>成品 C 出貨延遲超過 3 天</li>
			</ul>
		</div>
	</div>

<script>
<!-- 轉換每個棟的儲區 -->
const locXSize = <%=new ObjectMapper().writeValueAsString(locXSize)%>;
const locYSize = <%=new ObjectMapper().writeValueAsString(locYSize)%>;
const stockCounts = <%=new ObjectMapper().writeValueAsString(stockNum)%>;
const stockDetails = <%=new ObjectMapper().writeValueAsString(ihx)%>;

<!-- Chart.js 儀表板 -->
new Chart(document.getElementById('inventoryGauge'), {
	type: 'doughnut',
	data: {
		labels: ['已用容量', '剩餘容量'],
		datasets: [{
			data: [30, 70],
			backgroundColor: ['#3b82f6', '#e5e7eb']
		}]
	},
	options: {
		cutout: '30%',
		plugins: {
			legend: { display: false }
		}
	}
});

<!-- 2D 倉儲渲染 -->
function render2D(area) {
	const container = document.getElementById("warehouse2D");
	container.innerHTML = '';

	const locY = locXSize[area]; // 注意你的是 Y 在前
	const locX = locYSize[area];

	const rows = locY.length;
	const cols = locX.length;

	let selectedCell = null;

	// 建立一個外層表格容器
	const table = document.createElement("div");
	table.style.display = "inline-block";

	// 第一行：空格 + X 座標
	const headerRow = document.createElement("div");
	headerRow.style.display = "flex";

	const corner = document.createElement("div");
	corner.style.width = "32px";
	corner.style.height = "32px";
	headerRow.appendChild(corner);

	for (let c = 0; c < cols; c++) {
		const xLabel = document.createElement("div");
		xLabel.className = "cell";
		xLabel.style.backgroundColor = "#e5e7eb";
		xLabel.style.color = "#111";
		xLabel.textContent = locX[c];
		headerRow.appendChild(xLabel);
	}
	table.appendChild(headerRow);

	// 接下來每列：Y 標籤 + 儲位格
	for (let r = 0; r < rows; r++) {
		const row = document.createElement("div");
		row.style.display = "flex";

		// Y 座標標籤
		const yLabel = document.createElement("div");
		yLabel.className = "cell";
		yLabel.style.backgroundColor = "#e5e7eb";
		yLabel.style.color = "#111";
		yLabel.textContent = locY[r];
		row.appendChild(yLabel);

		for (let c = 0; c < cols; c++) {
			const div = document.createElement("div");
			const key = area + locY[r] + locX[c];
			
			
			const count = stockCounts[key] || 0;
			const isFilled = count > 0;
			div.className = "cell flex items-center justify-center text-xs text-white";
			div.style.backgroundColor = isFilled ? '#4c9aff' : '#9ca3af';
			div.textContent = count;
			
			if (stockCounts[key] === undefined) {
				//沒有這個儲區顯示空白
				div.style.backgroundColor = "#e5e7eb"; // 淺灰
				div.textContent = "";
			} 

			// 點擊顯示 info
			div.addEventListener('click', function () {
				const infoBox = document.getElementById('infoBox');

				if (selectedCell) {
					selectedCell.classList.remove("selected");
				}
				selectedCell = div;
				div.classList.add("selected");

				let tipText = key + "\n";
				const detailList = stockDetails[key];

				if (detailList && detailList.length > 0) {
					tipText += detailList.map(item => {
						const weight = parseFloat(item.WGT);
						const formatted = weight.toLocaleString(undefined, { maximumFractionDigits: 0 });
						return `ID: ${item.ID}\n重量: ${formatted} kg`;
					}).join('\n\n');
				} else if(stockCounts[key] === undefined){
					tipText = "";
				}else {
					tipText += "無資料";
				}

				infoBox.textContent = tipText;
			});
			//畫格子
			row.appendChild(div);
		}
		//畫整列
		table.appendChild(row);
	}
	//畫表格
	container.appendChild(table);
}
</script>

<script>
// 預設載入第一筆
<%if(Blocks.length > 0){%>
	render2D('<%=Blocks[0].get("BLOCK")%>');
<%}%>
</script>
</body>
</html>

<%! 
public static void injectTestData(javax.servlet.http.HttpServletRequest request) {
	try {
		//塞BLOCK，X、Y軸母體
		List<Map<String, String>> blocksList = new ArrayList();
		blocksList.add(new HashMap() {{ put("BLOCK", "T1"); }});
		blocksList.add(new HashMap() {{ put("BLOCK", "T2"); }});
		request.setAttribute("Blocks", blocksList.toArray(new Map[0]));

		//塞X軸的內容
		Map<String, List<String>> locXSize = new HashMap();
		locXSize.put("T1", Arrays.asList("A", "B", "C"));
		locXSize.put("T2", Arrays.asList("X", "Y"));
		request.setAttribute("locXSize", locXSize);

		//塞Y軸的內容
		Map<String, List<String>> locYSize = new HashMap();
		locYSize.put("T1", Arrays.asList("01", "02", "03"));
		locYSize.put("T2", Arrays.asList("11", "12"));
		request.setAttribute("locYSize", locYSize);

		//塞庫存數量
		Map<String, String> stockNum = new HashMap();
		stockNum.put("T1A01", "2");
		request.setAttribute("stockNum", stockNum);

		//塞庫存內容
		Map<String, List<Map<String, Object>>> ihx = new HashMap();

		List<Map<String, Object>> t1a01List = new ArrayList();
		Map<String, Object> i1 = new HashMap();
		i1.put("ID", "MAT001");
		i1.put("WGT", 1050);
		t1a01List.add(i1);
		Map<String, Object> i2 = new HashMap();
		i2.put("ID", "MAT002");
		i2.put("WGT", 980);
		t1a01List.add(i2);
		ihx.put("T1A01", t1a01List);

		request.setAttribute("ihx", ihx);
	} catch (Exception ex) {
		ex.printStackTrace();
	}
}
%>