package leafy.network;

@:cppFileCode("
#include <curl/curl.h>
#include <iostream>
#include <string>
#include <vector>

size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* output) {
    size_t totalSize = size * nmemb;
    output->append((char*)contents, totalSize);
    return totalSize;
}

std::string curlRequest(const std::string& url, 
                        const std::string& method, 
                        const std::string& data,
                        std::shared_ptr<std::deque<std::string>> headers) {
    
    CURL* curl;
    CURLcode res;
    std::string response;

    curl = curl_easy_init();
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());  
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);  
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

        if (method == \"POST\") {
            curl_easy_setopt(curl, CURLOPT_POST, 1L);
        } else if (method == \"PUT\" || method == \"DELETE\" || method == \"PATCH\") {
            curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, method.c_str());
        }

        if (!data.empty()) {
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data.c_str());
        }

        struct curl_slist* headerList = NULL;
        if (headers) {
            for (const std::string& header : *headers) {
                headerList = curl_slist_append(headerList, header.c_str());
            }
        }
        if (headerList) {
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerList);
        }

        res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            std::cerr << \"curl_easy_perform() failed: \" << curl_easy_strerror(res) << std::endl;
        }

        curl_easy_cleanup(curl);
        if (headerList) {
            curl_slist_free_all(headerList);
        }
    }

    return response;
}
")

/**
 * C++ wrapper for curl, used to make HTTP requests
 * 
 * Author: Slushi
 */
class LfCurlRequest {
    /**
     * Make an HTTP request
     * @param url The URL to make the request to
     * @param method The method to use (GET, POST, PUT, DELETE, PATCH)
     * @param data The data to send
     * @param headers The headers to send
     * @return String The response
     */
    public static function httpRequest(url:String, method:String, data:String, headers:Array<String>):String {
        return untyped __cpp__("curlRequest({0}, {1}, {2}, {3})", url, method, data, headers);
    }
}

