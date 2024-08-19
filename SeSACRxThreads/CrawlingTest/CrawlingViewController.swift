//
//  CrawlingViewController.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/14/24.
//

import UIKit
import SnapKit
import SwiftSoup
import Alamofire

final class CrawlingViewController: UIViewController {
    
    let testLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(testLabel)
        testLabel.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // crawlingKBO()
        // crawlingNaverSport()
    }
    
    private func crawlingKBO() {
        let url = "https://www.koreabaseball.com/Schedule/GameCenter/Main.aspx"
        guard let URL = URL(string: url) else { return }
        
        AF.request(URL).responseString { response in
            guard let html = response.value else { return }
            
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let game = try doc.select("div.today-game")
                print("=============================")
                print("game", game)
                
                for item in game {
                    print("item >>>", item)
                }
                
            } catch (let error) {
                print(error)
            }
        }
    }
    
    
    private func crawlingNaverSport() {
        let url = "https://sports.news.naver.com/kbaseball/index"
        guard let URL = URL(string: url) else { return }
        
        
        AF.request(URL).responseString { response in
            guard let html = response.value else { return }
            
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let game = try doc.select("div.home_mn")
               
                print("game", game)
                
                let gameDetail = try game.select("div#_tab_box_kbo").select("div.hmb_list").select("ul").select("li.hmb_list_items")
                
                for item in gameDetail {
                    
                    print("========================================================================")
                    let left = try item.select("div.vs_list1").select("div.inner")
                    print("left >>>", try left.text())
                    
                    print("========================================================================")
                    let right = try item.select("div.vs_list2").select("div.inner")
                    print("right >>>", try right.text())
                }
                
            } catch (let error) {
                print(error)
            }
        }
    }
    
}
