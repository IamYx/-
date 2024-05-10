//
//  MainViewController.swift
//  Today
//
//  Created by 姚肖 on 2023/7/12.
//

import UIKit
import AVKit

class MusicListCell: UITableViewCell {
    
    public var mImageView : UIImageView = UIImageView()
    public var nameLabel : UILabel = UILabel()
    public var authorLabel : UILabel = UILabel()
    public var numLabel : UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        mImageView.frame = CGRect.init(x: 20, y: 10, width: 50, height: 50)
        mImageView.clipsToBounds = true
        mImageView.layer.cornerRadius = 5
//        mImageView.backgroundColor = .orange
        self.addSubview(mImageView)
        
        nameLabel.frame = CGRect.init(x: CGRectGetMaxX(mImageView.frame) + 10, y: 10, width: 200, height: 23)
        nameLabel.text = "name"
        self.addSubview(nameLabel)
        
        authorLabel.frame = CGRect.init(x: CGRectGetMaxX(mImageView.frame) + 10, y: CGRectGetMaxY(nameLabel.frame) + 4, width: 200, height: 23)
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .lightGray
        authorLabel.text = "author"
        self .addSubview(authorLabel)
        
        numLabel.frame = CGRect.init(x: UIScreen.main.bounds.size.width - 33, y: CGRectGetMaxY(nameLabel.frame) + 4, width: 23, height: 23)
        numLabel.font = UIFont.systemFont(ofSize: 14)
        numLabel.textColor = .lightGray
        numLabel.text = "num"
        numLabel.textAlignment = .right
        self .addSubview(numLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MusicListCell = tableView.dequeueReusableCell(withIdentifier: "mCell") as! MusicListCell
        let model : MusicModel = mData[indexPath.row] as! MusicModel
        cell.nameLabel.text = model.name
        cell.authorLabel.text = model.author
        cell.mImageView.sd_setImage(with: URL(string: model.pic))
        cell.numLabel.text = "\(indexPath.row)"
        cell.selectionStyle = .none
        
        if (indexPath.row == currIndex) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model : MusicModel = mData[indexPath.row] as! MusicModel
        let action = UITableViewRowAction(style: .normal, title: "删除") { [weak self] actionrow, index in
            YXFileManager.deleteFile(withPath: model.ext)
            self?.loadData()
        }
        action.backgroundColor = .red
        let action1 = UITableViewRowAction(style: .normal, title: "置顶") {[weak self] actionrow, index in
            
            model.time = (String(format: "%.6f", NSDate().timeIntervalSince1970) as NSString) as String
            let dic = model.toDictionary()
            let myOCDict = NSDictionary(dictionary: dic)
            YXFileManager.saveValue(myOCDict as! [NSString : Any], key: (model.ext as NSString).lastPathComponent)
            
            self?.loadData()
        }
        action1.backgroundColor = .blue
        return [action, action1]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let musicModel = mData[indexPath.row] as! MusicModel
        widgeRefresh(model: musicModel)
        
        if (currIndex == indexPath.row) {
            
            mPlayer.play()
            WidgetKitManager.shareManager.startLiveAc(name: musicModel.name)
            
            let vc = MusicDetailViewController()
            vc.model = mData[currIndex] as! MusicModel
            vc.duration = YXFileManager.audioFileTime(vc.model.ext)
            vc.queuePlayer = mPlayer
            present(vc, animated: true)
            return
        }
        
        currIndex = indexPath.row
        mPlayer.pause()
        mPlayer.removeAllItems()
        
        for index in stride(from: indexPath.row, to: mItems.count, by: 1) {
            mPlayer.insert(mItems[index] as! AVPlayerItem, after: nil)
        }
        mPlayer.seek(to: CMTime.zero)
        mPlayer.play()
        
        tableView.reloadData()

    }
    
