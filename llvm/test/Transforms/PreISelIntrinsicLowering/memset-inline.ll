; RUN: %if aarch64-registered-target %{ opt -mtriple=aarch64-linux-gnu -mattr=+mops -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if aarch64-registered-target %{ opt -mtriple=aarch64-linux-gnu              -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,EXPAND %}
; RUN: %if x86-registered-target     %{ opt -mtriple=x86_64-pc-linux-gnu            -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if systemz-registered-target %{ opt -mtriple=systemz-linux-gnu              -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if webassembly-registered-target %{ opt -mtriple=wasm32-unknown-unknown -mattr=+bulk-memory-opt -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if webassembly-registered-target %{ opt -mtriple=wasm32-unknown-unknown                         -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,EXPAND %}
; RUN: %if riscv-registered-target   %{ opt -mtriple=riscv32-unknown-elf -mattr=+xqcilsm -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,INTACT %}
; RUN: %if riscv-registered-target   %{ opt -mtriple=riscv32-unknown-elf                 -passes=pre-isel-intrinsic-lowering -S %s | FileCheck %s --check-prefixes=COMMON,EXPAND %}

declare void @llvm.memset.inline.p0.i64(ptr, i8, i64, i1)

define void @memset_large(ptr %dest) {
; INTACT-LABEL: @memset_large(
; INTACT-NEXT:    call void @llvm.memset.inline.p0.i64(ptr {{.*}}, i8 0, i64 2126656, i1 false)
; INTACT-NEXT:    ret void
;
; EXPAND-LABEL: @memset_large(
; EXPAND-NOT:   call void @llvm.memset.inline
; EXPAND:       store i8 0
  call void @llvm.memset.inline.p0.i64(ptr %dest, i8 0, i64 2126656, i1 false)
  ret void
}

define void @memset_small(ptr %dest) {
; COMMON-LABEL: @memset_small(
; COMMON-NEXT:    call void @llvm.memset.inline.p0.i64(ptr {{.*}}, i8 0, i64 10, i1 false)
; COMMON-NEXT:    ret void
  call void @llvm.memset.inline.p0.i64(ptr %dest, i8 0, i64 10, i1 false)
  ret void
}
