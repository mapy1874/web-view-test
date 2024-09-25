//
//  ContentView.swift
//  WebViewTest
//
//  Created by Patrick Ma on 9/25/24.
//
import SafariServices
import SwiftUI
@preconcurrency import WebKit

struct ContentView: View {
    @State private var showSafari = false
    @State private var urlToOpen: URL?

    var body: some View {
        ZStack {
            WebView(url: URL(string: "about:blank")!, onLinkClicked: handleLinkClicked)
                .edgesIgnoringSafeArea(.all)

            if showSafari, let url = urlToOpen {
                SafariView(url: url)
            }
        }
    }

    func handleLinkClicked(_ url: URL) {
        urlToOpen = url
        showSafari = true
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let onLinkClicked: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        let htmlString = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body { margin: 0; padding: 0; }
                iframe { width: 100%; height: 100vh; }
            </style>
        </head>
        <body>

            <p>Below is an iframe:</p>

            <iframe width="560" height="315" src="https://www.youtube.com/embed/cwtpLIWylAw?si=xTT7PdgxKdnjSOLf" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
            <p>End of iframe</p>

            <a href="https://quora.com">This is a link in WebView</a>

        </body>
        </html>
        """

        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(
            _: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.targetFrame?.isMainFrame != false else {
                decisionHandler(.allow)
                return
            }

            if navigationAction.navigationType == WKNavigationType.linkActivated {
                print("link")

                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            print("no link")
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .systemBlue
        controller.preferredBarTintColor = .systemBackground
        return controller
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}

#Preview {
    ContentView()
}
