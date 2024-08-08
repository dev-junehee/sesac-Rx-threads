//
//  NetworkManager.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/8/24.
//

import Foundation
import RxSwift

enum APIError: Error {
    case invalidURL
    case unknownResponse
    case statusError
    
}

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
    
    /// `combineLatest, withLatestFrom, zip, just, debounce`...
    /// 위 연산자들 처럼 `callBoxOffice`도 내가 원하는 걸 만든 연산자라고 보면 된다!
    func callBoxOffice(date: String) -> Observable<Movie> {
        let url = "https://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=\(API.key)&targetDt=\(date)"
        
        let result = Observable<Movie>.create { observer in
            guard let URL = URL(string: url) else {
                observer.onError(APIError.invalidURL)
                return Disposables.create()
            }
            
            URLSession.shared.dataTask(with: URL) { data, response, error in
                /// 에러가 있을 땐 문제가 생겼다는 것!
                if let error = error {
                    observer.onError(APIError.unknownResponse)
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    observer.onError(APIError.statusError)
                    return
                }
                
                if let data = data, let appData = try? JSONDecoder().decode(Movie.self, from: data) {
                    observer.onNext(appData)
                    observer.onCompleted()
                } else {
                    print("응답은 왔으나 디코딩 실패")
                    observer.onError(APIError.unknownResponse)
                }
            }
            .resume()
            
            return Disposables.create()
        }
            .debug("박스오피스 조회")
        
        return result
    }
    
    
}
