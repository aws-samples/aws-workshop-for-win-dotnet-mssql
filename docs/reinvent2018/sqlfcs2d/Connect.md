Connect and Verify the Cluster
==============================

1. Using the credentials and IP provided, connect to your assigned STDxADM server via RDP.  
2. Launch PowerShell as Administrator
![](media/1d36caf7a2b49bb0a00b1412250e2475.png)
  
3. Set your nodes to the `$nodes` variable with the command `$nodes = "STDxSQL1", "STDxSQL2"`  
4. Launch the Failover Cluster Manager, if needed connect to your cluster 'STDxWSFC'
	- Launch the Failover Cluster Manager using comand 'Cluadmin.msc'  
5. Verify the Cluster is online and healthy. Note the passive Cluster IP will be offline and is expected.
![](media/398d808e192954ca472cfb3a38db089a.png)
