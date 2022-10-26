# mysetup

Run `powershell -ExecutionPolicy bypass win\setup.ps1` as non-admin

For Windows 11

```
Set-ExecutionPolicy Unrestricted
```

```
dir -Path . -Recurse | Unblock-File
```