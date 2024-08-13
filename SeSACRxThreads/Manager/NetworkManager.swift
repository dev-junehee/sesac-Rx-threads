//
//  NetworkManager.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/8/24.
//

import Foundation
import Alamofire
import RxSwift

enum APIError: Error {
    case invalidURL
    case unknownResponse
    case statusError
    
}

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
    
    // Observable 객체로 Alamofire 통신
    func fetchJoke() -> Observable<Joke> {
        return Observable.create { observer -> Disposable in
            // AF.request(API.jokeURL)
            AF.request("")
                .validate(statusCode: 200...299)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let value):
                        // 성공하면 next 이벤트 전달
                        observer.onNext(value)
                        observer.onCompleted() // 바로 종료해주기 위해서!
                    case .failure(let error):
                        // 실패하면 error 이벤트 전달
                        observer.onError(error) // 에러는 dispose로 연결되기 때문에 별도 처리 필요 X
                    }
                }
            return Disposables.create()
        }.debug("Joke API Call")
    }
    
    // Single 객체로 Alamofire 통신
    func fetchJokeWithSingle() -> Single<Joke> {
        return Single.create { observer -> Disposable in
            // AF.request(API.jokeURL)
            AF.request("")
                .validate(statusCode: 200...299)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer(.success(value))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }.debug("Joke API Call")
    }
    
    // Single 객체로 Alamofire 통신 + ResultType 활용
    func fetchJokeWithSingleResultType() -> Single<Result<Joke, ErrorType>> {
        return Single.create { observer -> Disposable in
            // AF.request(API.jokeURL)
            AF.request("")
                .validate(statusCode: 200...299)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let value):
                        // observer(.success(value))
                        observer(.success(.success(value)))
                    case .failure(let error):
                        // observer(.failure(error))
                        observer(.success(.failure(.invalidEmail)))
                    }
                }
            return Disposables.create()
        }.debug("Joke API Call")
    }
    
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
                    print("call boxoffice error", error)
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
