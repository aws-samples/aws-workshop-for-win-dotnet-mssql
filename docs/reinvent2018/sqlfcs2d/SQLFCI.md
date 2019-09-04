Install SQL as a Failover Cluster
===========

Now that Storage Spaces Direct is enabled on the Cluster and a Cluster Shared Volume has been created, we can start the installation of a SQL Failover Cluster.  

1. Connect to STDxSQL1 via RDP from STDxADM using the credentials provided  
2. The SQL media (iso) will be on STDxADM accessible via `\\stdxadm\isos`
	-   Copy the ISO into `c:\ClusterStorage\Volume1`
	-   Now simply double click or right click and mount the iso.  
![](media/41d0be3f5ee8e1964dc3c5e752c3ade2.png)
  
3. Launch the SQL setup.  
4. From the Installation Menu, Select “New SQL Server Failover Cluster”  
![](media/b445d138f3449bae5f0b81cffa55bdc1.png)
  
5. Specify a Free Edition "Developer", no product key. Click Next  
6. Accept the License Terms and Click Next  
7. Skip checking for updates (Do not check the box) Click Next  
8. Review the Cluster rules have passed (warnings are okay) Click Next  
9. Check the box to Install just the Database Engine, leaving the directory locations default, Click Next  
![](media/92f8fc58f9455a27fc251b7d0145f330.png)
  
10. Use Default Instance and specify the SQL Server Network Name “STDxSQLFCI”, click Next  
![](media/e28bc0457f9e060fb7049af58086ad2d.png)
  
11. Click next past the Cluster resource Page. You will have at least one qualified resource.  
12. Click Next past the Cluster Disk Selection. The only available CSV will be checked  
13. Select the 172.16.1.x network, deselect the DHCP box, and enter in the secondary IP provided for STDxSQL1, click next  
![](media/e8ba4f0ddc287967b0be78b58b0da99b.png)
  
14. Specify the SQL Service account credentials provided (Clicking the Collation tab then back will confirm credentials are valid.) Click Next  
![](media/ddcfe40ba4a5d8c66c83d1802d989bd9.png)
  
15. Enable Mixed mode and specify a SQL account password, add the current user as a SQL administrator as well. Click the Data Directories Tab.  
![](media/94624cd65897b2b41fbdc95bfee852ad.png)
  
16. Confirm the CSV is being used as the root directory “C:\\ClusterStorage\\Volume1\\”, Click Next
	- Note: if additional CSV are created you can separate the logs from the databases.  
![](media/6e98bfc1f49a7d8b542935c27a8ef886.png)
  
17. Review the configuration and finally Click Install.  
18. The Install should take roughly 5 minutes. If everything was configured correctly, you will see success.  
![](media/1d445e66c34893304daa24e6bad58582.png)
