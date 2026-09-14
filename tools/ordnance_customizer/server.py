"""B-2 Ordnance Personalization Bridge Server.
Serves the 3D Bomb Signing Studio UI and commits pilot customizations
directly to the PBR compositor and live DCS World installation.
"""

import http.server
import json
import os
import subprocess
import sys
from pathlib import Path

PORT = 8082
HERE = Path(__file__).resolve().parent
PROJECT_ROOT = HERE.parent.parent
COMPOSITOR_SCRIPT = PROJECT_ROOT / "tools" / "ordnance_pbr_compositor.py"
MANIFEST_FILE = HERE / "customization.json"
PATCH_DIR = PROJECT_ROOT / "B-2 Spirit" / "Textures" / "Weapons"


class OrdnanceCustomizerHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(HERE), **kwargs)

    def do_GET(self):
        if self.path == "/api/manifest":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            if MANIFEST_FILE.exists():
                with open(MANIFEST_FILE, "r", encoding="utf-8") as f:
                    self.wfile.write(f.read().encode("utf-8"))
            else:
                self.wfile.write(b"{}")
            return

        elif self.path.startswith("/textures/"):
            rel_name = self.path[len("/textures/"):]
            tex_path = PATCH_DIR / rel_name
            if tex_path.exists():
                self.send_response(200)
                self.send_header("Content-Type", "image/png")
                self.end_headers()
                with open(tex_path, "rb") as f:
                    self.wfile.write(f.read())
                return
            else:
                self.send_error(404, "Texture not found")
                return

        return super().do_GET()

    def do_POST(self):
        if self.path == "/api/commit":
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
            try:
                data = json.loads(body.decode("utf-8"))
                with open(MANIFEST_FILE, "w", encoding="utf-8") as f:
                    json.dump(data, f, indent=2)

                print(f"[BRIDGE] Manifest updated. Running PBR Compositor: {COMPOSITOR_SCRIPT}...")
                res = subprocess.run(
                    [sys.executable, str(COMPOSITOR_SCRIPT)],
                    cwd=str(PROJECT_ROOT),
                    capture_output=True,
                    text=True,
                )
                print(res.stdout)
                if res.returncode != 0:
                    print(f"[!] Compositor error: {res.stderr}")
                    self.send_response(500)
                    self.send_header("Content-Type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"status": "error", "error": res.stderr}).encode("utf-8"))
                    return

                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                resp = {
                    "status": "success",
                    "message": "PBR textures compiled and synced to live DCS installation!",
                    "sortie": data.get("mission", {}).get("sortie_id", ""),
                }
                self.wfile.write(json.dumps(resp).encode("utf-8"))
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"status": "error", "message": str(e)}).encode("utf-8"))
            return

        self.send_error(404, "Endpoint not found")


def run_server():
    server = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), OrdnanceCustomizerHandler)
    print(f"============================================================")
    print(f" B-2 ORDNANCE CUSTOMIZER BRIDGE RUNNING")
    print(f" URL: http://localhost:{PORT}")
    print(f" Press Ctrl+C to stop.")
    print(f"============================================================")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down customizer bridge.")
        server.server_close()


if __name__ == "__main__":
    run_server()
