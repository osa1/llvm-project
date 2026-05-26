; RUN: llc %s -o - | FileCheck %s

target triple = "arm64-apple-macosx"

declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

declare ptr @sink(ptr) local_unnamed_addr

; CHECK-LABEL: loop:
; CHECK: stp q0, q0, [sp]

define void @loop(ptr captures(none) %src, ptr readonly captures(none) %p2, ptr writeonly captures(none) initializes((40, 41)) %p3) local_unnamed_addr #1 {
entry:
  %t = alloca [40 x i8], align 8
  %t_plus_16 = getelementptr inbounds nuw i8, ptr %t, i64 16
  %g1 = getelementptr i8, ptr %p3, i64 40
  %g2 = getelementptr i8, ptr %p2, i64 48
  br label %body

body:
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %t, ptr noundef nonnull align 1 dereferenceable(16) %src, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %t_plus_16, ptr noundef nonnull align 1 dereferenceable(24) %src, i64 24, i1 false)
  store i8 0, ptr %g1, align 8
  %v = load i8, ptr %g2, align 1
  store i8 %v, ptr %src, align 1
  %0 = call ptr @sink(ptr nonnull %t)
  br label %body
}
