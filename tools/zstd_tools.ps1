# Shared zstd helpers via Git's libzstd.dll
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ZstdLib {
    [DllImport("C:\\Program Files\\Git\\mingw64\\bin\\libzstd.dll")] public static extern ulong ZSTD_decompress(byte[] dst, ulong dstCap, byte[] src, ulong srcSize);
    [DllImport("C:\\Program Files\\Git\\mingw64\\bin\\libzstd.dll")] public static extern uint ZSTD_isError(ulong code);
    [DllImport("C:\\Program Files\\Git\\mingw64\\bin\\libzstd.dll")] public static extern ulong ZSTD_compress(byte[] dst, ulong dstCap, byte[] src, ulong srcSize, int level);
    [DllImport("C:\\Program Files\\Git\\mingw64\\bin\\libzstd.dll")] public static extern ulong ZSTD_compressBound(ulong srcSize);
}
'@

function Decompress-CaFile([byte[]]$raw) {
    # CA packed file: u32 uncompressed size + zstd frame
    $uncompSize = [BitConverter]::ToUInt32($raw, 0)
    $src = New-Object byte[] ($raw.Length - 4)
    [Array]::Copy($raw, 4, $src, 0, $src.Length)
    $dst = New-Object byte[] $uncompSize
    $res = [ZstdLib]::ZSTD_decompress($dst, [uint64]$uncompSize, $src, [uint64]$src.Length)
    if ([ZstdLib]::ZSTD_isError($res) -ne 0 -or $res -ne $uncompSize) { throw "zstd decompress failed: res=$res expected=$uncompSize" }
    return $dst
}

function Compress-CaFile([byte[]]$data) {
    $bound = [ZstdLib]::ZSTD_compressBound([uint64]$data.Length)
    $dst = New-Object byte[] ([int]$bound)
    $res = [ZstdLib]::ZSTD_compress($dst, [uint64]$bound, $data, [uint64]$data.Length, 3)
    if ([ZstdLib]::ZSTD_isError($res) -ne 0) { throw "zstd compress failed" }
    $out = New-Object byte[] (4 + [int]$res)
    [Array]::Copy([BitConverter]::GetBytes([uint32]$data.Length), 0, $out, 0, 4)
    [Array]::Copy($dst, 0, $out, 4, [int]$res)
    return $out
}
