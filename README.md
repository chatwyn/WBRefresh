# WBRefresh
An easy way to refresh. 

<img src="http://7xpk2w.com1.z0.glb.clouddn.com/demo.gif" width="320"><br/>



#Integration
---
You can use [Cocoapods](https://cocoapods.org/) to install WBRefresh adding it to your Podfile:

```
platform :ios, '8.0'  
use_frameworks!  

pod 'WBRefresh'

end
```


##Usage
---

```
      tableView.refreshBlock { () -> Void in
             //Do something you want
            
        }
        
	 tableView.endRefresh()
    
```  


