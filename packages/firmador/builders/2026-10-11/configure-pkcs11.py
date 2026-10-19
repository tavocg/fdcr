"""Select OpenSC from java.library.path in both supported source layouts."""
import re
from pathlib import Path

matches = list(Path("src/main/java").rglob("CRSigner.java"))
if len(matches) != 1:
    raise SystemExit("Expected exactly one CRSigner.java")
source = matches[0]
text = source.read_text()
pattern = r"(private static String detectJCOP4PKCS11Lib\(\)\s*\{).*?(?=\s*if \(pathloc != null\))"
replacement = r'''\1
        String pathloc = null;
        String name = System.getProperty("os.name").toLowerCase().contains("windows")
            ? "opensc-pkcs11.dll" : "opensc-pkcs11.so";
        for (String directory : System.getProperty("java.library.path", "").split(
                java.util.regex.Pattern.quote(File.pathSeparator), -1)) {
            File library = new File(directory.isEmpty() ? "." : directory, name);
            if (library.isFile() && library.canRead()) {
                pathloc = library.getAbsolutePath();
                break;
            }
        }
'''
text, count = re.subn(pattern, replacement, text, flags=re.DOTALL)
if count != 1:
    raise SystemExit("Expected exactly one PKCS#11 detection method")
source.write_text(text)
