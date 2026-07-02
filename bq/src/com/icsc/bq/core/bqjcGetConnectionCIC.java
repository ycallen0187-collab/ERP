/*----------------------------------------------------------------------------*/
/* vcGen Ver 6.1010
/*----------------------------------------------------------------------------*/
/* author : YC13
/* system : IL
/* target : 採購退貨資料處理邏輯
/* create : 2009.01.01
/* update : XXXX.XX.XX
/*----------------------------------------------------------------------------*/
package com.icsc.bq.core;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import com.icsc.aa.yc.dao.aajcYCADAO;
import com.icsc.aa.yc.util.aajcYCATool;
import com.icsc.dpms.de.dejc308;
import com.icsc.dpms.de.dejc318;
import com.icsc.dpms.de.dejcQueryDAO;
import com.icsc.dpms.ds.dsjccom;


public class bqjcGetConnectionCIC{
	private static final String PROCID = "BQJC042";
	public final static String CLASS_VERSION = "$Id: bqjcGetConnectionCIC.java,v 1.3 2026/06/04 07:40:45 02553 Exp $";
    
    private dejc318 de318;
	private dsjccom dsCom;
    
    public aajcYCATool aaTool = new aajcYCATool();
    
/*----------------------------------------------------------------------------*/
/* 建構子
/*----------------------------------------------------------------------------*/
    public bqjcGetConnectionCIC(dsjccom dsCom) {
    	super();
        this.dsCom = dsCom;
        de318 = new dejc318(this.dsCom, PROCID);
    }
    
    
    
    public static Connection getSQLServerConnection()throws Exception{
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection("jdbc:sqlserver://172.17.0.36:1433;"
                + "databaseName=CIC;user=sa;password=59068700;encrypt=false;trustServerCertificate=true;");
	}
    
    public static Connection getIOTServerConnection()throws Exception{
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection("jdbc:sqlserver://172.17.0.63:1433;"
                + "databaseName=DataMart;user=YC_ReadOnlyUser;password=20260223@yc!;encrypt=false;trustServerCertificate=true;sslProtocol=TLSv1.2;");
	}
    
    public Connection getTRDB2Connection()throws Exception{
    	Connection conTR = null;
    	Class.forName("com.ibm.db2.jcc.DB2Driver");
    	for(int i = 0; i < 10; i++){
    		if(conTR != null){
    			return conTR;
    		}
        	try{
        		//建立TR連線
    			conTR = DriverManager.getConnection("jdbc:db2://172.21.0.6:50000/YCUTF8","db2inst", "ibmdb2");
        	}catch (Exception ex) {
        	}
    	}
		return conTR;
    }
    
}
