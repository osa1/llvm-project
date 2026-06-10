; RUN: %if aarch64-registered-target %{ opt -mtriple=aarch64-linux-gnu -mattr=+mops -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if aarch64-registered-target %{ opt -mtriple=aarch64-linux-gnu              -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,EXPAND %}
; RUN: %if x86-registered-target     %{ opt -mtriple=x86_64-pc-linux-gnu            -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if systemz-registered-target %{ opt -mtriple=systemz-linux-gnu              -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if webassembly-registered-target %{ opt -mtriple=wasm32-unknown-unknown -mattr=+bulk-memory-opt -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if webassembly-registered-target %{ opt -mtriple=wasm32-unknown-unknown                         -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,EXPAND %}
; RUN: %if riscv-registered-target   %{ opt -mtriple=riscv32-unknown-elf -mattr=+xqcilsm -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if riscv-registered-target   %{ opt -mtriple=riscv32-unknown-elf                 -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,EXPAND %}

declare void @llvm.memcpy.inline.p0.p0.i64(ptr, ptr, i64, i1)

define void @memcpy_large(ptr %dst, ptr %src) {
; INTACT-LABEL: @memcpy_large(
; INTACT-NEXT:    call void @llvm.memcpy.inline.p0.p0.i64(ptr {{.*}}, ptr {{.*}}, i64 2126656, i1 false)
; INTACT-NEXT:    ret void
;
; EXPAND-LABEL: @memcpy_large(
; EXPAND-NOT:   call void @llvm.memcpy.inline
; EXPAND:       store i8
  call void @llvm.memcpy.inline.p0.p0.i64(ptr %dst, ptr %src, i64 2126656, i1 false)
  ret void
}

define void @memcpy_small(ptr %dst, ptr %src) {
; COMMON-LABEL: @memcpy_small(
; COMMON-NEXT:    call void @llvm.memcpy.inline.p0.p0.i64(ptr {{.*}}, ptr {{.*}}, i64 10, i1 false)
; COMMON-NEXT:    ret void
  call void @llvm.memcpy.inline.p0.p0.i64(ptr %dst, ptr %src, i64 10, i1 false)
  ret void
}
