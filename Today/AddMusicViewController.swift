//
//  AddMusicViewController.swift
//  Today
//
//  Created by 姚肖 on 2023/7/12.
//

import UIKit
import WebKit

class AddMusicViewController: ViewController {

    public var musicName : NSString = ""
    var webView : WKWebView = WKWebView()
    var musicModel : MusicModel = MusicModel()
    
    init(musicName: NSString) {
        super.init(nibName: nil, bundle: nil)
        self.musicName = musicName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadui() {
        super.loadui()
        title = "add music"
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "back", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "downLoad", style: .plain, target: self, action: #selector(downLoadAction))
        
        webView = WKWebView.init(frame: CGRect(x: 20, y: 120, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 120 - 80))
        musicName = musicName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)! as NSString
        var requestSting : NSString = "https://www.hifini.com/search-"
        requestSting = requestSting.appending(musicName as String) as NSString
        requestSting = requestSting.appending("-1.htm") as NSString
        print("=== \(requestSting)")
        webView.load(NSURLRequest(url: NSURL(string: requestSting as String)! as URL) as URLRequest)
        view.addSubview(webView)
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func downLoadAction() {
        webView.evaluateJavaScript("document.documentElement.outerHTML") {[weak self] html, error in
            if (error == nil) {
                self?.musicModel = HtmlHandle.handleHtmlString(html as! String)
                self?.downLoad()
            } else {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
    }
    
    func downLoad() {
        
        SVProgressHUD.showSuccess(withStatus: musicModel.url)
        let manager : YXFileManager = YXFileManager.shared()
        manager.downLoadFile(musicModel.url, groupName: "music") { pro, index in
            SVProgressHUD.showProgress(pro)
        } success: {[weak self] path in
            let dic = self?.musicModel.toDictionary()
            let myOCDict = NSDictionary(dictionary: dic!)
            YXFileManager.saveValue(myOCDict as! [NSString : Any], key: (path! as NSString).lastPathComponent)
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
