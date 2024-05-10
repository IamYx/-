//
//  AddVideoViewController.swift
//  Today
//
//  Created by 姚肖 on 2023/7/25.
//

import UIKit
import WebKit

class AddVideoViewController: ViewController {

    @objc public var urlStr : NSString = ""
    var downLoadString : NSString = ""
    var webView : WKWebView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadui()
        
    }
    
    override func loadui() {
        super.loadui()
        title = "add music"
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "back", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "downLoad", style: .plain, target: self, action: #selector(downLoadAction))
        
        webView = WKWebView.init(frame: CGRect(x: 20, y: 120, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 120 - 80))
        var requestSting : NSString = "https://www.hifini.com/search-"
        let strArray = (urlStr as NSString).components(separatedBy: "https")
        if strArray.count > 1 {
            requestSting = NSString(format: "https%@", (strArray[1] as NSString))
        }
        
        webView.load(NSURLRequest(url: NSURL(string: requestSting as String)! as URL) as URLRequest)
        view.addSubview(webView)
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func downLoadAction() {
        webView.evaluateJavaScript("document.getElementById('root').innerHTML") {[weak self] html, error in
            if (error == nil) {
                let download : NSArray = (html as! NSString).components(separatedBy:"?video_id") as NSArray
                if download.count > 1 {
                    let download0 = download[1]
                    let download1 : NSArray = (download0 as! NSString).components(separatedBy: "line=0") as NSArray
                    if download1.count > 1 {
                        self?.downLoadString = NSString(format: "https://www.douyin.com/aweme/v1/play/?video_id%@line=0", (download1[0] as! NSString))
                        
//                        print(self!.downLoadString as NSString)
                        self?.downLoad()
                    }
                }
            } else {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
    }
    
    func downLoad() {
        
        SVProgressHUD.showSuccess(withStatus: downLoadString as String)
        let manager : YXFileManager = YXFileManager.shared()
        manager.downLoadFile(downLoadString as String, groupName: "dyVideo") { pro, index in
            SVProgressHUD.showProgress(pro)
        } success: { path in
            SVProgressHUD.showSuccess(withStatus: "done")
        } failure: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