    func widgeRefresh(model : MusicModel) {
        //传输music name给小组件
        let userDefualt = UserDefaults.init(suiteName: "group.com.today.widge")
        userDefualt?.set(model.name, forKey: "MusicName")
        userDefualt?.set(model.pic, forKey: "MusicPic")
        
        if #available(iOS 14.0, *) {
            WidgetKitManager.shareManager.reloadTimelines(kind: "TodayWidget")
            print("更新ing")
            WidgetKitManager.shareManager.updateLiveAc(name: model.name)
        } else {
            // Fallback on earlier versions
        }
    }

    lazy var mTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MusicListCell.self, forCellReuseIdentifier: "mCell")
        return tableView
    }()
    lazy var mPlayer: AVQueuePlayer = {
        let player = AVQueuePlayer()
        return player
    }()
    let mData : NSMutableArray = []
    let mItems : NSMutableArray = []
    var currIndex : NSInteger = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mPlayer.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onEnterForeground() {
        
        if (mPlayer.currentItem != nil) {
            mPlayer.play()
            currIndex = mItems.index(of: mPlayer.currentItem!)
            mTableView.reloadData()
            widgeRefresh(model: mData[currIndex] as! MusicModel)
        }
    }
    
    @objc func playerDidFinishPlaying(sender : Any) {
        mPlayer.advanceToNextItem()
        
        if (mPlayer.currentItem != nil) {
            currIndex = mItems.index(of: mPlayer.currentItem!)
            mTableView.reloadData()
            widgeRefresh(model: mData[currIndex] as! MusicModel)
        } else {
            currIndex = -1
            mTableView.reloadData()
        }
    }
    
    func loadData() {
        
        mData.removeAllObjects()
        mItems.removeAllObjects()
        currIndex = -1
        mPlayer.pause()
        
        let array = YXFileManager.outPutFile(fromGroup: "music")
        //先添加model
        for path in array {
            let dic = YXFileManager.getValueForKey((path as! NSString).lastPathComponent)
            let musicModel = MusicModel.music(withDict: dic)
            musicModel.ext = YXFileManager.musicFile(fromPath: path as! String)
            mData.add(musicModel)
        }
        
        self.writeMusicInfo(arr: mData)
        
        //根据时间排序
        mData.sort { a, b in
            let model1 : MusicModel = a as! MusicModel
            let model2 : MusicModel = b as! MusicModel
            if model1.time > model2.time {
                return .orderedAscending
            } else if model1.time == model2.time {
                return .orderedSame
            } else {
                return .orderedDescending
            }
        }
        
        //排完序再添加播放队列
        for item in mData {
            let model : MusicModel = item as! MusicModel
            let item = AVPlayerItem.init(url: URL(fileURLWithPath: model.ext))
            mItems.add(item)
        }
        
        mTableView.reloadData()
    }
    
    override func loadui() {
        super.loadui()
        title = "music"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action:#selector(addAction))
        view.addSubview(mTableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mTableView.frame = view.bounds
    }
    
    @objc func addAction() {
        
        var textField : UITextField = UITextField()
        let alertC = UIAlertController.init(title: "music name", message: nil, preferredStyle: .alert)
        alertC.addTextField() { tf in
            textField = tf
        }
        alertC.addAction(UIAlertAction.init(title: "cancel", style: .cancel))
        alertC.addAction(UIAlertAction.init(title: "ok", style: .default) { [weak self] action in
            let content : NSString = textField.text! as NSString
            if content.length > 0 {
                let vc = AddMusicViewController(musicName: content)
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })
        present(alertC, animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func writeMusicInfo(arr : NSArray) {
        
        // 要写入的文件路径
        let path = NSHomeDirectory() + "/Documents/" + "file.txt"
        let fileURL = URL(fileURLWithPath: path)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            
            return;
            
        } else {
            
            do {
                try "music".write(to: fileURL, atomically: true, encoding: .utf8)
                print("文件创建成功")
            } catch {
                print("创建文件时出现错误: \(error)")
            }
            
        }
        
        for i in arr {
            let musicModel = i as! MusicModel
            let dictionary = [musicModel.name : musicModel.ext]
            // 打开文件句柄，以便在末尾添加内容
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                fileHandle.seekToEndOfFile()
                
                for (key, value) in dictionary {
                    let entry = "\(key): \(value)\n"
                    if let data = entry.data(using: .utf8) {
                        fileHandle.write(data)
                    }
                }
                
                fileHandle.closeFile()
                print("字典内容已成功附加到文件末尾")
            } else {
                print("无法打开文件句柄")
            }
        }
        
    }

}
