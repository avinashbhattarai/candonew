//
//  TipsViewController.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 18.08.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit
import Moya
import SVProgressHUD
import ESPullToRefresh
import Kingfisher

class TipsViewController: BaseViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var tipsTableView: UITableView!
    var heightAtIndexPath = NSMutableDictionary()
	var tipsArray = [Tip]()
	var selectedTip: Tip?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		tipsTableView.dataSource = self
		tipsTableView.delegate = self
        tipsTableView.emptyDataSetSource = self;
        tipsTableView.emptyDataSetDelegate = self;

        headerLabel.text = String(format:"Here are some tips and resources\nto help you support %@", (Helper.UserDefaults.kStandardUserDefaults.value(forKey: Helper.UserDefaults.kUserGroupOwner) as? String) ?? "")
        
        
		_ = tipsTableView.es_addPullToRefresh {

			/// Do anything you want...
			/// ...
			self.runTipsInfoRequest()
			/// Stop refresh when your job finished, it will reset refresh footer if completion is true

			/// Set ignore footer or not
			// self?.teamTableView.es_stopPullToRefresh(completion: true, ignoreFooter: false)
		}
        tipsTableView.es_startPullToRefresh()

	}
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No tips"
        let attrs = [NSFontAttributeName: UIFont(name: "MuseoSansRounded-300", size: 18)!, NSForegroundColorAttributeName:Helper.Colors.RGBCOLOR(104, green: 104, blue: 104)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func runTipsInfoRequest() {

		
		provider.request(.tipsInfo()) { result in
			switch result {
			case let .success(moyaResponse):

				do {
					try _ = moyaResponse.filterSuccessfulStatusCodes()
					guard let json = moyaResponse.data.nsdataToJSON() as? [[String: AnyObject]] else {
						print("wrong json format")
                        self.tipsTableView.es_stopPullToRefresh(completion: true)
						SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
						return
					}
					self.tipsArray.removeAll()
					for tip in json {
						let newTip = Tip(title: tip["title"] as? String, cover: tip["cover"] as? String, url: tip["url"] as? String)
						self.tipsArray.append(newTip)
					}

					self.tipsTableView.reloadData()
					SVProgressHUD.dismiss()
					self.tipsTableView.es_stopPullToRefresh(completion: true)

				}
				catch {

					guard let json = moyaResponse.data.nsdataToJSON() as? NSArray,
						let item = json[0] as? [String: AnyObject],
						let message = item["message"] as? String else {
							SVProgressHUD.showError(withStatus: Helper.ErrorKey.kSomethingWentWrong)
							self.tipsTableView.es_stopPullToRefresh(completion: true)
							return
					}
					SVProgressHUD.showError(withStatus: "\(message)")
					self.tipsTableView.es_stopPullToRefresh(completion: true)
				}

			case let .failure(error):
				guard let error = error as? CustomStringConvertible else {
					break
				}
				print(error.description)
				SVProgressHUD.showError(withStatus: "\(error.description)")
				self.tipsTableView.es_stopPullToRefresh(completion: true)

			}
		}

	}

	func loadImage(_ indexPath: IndexPath, tip: Tip) {
       
        ImageDownloader(name: "imageDownloader").downloadImage(with:URL(string: tip.cover)!, progressBlock: { (receivedSize: Int64, expectedSize: Int64) -> Void in
			// progression tracking code

			}, completionHandler: { (image: Image?, error: NSError?, imageURL: URL?, originalData: Data?) -> Void in

			print("image \(image)  url \(NSURL(string:tip.cover))  error \(error)")

			if image != nil {
				let localImage: UIImage = image!

                DispatchQueue.main.async{
					tip.image = localImage
					self.tipsTableView.beginUpdates()
                    self.tipsTableView.reloadRows(at: [indexPath],with: .none)
					self.tipsTableView.endUpdates()
				}
			}

		})

	}

	func readMoreButtonTapped(_ sender: ButtonWithIndexPath) {
		selectedTip = tipsArray[((sender.indexPath as NSIndexPath?)?.row)!]
		performSegue(withIdentifier: Helper.SegueKey.kToTipDetailsViewController, sender: self)
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		if segue.identifier == Helper.SegueKey.kToTipDetailsViewController {
			let viewController: TipDetailsViewController = segue.destination as! TipDetailsViewController
			if (selectedTip != nil) {
				viewController.currentTip = selectedTip
			}

		}

	}

}

// MARK: - UITableViewDataSource
extension TipsViewController: UITableViewDataSource {

	

 
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tipsArray.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let tip: Tip = tipsArray[(indexPath as NSIndexPath).row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TipTableViewCell
        cell.selectionStyle = .none
		cell.titleLabel.text = tip.title
		if tip.cover.characters.count > 0 && tip.image == nil {
			loadImage(indexPath, tip: tip)
		} else {
			cell.setPostedImage(tip.image)
		}
		cell.readMoreButton.indexPath = indexPath
		cell.readMoreButton.addTarget(self, action: #selector(readMoreButtonTapped(_:)), for: .touchUpInside)

		return cell
	}

}
// MARK: - UITableViewDelegate
extension TipsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.heightAtIndexPath.object(forKey: indexPath)
        if ((height) != nil) {
            return CGFloat((height! as AnyObject).floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = cell.frame.size.height
        self.heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }

}

