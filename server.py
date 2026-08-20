from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import sys

class FastHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="build/web", **kwargs)

    def end_headers(self):
        # Enable caching headers and CORS for fast local delivery
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

    def log_message(self, format, *args):
        pass # Suppress noisy logging for performance

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
    httpd = ThreadingHTTPServer(('0.0.0.0', port), FastHandler)
    print(f"High-performance threaded web server serving build/web on http://localhost:{port}")
    httpd.serve_forever()
