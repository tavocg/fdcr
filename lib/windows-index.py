"""Generate FDCR's plain download list from metarepo's published MSI catalog."""
import html
import json
from pathlib import Path
import sys
from urllib.parse import quote

channel = Path(sys.argv[1])
catalog = channel / "catalog.json"
if catalog.exists():
    packages = json.loads(catalog.read_text())["packages"]
    links = []
    for package in sorted(packages, key=lambda p: (p["name"], p["version"], p["release"], p["architecture"])):
        label = "{name} {version} (revisión {release}, {architecture})".format(**package)
        links.append(f'<li><a href="{quote(package["file"])}">{html.escape(label)}</a></li>')
    (channel / "index.html").write_text(
        '<!doctype html>\n<html lang="es">\n<head><title>FDCR para Windows</title></head>\n'
        '<body>\n<h1>FDCR para Windows</h1>\n<ul>\n'
        + "\n".join(links) + '\n</ul>\n</body>\n</html>\n', encoding="ascii", errors="xmlcharrefreplace"
    )
