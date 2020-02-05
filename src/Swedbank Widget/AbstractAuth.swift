//
//  AbstractAuth.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2019-12-29.
//  Copyright © 2019 Samuel Ivarsson. All rights reserved.
//

import Foundation

class AbstractAuth {
    /** Auth session name */
    let authSession = "swedbankjson_auth"
    /** Cookie jar session name */
    let cookieJarSession = "swedbankjson_cookiejar"
    /** @var string URI to API server */
    private var _baseUri = "https://auth.api.swedbank.se/TDE_DAP_Portal_REST_WEB/api/"
    /** @var string API version */
    private var _apiVersion = "v4"
    /** @var string Bank type AppID */
    private var _appID: String
    /** @var string User agent for API client */
    private var _userAgent: String
    /** @var string Generated  required auth key */
    private var _authorization: String
    /** @var object HTTP client lib */
    //private var _client: AnyObject?
    /** @var string Profile type (individual or cooperate) */
    private var _profileType: String
    /** @var bool Debug */
    private var _debug: Bool
    /** @var object Cookie jar */
    //private var _cookieJar: AnyObject
    /** @var bool If the authentication method needs to save the session */
    private var _persistentSession = false
    
    init() {
        self._appID = ""
        self._userAgent = ""
        self._authorization = ""
        self._profileType = ""
        self._debug = false
    }
    
    public func setAppData(appdata: [String: String]) {
        if (appdata["appID"] == nil || appdata["useragent"] == nil) {
            print("Not valid app data.")
            exit(1)
        } else {
            self._appID = appdata["appID"]!
            self._userAgent = appdata["useragent"]!
            self._profileType = "privateProfile"
        }
    }
    
    public func setAuthorizationKey(key: String = "") {
        self._authorization = (key.count < 1) ? genAuthorizationKey() : key;
    }
    
    public func genAuthorizationKey() -> String {
        let string = self._appID + ":" + UUID().uuidString
        let data = string.data(using: String.Encoding.utf8)
        guard let output: String = data?.base64EncodedString() else {
            print("Error for some reason")
            exit(123)
        }
        return output
    }
    
    public func getRequest(apiRequest: String, query: NSArray = []) -> Data {
        let request = createRequest(method: "get", apiRequest: apiRequest)
        return sendRequest(request: request, query: query)
    }
    
    private func createRequest(method: String, apiRequest: String, headers: NSArray = [], body: String = "") -> URLRequest {
        // Initiate HTTP client if missing
//        guard let unWrappedClient = _client else {
//            self._cookieJar = (self._persistentSession) ? SessionCookieJar(self::cookieJarSession, true) : new CookieJar();
            
//            stack = HandlerStack.create();
            
        if (_debug)
        {
//                if (!class_exists(Logger::class))
//                    throw new UserException('Components for logging is missing (Monolog).', 1);
//                log = Logger("Log");
//                $stream = new StreamHandler('swedbankjson.log');
//                $stream->setFormatter(new LineFormatter("[%datetime%]\n\t%message%\n", null, true));
//                $log->pushHandler($stream);
//                $stack->push(Middleware::log($log, new MessageFormatter("{req_headers}\n\n{req_body}\n\t{res_headers}\n\n{res_body}\n")));
            print("Not fixed")
        }
        
        let url = URL(string: self._baseUri + self._apiVersion + "/" + apiRequest)
        guard let requestUrl = url else {
            fatalError()
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.uppercased()
        
        request.setValue("Authorization", forHTTPHeaderField: self._authorization)
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("sv-se", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("keep-alive", forHTTPHeaderField: "Proxy-Connection")
        request.setValue(self._userAgent, forHTTPHeaderField: "User-Agent")
        
        return request
            
//            _client = new Client([
//                'base_uri'        => $this->_baseUri.$this->_apiVersion.'/',
//                'headers'         => [
//                    'Authorization'    => $this->_authorization,
//                    'Accept'           => '*/*',
//                    'Accept-Language'  => 'sv-se',
//                    'Accept-Encoding'  => 'gzip, deflate',
//                    'Connection'       => 'keep-alive',
//                    'Proxy-Connection' => 'keep-alive',
//                    'User-Agent'       => $this->_userAgent,
//                ],
//                'allow_redirects' => ['max' => 10, 'referer' => true],
//                'verify'          => false, // Skipping TLS certificate verification of Swedbank API. Only for preventive purposes.
//                'handler'         => $stack,
//                //'debug'           => $this->_debug,
//            ]);
//        }
//        return Request($method, $apiRequest, $headers, $body)
    }
    
//    struct JSONBody: Codable {
//        var balance: String
//    }
    
    private func sendRequest(request: URLRequest, query: NSArray = [], options: NSArray = []) -> Data {
        
        var output: Data = Data()
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                //print("Response data string:\n \(dataString)")
                output = Data(base64Encoded: dataString)!
            }
        }
        
        task.resume()
        
        return output // JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: data)
        
//        $dsid = $this->dsid();
//        $this->_cookieJar->setCookie(new SetCookie([
//            'Name'   => 'dsid',
//            'Value'  => $dsid,
//            'Path'   => '/',
//            'Domain' => 0,
//        ]));
//        $options['cookies'] = $this->_cookieJar;
//        $options['query']   = array_merge($query, ['dsid' => $dsid]);
//        try
//        {
//            $response = $this->_client->send($request, $options);
//        } catch (ServerException $e)
//        {
//            $this->cleanup();
//            throw new ApiException($e->getResponse());
//        } catch (ClientException $e)
//        {
//            if(strpos($request->getUri(), 'identification/logout') === false)
//            {
//                $this->terminate();
//            }
//            throw new ApiException($e->getResponse());
//        }
//        return json_decode($response->getBody());
    }
    
    public func setDebug(_ debug: Bool) {
        self._debug = debug
    }
    
    public func setBaseUri(_ baseUri: String) {
        self._baseUri = baseUri
    }
    
}
