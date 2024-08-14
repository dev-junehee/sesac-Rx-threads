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
        
        crawlingKBO()
    }
    
    private func crawlingKBO() {
        let url = "https://www.koreabaseball.com/Schedule/GameCenter/Main.aspx"
        guard let URL = URL(string: url) else { return }
        
        
        AF.request(URL).responseString { response in
            guard let html = response.value else { return }

            do {
                let doc: Document = try SwiftSoup.parse(html)
                let headerTitle = try doc.title()
                print("header", headerTitle)
                
                /// `내 코드`
                // let find = try doc.select("#container").select("#contents").select(".today-game").select(".game-list").select(".game-cont")
                // let find = try doc.select("li.game-cont")
                // print("갯수", find.size())
                // print("이건가", find)
                // for i in find {
                //     print("title: ", i)
                //     print("==", try i.text())
                // }
                
                /// `챗지피티 코드`
                // let gameContElements = try doc.select(".game-cont")
                // 
                // // 선택된 요소의 개수 출력 (디버깅 용도)
                // print("Number of .game-cont elements found:", gameContElements.size())
                // 
                // // 각 요소의 HTML 내용 출력
                // for element in gameContElements {
                //     let outerHtml = try element.outerHtml()
                //     print("HTML Content:", outerHtml)
                // }

                
                /// `김종권 블로그 코드`
                // #contents > div.today-game > div > div.bx-viewport > ul
                // let elements: Elements = try doc.select("div.today-game")
                // print("el", elements)
                // for element in elements {
                //     print(try element.select("div.bx-viewport > ul").text())
                // }

            } catch {
                print("crawl error")
            }
        }

        
    
        /// `내 코드`
        // do {
        //     let html = try String(contentsOf: URL, encoding: .utf8)
        //     let doc: Document = try SwiftSoup.parse(html)
        //     let game = try doc.select(".bx-viewport")
        //     print("=============================")
        //     print(game)
        // } catch Exception.Error(let type, let message) {
        //     print(message)
        // } catch {
        //     print("unknown error")
        // }
    }
    
}
