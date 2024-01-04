import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        
        // 设置脚本消息处理程序
        let contentController = WKUserContentController()
        contentController.add(self, name: "getImageURL")
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: "http://192.168.220.75:3000/webview-com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    // 实现 WKScriptMessageHandler 协议方法，处理从网页端发送的消息
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "getImageURL" {
            print("Received message from web page:")
            print("Message Name: \(message.name)")
            print("Message Body: \(message.body)")
            
            if let command = message.body as? String, command == "selectImage" {
                // 处理打开图片选择器的命令
                openImagePicker()
            } else if let imageURLString = message.body as? String {
                print("Received image URL from web page: \(imageURLString)")
                // 进行进一步处理，如果需要的话
            }
        }
    }
    
    // 打开图片选择器的方法
    func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 用户从图库选择图片后调用此方法
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 关闭图片选择器
        picker.dismiss(animated: true, completion: nil)
        
        // 检查选择的媒体是否为图片
        if let pickedImage = info[.originalImage] as? UIImage {
            // 将图片转换为 Data 对象
            if let imageData = pickedImage.jpegData(compressionQuality: 0.8) {
                // 将 Data 对象转换为 base64 编码的字符串
                let base64String = imageData.base64EncodedString()
                
                print("Message Name:",base64String)
                
                // 创建一个 JavaScript 函数，将图片数据发送回网页端
                let javascriptFunction = "setImageFromiOS('\(base64String)')"
                
                // 在 WebView 上执行 JavaScript 函数
                webView.evaluateJavaScript(javascriptFunction, completionHandler: nil)
            }
        }
    }
    
    // 用户取消图片选择时调用此方法
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

