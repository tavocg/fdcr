#include <windows.h>
#include <wchar.h>
#include <shellapi.h>
int WINAPI wWinMain(HINSTANCE a, HINSTANCE b, LPWSTR args, int show) {
    wchar_t root[32768], java[32768], dll[32768], command[32768];
    DWORD n = GetModuleFileNameW(NULL, root, 32768);
    if (!n || n >= 32768 || !wcsrchr(root, L'\\')) return 1;
    *wcsrchr(root, L'\\') = 0;
    if (!GetEnvironmentVariableW(L"LIBASEP11", dll, 32768)) {
        if (!GetEnvironmentVariableW(L"ProgramW6432", dll, 32768) &&
            !GetEnvironmentVariableW(L"ProgramFiles", dll, 32768)) return 1;
        wcscat_s(dll, 32768, L"\\FDCR\\opensc\\bin\\opensc-pkcs11.dll");
        SetEnvironmentVariableW(L"LIBASEP11", dll);
    }
    if (GetFileAttributesW(dll) == INVALID_FILE_ATTRIBUTES) {
        MessageBoxW(NULL, L"Instale OpenSC de FDCR o configure LIBASEP11.", L"Firmador Libre", MB_ICONERROR);
        return 1;
    }
    if (!wcsrchr(dll, L'\\')) return 1;
    *wcsrchr(dll, L'\\') = 0;
    swprintf_s(java, 32768, L"%ls\\runtime\\bin\\javaw.exe", root);
    // Passing "run" makes Firmador skip its self-relaunch, which loses JVM
    // options and builds the JAR path with URI.getPath() (invalid on Windows).
    const wchar_t *run = (args == NULL || *args == 0) ? L"run" : L"";
    swprintf_s(command, 32768, L"\"%ls\" \"-Djava.library.path=%ls\" --add-exports jdk.crypto.cryptoki/sun.security.pkcs11.wrapper=ALL-UNNAMED -jar \"%ls\\firmador.jar\" %ls %ls", java, dll, root, run, args);
    int argc;
    LPWSTR *argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv && argc == 2 && wcsncmp(argv[1], L"firmador:", 9) == 0) {
        if (wcschr(argv[1], L'"')) { LocalFree(argv); return 1; }
        swprintf_s(command, 32768, L"\"%ls\" \"-Djava.library.path=%ls\" \"-Djnlp.remoteOrigin=%ls\" --add-exports jdk.crypto.cryptoki/sun.security.pkcs11.wrapper=ALL-UNNAMED -jar \"%ls\\firmador.jar\" run", java, dll, argv[1] + 9, root);
    }
    LocalFree(argv);
    STARTUPINFOW si = { .cb = sizeof(si) };
    PROCESS_INFORMATION pi;
    if (!CreateProcessW(java, command, NULL, NULL, FALSE, 0, NULL, root, &si, &pi)) return 1;
    CloseHandle(pi.hThread); CloseHandle(pi.hProcess);
    return 0;
}
