; RUN: opt -O2 -mtriple=arm64-apple-macosx -S %s | llc -mtriple=arm64-apple-macosx -o - | FileCheck %s

declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg)
declare ptr @sink(ptr)

; CHECK-LABEL: loop:
; CHECK: stp q0, q0, [sp]

define void @loop(ptr %src, ptr %p2, ptr %p3) {
entry:
    %t = alloca [40 x i8], align 8
    br label %body

body:
    call void @llvm.memcpy.p0.p0.i64(ptr %t, ptr %src, i64 16, i1 false)
    %t_plus_16 = getelementptr i8, ptr %t, i64 16
    call void @llvm.memcpy.p0.p0.i64(ptr %t_plus_16, ptr %src, i64 24, i1 false)
    %g1 = getelementptr i8, ptr %p3, i64 40
    store i8 0, ptr %g1, align 8
    %g2 = getelementptr i8, ptr %p2, i64 48
    %v = load i8, ptr %g2, align 1
    store i8 %v, ptr %src, align 1
    call ptr @sink(ptr %t)
    br label %body
}
